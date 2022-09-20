const DATA_FOR_WEBRING = `https://raw.githubusercontent.com/CSS-Tricks/css-webring/main/webring.json`;

//based on https://css-tricks.com/how-you-might-build-a-modern-day-webring/

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

        const thisSite = this.getAttribute("current-site");

        fetch(DATA_FOR_WEBRING)
            .then((response) => response.json())
            .then((sites) => {

                this.shadowRoot
                    .querySelector("#webring-loading")
                    .remove()

                const matchedSiteIndex = sites.findIndex((site) => site.url === thisSite);
                const matchedSite = sites[matchedSiteIndex];

                let prevSiteIndex = matchedSiteIndex - 1;
                if (prevSiteIndex === -1) prevSiteIndex = sites.length - 1;

                let nextSiteIndex = matchedSiteIndex + 1;
                if (nextSiteIndex > sites.length) nextSiteIndex = 0;

                const cp = `
                    <h1>Derivative of the Great CSS Webring</h1>
                    <p>
                        This <a href="${matchedSite.url}">${matchedSite.name}</a> site is owned by ${matchedSite.owner}
                    </p>
                    
                    <p>
                        <a href="${sites[prevSiteIndex].url}">[Prev]</a> |
                        <a href="${sites[nextSiteIndex].url}">[Next]</a>
                    </p>
                    `;

                this.shadowRoot
                    .querySelector("#webring-copy")
                    .insertAdjacentHTML("afterbegin", cp);
            });
    }
}

window.customElements.define("webring-css", WebRing);