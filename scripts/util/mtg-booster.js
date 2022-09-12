#!/usr/bin/env deno run --allow-net --allow-write --allow-read --allow-run

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

const groupCardsByRarity = (cards) => cards
  .filter((it) => !it.isBasicLand && !it.isToken)
  .reduce((acc, value) => {
    if (!acc[value.rarity]) {
      acc[value.rarity] = [];
    }
    acc[value.rarity].push(value);
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
        return {
          id: it.collector_number,
          name: it.name,
          rarity: it.rarity,
          scryfall_uri: it.scryfall_uri,
          image_url: it.image_uris.small,
          isBasicLand: it.type_line.includes("Basic Land"),
          isToken: it.type_line.includes("Token"),
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

function getRandomFromArray(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

async function main() {
  const a = getCards(startUrl);
  const cardsByRarity = groupCardsByRarity(await a);
  const numBoosters = 6;
  const numDecks = 3;
  for (let indexDeck = 0; indexDeck < numDecks; indexDeck++) {
    for (let index = 0; index < numBoosters; index++) {
      const cards = await buildBooster(await a, cardsByRarity);
      console.log(cards);
      const output = createBoosterFileContent(cards);
      await Deno.writeTextFile(`mtg-booster-${index}.html`, output);
    }
    let count = 0
    await compress(Array(numBoosters).fill(0).map(() => `mtg-booster-${count++}.html`), `sealed-deck-${indexDeck}.zip`, { overwrite: true })
  }
}
main();

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

