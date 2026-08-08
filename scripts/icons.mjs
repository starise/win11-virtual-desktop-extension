import fs from "fs";
import path from "path";
import icongen from "icon-gen";

const srcDir = path.resolve("images");
const outDir = path.resolve("icons");

async function main() {
  if (!fs.existsSync(srcDir)) {
    throw new Error(`Missing directory: ${srcDir}`);
  }

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

    try {
      await icongen(input, outDir, {
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
