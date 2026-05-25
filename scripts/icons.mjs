import fs from "fs";
import path from "path";
import crypto from "crypto";
import sharp from "sharp";
import icongen from "icon-gen";

const srcDir = path.resolve("images");
const cacheDir = path.resolve(".cache/icons");
const outDir = path.resolve("icons");

function hashFile(filePath) {
  const data = fs.readFileSync(filePath);
  return crypto.createHash("sha1").update(data).digest("hex");
}

async function normalizeImage(inputPath, outputPath) {
  await sharp(inputPath)
    .resize(256, 256, {
      fit: "contain",
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png({
      compressionLevel: 9,
      adaptiveFiltering: true,
    })
    .toFile(outputPath);
}

async function main() {
  if (!fs.existsSync(srcDir)) {
    throw new Error(`Missing directory: ${srcDir}`);
  }

  fs.mkdirSync(cacheDir, { recursive: true });
  fs.mkdirSync(outDir, { recursive: true });

  const files = fs.readdirSync(srcDir).filter((f) => path.extname(f).toLowerCase() === ".png");

  if (files.length === 0) {
    console.log("No PNG files found in images/");
    return;
  }

  console.log(`Processing ${files.length} image(s)...`);

  for (const file of files) {
    const input = path.join(srcDir, file);
    const name = path.basename(file, ".png");

    const hash = hashFile(input);
    const cachedPng = path.join(cacheDir, `${name}.${hash}.png`);

    try {
      if (!fs.existsSync(cachedPng)) {
        console.log(`→ Normalizing ${file}`);
        await normalizeImage(input, cachedPng);
      } else {
        console.log(`→ Cache hit ${file}`);
      }

      await icongen(cachedPng, outDir, {
        report: false,
        ico: {
          name,
          sizes: [16, 24, 32, 48, 64, 128, 256],
        },
      });

      console.log(`OK  ${name}.ico generated`);
    } catch (err) {
      console.error(`ERR ${name}:`, err.message);
      process.exitCode = 1;
    }
  }
}

main();
