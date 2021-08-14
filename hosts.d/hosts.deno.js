import { parse as yamlParse } from "https://deno.land/std@0.82.0/encoding/yaml.ts";

const outputFileName = "./build/hosts";
const main = (debug) => {
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
    .map((fileName) => yamlParse(Deno.readTextFileSync(fileName)))
    .flatMap((it) => it)
    .map((it) => it.split(".").reverse().join("."))
    .sort()
    .map((it) => it.split(".").reverse().join("."));
}

main(false);
