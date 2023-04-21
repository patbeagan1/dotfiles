const express = require('express');
const fs = require('fs');
const path = require('path');
const JSZip = require('jszip');
const app = express();

const cbrDirectory = './'; // Use the current directory as the CBR directory

app.get('/', async (req, res) => {
  const cbrFiles = getCbrFiles(cbrDirectory);
  const links = await Promise.all(cbrFiles.map(async (file) => await getLinkHTML(file)))

  const html = `
    <html>
      <head>
        <title>CBR Viewer - Home</title>
        <style>
          .cbr-link {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            width: 200px;
            margin: 10px;
            padding: 10px;
            border-radius: 10px;
            background-color: #f5f5f5;
            box-shadow: 0 2px 5px rgba(0,0,0,0.3);
            text-decoration: none;
            color: black;
          }
          .cbr-link img {
            width: 100%;
            border-radius: 10px;
            margin-bottom: 10px;
          }
        </style>
      </head>
      <body>
        <h1>CBR Viewer</h1>
        <div style="display: flex; flex-wrap: wrap;">
          ${links.join('')}
        </div>
      </body>
    </html>
  `;
  res.send(html);
});

app.get('/cbrviewer/:fileName', async (req, res) => {
  try {
    const cbrFileName = req.params.fileName;
    const zip = await readZip(cbrFileName)

    const images = await Promise.all(
      findImageFileObjects(zip)
        .map(async (entry) => {
          return {
            name: entry.name,
            url: await getImageUrlFor(entry)
          }
        }));

    images.sort((a, b) => {
      const nameA = a.name.toUpperCase();
      const nameB = b.name.toUpperCase();
      if (nameA < nameB) {
        return -1;
      } else if (nameA > nameB) {
        return 1;
      } else {
        return 0;
      }
    })

    const html = `
      <html>
        <head>
          <title>CBR Viewer - ${cbrFileName}</title>
          <style>
          #container {
            display: flex;
            justify-content: center;
          }
          #container > div {
            width: 90%;
          }
          .cbr-image-container {
            display: flex;
            justify-content: center;
          }
          .cbr-image {
            width: 100%;
          }
          </style>
        </head>
        <body>
          <h1>${cbrFileName}</h1>
          <div id="container">
            <div>
              ${images.map(each => `
                <div class="cbr-image-container">
                  <img class="cbr-image" src="${each.url}">
                </div>
              `).join('')}
            </div>
          </div>
        </body>
      </html>
    `;
    res.send(html);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error displaying CBR file');
  }
});

app.listen(3000, () => console.log('Server started at http://localhost:3000'));

async function getImageUrlFor(entry) {
  const type = entry.name.search(/.(\w)$/);
  const blob = await entry.async('base64');
  const url = `data:${type};base64,${blob}`;
  return url;
}

function getCbrFiles(directoryPath) {
  const files = fs.readdirSync(directoryPath);
  const cbrFiles = files.filter((file) => {
    const extName = path.extname(file).toLowerCase();
    const isCBR = extName === '.cbr';
    const isCBZ = extName === '.cbz';
    return isCBR || isCBZ;
  });
  return cbrFiles;
}

async function readZip(fileName) {
  const filePath = path.join(cbrDirectory, fileName);
  const zip = JSZip.loadAsync(fs.readFileSync(filePath));
  return zip
}

function findImageFileObjects(zipFile) {
  return zipFile.file(/.jpg|.JPG|.jpeg|.png/)
}

async function getLinkHTML(fileName) {
  const zip = readZip(fileName)
  return zip.then(async zipFile => {
    try {
      const entry = findImageFileObjects(zipFile)[0]
      const url = await getImageUrlFor(entry)
      return `
        <a href="/cbrviewer/${fileName}" class="cbr-link">
          <img src="${url}">
          <span>${fileName}</span>
        </a>
      `;
    } catch (error) {
      console.error(error)
      return ""
    }
  });
}


