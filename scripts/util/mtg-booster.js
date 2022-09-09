#!/usr/bin/env deno run --allow-net --allow-write

const startUrl = 'https://api.scryfall.com/cards/search' +
  '?format=json' +
  '&include_extras=true' +
  '&include_multilingual=false' +
  '&include_variations=true' +
  '&order=set' +
  '&page=1' +
  '&q=e%3Admu' +
  '&unique=prints'

const groupCardsByRarity = (cards) => cards.reduce((acc, value) => {
  if (!acc[value.rarity]) {
    acc[value.rarity] = []
  }
  acc[value.rarity].push(value)
  return acc
}, {})

async function getNextPage(url) {
  console.log('Visit next page')
  return fetch(url)
    .then((response) => response.json())
    .then(async (response) => {
      const out = response.data.map((it) => {
        return {
          id: it.collector_number,
          name: it.name,
          rarity: it.rarity,
          scryfall_uri: it.scryfall_uri,
          image_url: it.image_uris.small
        }
      })
      if (response.has_more) {
        out.push.apply(out, await getNextPage(response.next_page))
      }
      return out
    })
    .catch((error) => console.log(error))
}

function getRandomByRarity(cardsByRarity, rarity) {
  return cardsByRarity[rarity][Math.floor(Math.random() * cardsByRarity[rarity].length)]
}

const a = getNextPage(startUrl)
async function main() {
  const cardsByRarity = groupCardsByRarity(await a)
  const cards = [
    Array(10).fill(0).map(() => getRandomByRarity(cardsByRarity, 'common')),
    Array(3).fill(0).map(() => getRandomByRarity(cardsByRarity, 'uncommon')),
    [Math.floor(Math.random() * 8) === 0
      ? getRandomByRarity(cardsByRarity, 'mythic')
      : getRandomByRarity(cardsByRarity, 'rare')]
  ].flatMap((it) => it)

  console.log(cards)

  const output = `
  <html><body>
  ${cards.map((it) => `<a href="${it.scryfall_uri}"><img src="${it.image_url}"/></a>`).join('\n')}
  </body></html>
`
  await Deno.writeTextFile('./mtg-booster.html', output)
}
main()
