#!/usr/bin/env -S deno run --allow-net --allow-write --allow-read --allow-run

import { compress } from "https://deno.land/x/zip@v1.2.3/mod.ts";

const startUrl = "https://api.scryfall.com/cards/search" +
  "?format=json" +
  "&include_extras=true" +
  "&include_multilingual=false" +
  "&include_variations=true" +
  "&order=set" +
  "&page=1" +
  "&q=e%3Admu" +
  "&unique=prints";

const manaTypeRegex = /[A-Z]/gi;

const uniq = (value, index, self) => self.indexOf(value) === index;

const groupCardsByRarity = (cards) => cards
  .filter((it) => !it.isBasicLand && !it.isToken)
  .reduce((acc, value) => {
    if (!acc[value.rarity]) {
      acc[value.rarity] = [];
    }
    acc[value.rarity].push(value);
    return acc;
  }, {});

const groupCardsByMana = (cards) => cards
  .reduce((acc, value) => {
    if (!acc[value.manaType]) {
      acc[value.manaType] = [];
    }
    acc[value.manaType].push(value);
    return acc;
  }, {});

const findBasicLands = (cards) => cards
  .filter((it) => it.isBasicLand);

function getCards(url) {
  console.log("Visit next page");
  return fetch(url)
    .then((response) => response.json())
    .then(async (response) => {
      const out = response.data.map((it) => {
        const manaType = it.mana_cost.match(manaTypeRegex)
        return {
          id: it.collector_number,
          name: it.name,
          rarity: it.rarity,
          scryfall_uri: it.scryfall_uri,
          image_url: it.image_uris.small,
          isBasicLand: it.type_line.includes("Basic Land"),
          isToken: it.type_line.includes("Token"),
          manaType: manaType ? manaType.filter(uniq).sort().join("") : "-"
        };
      });
      if (response.has_more) {
        out.push.apply(out, await getCards(response.next_page));
      }
      return out;
    })
    .catch((error) => console.log(error));
}

function getRandomByRarity(cardsByRarity, rarity) {
  return cardsByRarity[rarity][
    Math.floor(Math.random() * cardsByRarity[rarity].length)
  ];
}


async function main() {
  const remoteCards = getCards(startUrl);
  const cardsByRarity = groupCardsByRarity(await remoteCards);
  const numBoosters = 6;
  const numDecks = 3;
  for (let indexDeck = 0; indexDeck < numDecks; indexDeck++) {
    await generateDeck(numBoosters, remoteCards, cardsByRarity, indexDeck);
  }
  console.log(startUrl)
}
main();

function getRandomFromArray(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

async function generateDeck(numBoosters, remoteCards, cardsByRarity, indexDeck) {
  const allCards = [];
  const genFiles = []

  // generating booster files
  for (let index = 0; index < numBoosters; index++) {
    const cards = await buildBooster(await remoteCards, cardsByRarity);
    allCards.push(cards);
    console.log(cards.map((it) => it.name));
    const output = createBoosterFileContent(cards);
    const filename = `mtg-booster-${index}.html`
    genFiles.push(filename)
    await Deno.writeTextFile(filename, output);
  }

  // using the generated booster info to create filtered sets based on mana type
  const cardsByMana = groupCardsByMana(allCards.flat());
  for (const key in cardsByMana) {
    if (Object.hasOwnProperty.call(cardsByMana, key)) {
      const element = cardsByMana[key];
      const output = createBoosterFileContent(element);
      const filename = `mtg-booster-filtered-${key}.html`
      genFiles.push(filename)
      await Deno.writeTextFile(filename, output);
    }
  }

  const filename = "index.html"
  const output = createIndexFileContent(cardsByMana, numBoosters)
  genFiles.push(filename)
  await Deno.writeTextFile(filename, output);

  await compress(genFiles, `sealed-deck-${indexDeck}.zip`, { overwrite: true });
}

function createIndexFileContent(cardsByMana, numBoosters) {
  const lines = []
  for (let index = 0; index < numBoosters; index++) {
    lines.push(`<a href="./mtg-booster-${index}.html"><div>Booster #${index}</div></a>`)
  }
  lines.push('<hr>')
  for (const key in cardsByMana) {
    if (Object.hasOwnProperty.call(cardsByMana, key)) {
      const element = cardsByMana[key];
      lines.push(`<a href="./mtg-booster-filtered-${key}.html"><div>${key}: <strong>${element.length}</strong> cards</div></a>`)
    }
  }
  return `
  <html><body>
  ${lines.join("\n")}
  </body></html>
`
}

function createBoosterFileContent(cards) {
  return `
  <html><body>
  ${cards.map((it) => `<a href="${it.scryfall_uri}"><img src="${it.image_url}"/></a>`
  ).join("\n")}
  </body></html>
`;
}

function buildBooster(allCards, cardsByRarity) {
  return [
    Array(10).fill(0).map(() => getRandomByRarity(cardsByRarity, "common")),
    Array(3).fill(0).map(() => getRandomByRarity(cardsByRarity, "uncommon")),
    [
      Math.floor(Math.random() * 8) === 0
        ? getRandomByRarity(cardsByRarity, "mythic")
        : getRandomByRarity(cardsByRarity, "rare"),
    ],
    [getRandomFromArray(findBasicLands(allCards))],
  ].flatMap((it) => it);
}

