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

function getCards(url) {
  console.log("Visit next page");
  return fetch(url)
    .then((response) => response.json())
    .then(async (response) => {
      const out = response.data.map((it) => {
        const manaType = it.mana_cost.match(manaTypeRegex)
        const priceUSDstr = it.prices["usd"]
        return {
          id: it.collector_number,
          name: it.name,
          rarity: it.rarity,
          scryfall_uri: it.scryfall_uri,
          image_url: it.image_uris.small,
          isBasicLand: it.type_line.includes("Basic Land"),
          isToken: it.type_line.includes("Token"),
          manaType: manaType ? manaType.filter(uniq).sort().join("") : "-",
          convertedManaCost: it.cmc,
          price: priceUSDstr ? parseFloat(priceUSDstr) : -1
        };
      });
      if (response.has_more) {
        out.push.apply(out, await getCards(response.next_page));
      }
      return out;
    })
    .catch((error) => console.log(error));
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

async function generateDeck(numBoosters, remoteCards, cardsByRarity, indexDeck) {
  const allCards = [];
  const genFiles = []

  // generating booster files
  await generateBoosterFiles();

  // using the generated booster info to create filtered sets based on mana type
  const cardsByMana = groupCardsByMana(allCards.flat());
  await writeManaGroupedPages(cardsByMana);
  await writePricePage(allCards, genFiles);
  await writeIndexFile(cardsByMana, numBoosters, genFiles);
  await writeAllCardsPage(allCards, genFiles);

  await compress(genFiles, `sealed-deck-${indexDeck}.zip`, { overwrite: true });

  genFiles.forEach(element => {
    Deno.remove(element)
  });

  async function writeAllCardsPage(allCards, genFiles) {
    const filename = "mtg-all-cards.html";
    const sortedCards = sortByField(
      sortByField(
        sortByField(
          allCards.flat(),
          "id"),
        "convertedManaCost"),
      "manaType"
    )

    const output = createAllCardsContent(sortedCards);
    genFiles.push(filename);
    await Deno.writeTextFile(filename, output);

    function createAllCardsContent(cards) {
      return `
      <html><body>
      <div style="display: flex; flex-wrap: wrap;">
      ${cards.map((it, index) => {
        return `
      <div id="${index}">
      <a href="${it.scryfall_uri}">
      <img src="${it.image_url}"/>
      </a>
      <div onclick="rmCard(${index})">
      Remove
      </div>
      </div>`;
      }).join("\n")}
      </div>
      <script>
      function rmCard(cardId) {
        document.getElementById(cardId).style.display = "none"
      }
      </script>
      </body></html>
    `;
    }
  }

  async function generateBoosterFiles() {
    for (let index = 0; index < numBoosters; index++) {
      const cards = await buildBooster(await remoteCards, cardsByRarity);
      allCards.push(cards);
      console.log(cards.map((it) => it.name));
      const output = createBoosterFileContent(cards);
      const filename = `mtg-booster-${index}.html`;
      genFiles.push(filename);
      await Deno.writeTextFile(filename, output);
    }


    function buildBooster(allCards, cardsByRarity) {
      const getRandomFromArray = (arr) => arr[Math.floor(Math.random() * arr.length)];

      function getRandomByRarity(cardsByRarity, rarity) {
        return cardsByRarity[rarity][
          Math.floor(Math.random() * cardsByRarity[rarity].length)
        ];
      }

      const findBasicLands = (cards) => cards
        .filter((it) => it.isBasicLand);

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
  }

  async function writeManaGroupedPages(cardsByMana) {
    for (const key in cardsByMana) {
      if (Object.hasOwnProperty.call(cardsByMana, key)) {
        const element = cardsByMana[key];
        const output = createBoosterFileContent(element);
        const filename = `mtg-booster-filtered-${key}.html`;
        genFiles.push(filename);
        await Deno.writeTextFile(filename, output);
      }
    }
  }
}

async function writePricePage(allCards, genFiles) {
  const cardsByPrice = sortByField(allCards.flat(), "price")
  const output = `
  <html><body>
  ${cardsByPrice.map((it) => `<a href="${it.scryfall_uri}"><div>${it.name}: ${it.price}</div></a>`).join("\n")}
  </body></html>
  `;
  const filename = `mtg-price.html`;
  genFiles.push(filename);
  await Deno.writeTextFile(filename, output);
}

function sortByField(arr, field) {
  function byField(field) {
    return (a, b) => {
      if (a[field] > b[field]) {
        return -1;
      } else if (a[field] < b[field]) {
        return 1;
      } else {
        return 0;
      }
    };
  }
  return arr.sort(byField(field))
}

async function writeIndexFile(cardsByMana, numBoosters, genFiles) {
  const filename = "index.html";
  const output = createIndexFileContent(cardsByMana, numBoosters);
  genFiles.push(filename);
  await Deno.writeTextFile(filename, output);

  function createIndexFileContent(cardsByMana, numBoosters) {
    const lines = []
    for (let index = 0; index < numBoosters; index++) {
      lines.push(`<a href="./mtg-booster-${index}.html"><div>Booster #${index}</div></a>`)
    }
    lines.push('<hr>')
    const keys = []
    for (const key in cardsByMana) {
      keys.push(key)
    }
    keys.sort().forEach(key => {
      if (Object.hasOwnProperty.call(cardsByMana, key)) {
        const element = cardsByMana[key];
        lines.push(`<a href="./mtg-booster-filtered-${key}.html"><div>${key}: <strong>${element.length}</strong> cards</div></a>`)
      }
    })
    lines.push('<hr>')
    lines.push(`<a href="./mtg-price.html"><div>Cards by price</a>`)
    lines.push(`<a href="./mtg-all-cards.html"><div>All cards</a>`)
    return `
  <html><body>
  ${lines.flat().join("\n")}
  </body></html>
`
  }
}

function createBoosterFileContent(cards) {
  return `
  <html><body>
  ${cards.map((it) => `<a href="${it.scryfall_uri}"><img src="${it.image_url}"/></a>`
  ).join("\n")}
  </body></html>
`;
}

main();
