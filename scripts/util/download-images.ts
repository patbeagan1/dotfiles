#!/usr/bin/env -S deno run --allow-net --allow-write

// Import required modules from the Deno standard library
import { Sha256 } from "https://deno.land/std@0.160.0/hash/sha256.ts"
import { writeCSV } from "https://deno.land/x/csv/mod.ts";

// Function to download an image from a URL and store it with a specific filename format
async function downloadImage(url) {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Failed to fetch ${url}: ${response.statusText}`);
    }
    const buffer = await response.arrayBuffer();
    const hash = new Sha256();
    hash.update(buffer);
    const hexHash = hash.toString('hex');
    const timestamp = Date.now();
    const extension = url.split('.').pop().split('?')[0];
    const newFileName = `${timestamp}-${hexHash}.${extension}`;
    await Deno.writeFile(newFileName, new Uint8Array(buffer));
    console.log(`Downloaded ${newFileName}`);

    // Append a row to record.csv
    const originalFileName = url.split('/').pop();
    const csvData = [[originalFileName, newFileName, url]];
    
    const f = await Deno.open("./record.csv", {
      create: true,
      append: true,
    });
    await f.write(new TextEncoder().encode("\n"));
    await writeCSV(f, csvData);
    f.close();

  } catch (error) {
    console.error(`Error downloading ${url}: ${error.message}`);
  }
}

// Get image URLs from command-line arguments
const imageUrls = Deno.args;

// Validate that there are URLs provided
if (imageUrls.length === 0) {
  console.error('No image URLs provided. Please provide at least one URL as a command-line argument.');
  Deno.exit(1);
}

// Download all images using promises for parallel execution
await Promise.all(imageUrls.map(downloadImage));

