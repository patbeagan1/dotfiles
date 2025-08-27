#!/usr/bin/zsh

function q-heb {
web-open.sh 'https://www.heb.com/search?Ns=product.salePrice%7C0&q='"$1"

}
while IFS= read -r line; do q-heb $line; sleep 20; done < "$1"
