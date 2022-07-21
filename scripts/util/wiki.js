#!/usr/bin/env deno run --allow-net

let url = 'https://en.wikipedia.org/w/api.php'

const params = {
  action: 'query',
  format: 'json',
  titles: Deno.args,
  prop: 'info',
  inprop: 'url|talkid'
}

url = url + '?origin=*'

Object
  .keys(params)
  .forEach((key) => {
    url += '&' + key + '=' + params[key]
  })

const getPageUrlByCurrId = (curid) => {
  return `http://en.wikipedia.org/?curid=${curid}`
}

fetch(url)
  .then((response) => response.json())
  .then((response) => {
    const pages = Object.values(
      response.query.pages
    )
    pages.forEach((it) => {
      console.log(`${getPageUrlByCurrId(it.pageid)}`)
    })
  })
  .catch((error) => console.log(error))

/*
  Sample response:
{
  pageid: 736,
  ns: 0,
  title: "Albert Einstein",
  contentmodel: "wikitext",
  pagelanguage: "en",
  pagelanguagehtmlcode: "en",
  pagelanguagedir: "ltr",
  touched: "2022-07-20T02:49:02Z",
  lastrevid: 1097822042,
  length: 208683,
  talkid: 21091085,
  fullurl: "https://en.wikipedia.org/wiki/Albert_Einstein",
  editurl: "https://en.wikipedia.org/w/index.php?title=Albert_Einstein&action=edit",
  canonicalurl: "https://en.wikipedia.org/wiki/Albert_Einstein"
}
 */
