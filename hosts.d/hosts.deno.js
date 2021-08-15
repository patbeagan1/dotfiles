import { parse as yamlParse } from "https://deno.land/std@0.82.0/encoding/yaml.ts";
import combinate from "https://raw.githubusercontent.com/nas5w/combinate/v1.1.6/index.ts";

const debug = false;
const outputFileName = "./build/hosts";

const main = () => {
  const fileList = generateFileList();
  if (debug) console.log(fileList);

  const sites = generateSiteList(fileList);
  if (debug) console.log(sites);

  const hostString = generateHostsContent(sites);

  Deno.writeTextFile(outputFileName, hostString).then(() =>
    console.log(`\nFile written to ${outputFileName}`)
  );
};

/**
 * finding all of the yaml files that we'll be operating on
 */
function generateFileList() {
  const fileList = [];
  const readData = (directory) => {
    for (const dirEntry of Deno.readDirSync(directory)) {
      const name = `${directory}/${dirEntry.name}`;
      if (dirEntry.isFile) {
        console.log("file: " + name);
        fileList.push(name);
      } else {
        console.log("dir : " + name);
        readData(name);
      }
    }
  };
  readData("data");
  return fileList;
}

/**
 * building contents of the hosts file
 */
function generateHostsContent(sites) {
  const checkhost = (it) => it?.split(".")?.slice(-2)?.join("");
  const hostString = sites
    .map((it, index) => {
      const separator =
        checkhost(sites[index - 1]) === checkhost(sites[index]) ? "" : "\n";
      return `${separator}127.0.0.1\t${it}`;
    })
    .join("\n");
  return hostString;
}

/**
 * flattening the list of sites and sorting them based on their host
 */
function generateSiteList(fileList) {
  return fileList
    .map((fileName) => {
      if (fileName.endsWith(".yaml")) {
        return yamlParse(Deno.readTextFileSync(fileName));
      }
      if (fileName.endsWith(".txt")) {
        return parseTxtFile(fileName);
      }
    })
    .flatMap((it) => it)
    .map(expandRanges)
    .map(expandMatches)
    .flatMap((it) => it)
    .map((it) => it.split(".").reverse().join("."))
    .sort()
    .map((it) => it.split(".").reverse().join("."));
}

function parseTxtFile(fileName) {
  const commentRegex = RegExp("^[ \t]*#");
  const contents = Deno.readTextFileSync(fileName)
    .split("\n")
    .filter((it) => {
      return !it.match(commentRegex);
    })
    .filter((it) => it);
  if (debug) console.log(contents);
  return contents;
}

/**
 * Expands a range such as [1..4] into [1,2,3,4]
 * This makes it compatible with the expandMatches step
 */
function expandRanges(input) {
  //g[1..4][a,z]oogle.com -> ["1,2,3,4", "a,z"]
  const regex = new RegExp(`\\[([^\\[\\]]+)\\]`);
  const found = input.split(regex).filter((it) => it.includes(".."));
  if (found.length <= 0) return input;

  let ret = input;
  for (let item of found) {
    let nums = item.split("..");
    const first = Number(nums[0]);
    const second = Number(nums[1]);
    const arrayLength = second - first;

    let replacement = [...Array(arrayLength).keys()]
      .map((it) => it + first)
      .join(",");
    ret = ret.replaceAll(item, replacement);
  }

  if (debug) console.log(input + " -> " + ret);
  return ret;
}

/**
 * Allows for compact declaration of variations on a domain.
 * For example, media[1,2,3][1,2] would stand in for media11, media21, media31, media12, media22, media32
 * Useful since a lot of the domain names just iterate, and there is no way to do pattern matching in a hosts file.
 */
function expandMatches(input) {
  //g[1,2,3,4][a,z]oogle.com -> ["1,2,3,4", "a,z"]
  const regex = new RegExp(`\\[([^\\[\\]]+)\\]`);
  const found = input.split(regex).filter((it) => it.includes(","));
  if (found.length <= 0) return input;

  const cleanString = input.replaceAll("[", "").replaceAll("]", "");

  const combinations = combinate(
    found.map((i) => {
      return i.split(",").flatMap((j) => {
        return { match: i, replacewith: j };
      });
    })
  );

  const combos = combinations.map((it) => {
    let replacedString = cleanString;
    for (const [key, value] of Object.entries(it)) {
      replacedString = replacedString.replaceAll(
        value.match,
        value.replacewith
      );
    }
    return replacedString;
  });
  return combos;
}

main();
