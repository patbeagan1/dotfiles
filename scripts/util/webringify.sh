#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help() {
    error_code=$?
    echo "
No help message yet
"
    exit $error_code
}

webringify() {
    mkdir -p webring

    count=0
    for i in $(find . -d 1 -name "*.txt" | sort -n  ); do
        echo '<html><body>' >> "webring/$count.html"
        echo '<style>
        body {
            background-color: #e5e5e5;
        }
        pre { 
            background: #f5f5f5;
            font: 14px/22px normal verdana, helvetica, sans-serif; 
            margin-top: 20px;
            margin-bottom: 20px;
            padding: 20px;
            border-radius: 10px;
            overflow-x: auto;
        }
        </style>' >> "webring/$count.html"
        echo "<webring-component current-site=\"$count\"></webring-component>" >> "webring/$count.html"
        echo '<pre>' >> "webring/$count.html"
        cat "$i" >> "webring/$count.html"
        echo '</pre>' >> "webring/$count.html"
        echo "<webring-component current-site=\"$count\"></webring-component>" >> "webring/$count.html"
        echo '<script src="./webring.js"></script>' >> "webring/$count.html"
        echo '</body></html>' >> "webring/$count.html"
        count=$((count + 1))
    done

    echo '
const template = document.createElement("template");
template.innerHTML = `
<style>
.webring {
  border: 5px solid #222;
  border-top-color: #777;
  border-left-color: #777;
  text-align: center;
  font: 100% system-ui, sans-serif;
}
</style>

<div class="webring">
  <div id="webring-loading">
    Loading
  </div>
  <div id="webring-copy"></div>
</div>`;

class WebRing extends HTMLElement {
    connectedCallback() {
        this.attachShadow({ mode: "open" });
        this.shadowRoot.appendChild(template.content.cloneNode(true));

        const thisSite = parseInt(this.getAttribute("current-site"));

        this.shadowRoot
            .querySelector("#webring-loading")
            .remove()

        let prevSiteIndex = thisSite - 1;
        if (prevSiteIndex === -1) prevSiteIndex = 0;
        let nextSiteIndex = thisSite + 1;

        const cp = `<p>
            <a href="/${prevSiteIndex}.html">[Prev]</a> |
            <a href="/${nextSiteIndex}.html">[Next]</a>
        </p>`;

        this.shadowRoot
            .querySelector("#webring-copy")
            .insertAdjacentHTML("afterbegin", cp);
    }
}

window.customElements.define("webring-component", WebRing);
' >> webring/webring.js
}

webringify "$@" || help
trackusage.sh "$0"
