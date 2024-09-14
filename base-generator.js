const sharp = require('sharp');
const fs = require('fs');

// https://yqnn.github.io/svg-path-editor/
function generateSvg() {
    const numPaths = 6;
    const pathData = "M 110 165 L 48 165 L 78 180 H 120 L 154 123 L 146 108 Z";
    
    // Create SVG markup
    let svgMarkup = `
        <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" version="1.0">
        <path d="M 110 165 L 48 165 L 78 180 L 120 180 L 153.4 122.6 L 144.113 106.505 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 48.7083 141.1603 L 17.7083 87.4667 L 19.718 120.9474 L 40.718 157.3205 L 107.1278 157.5458 L 116.423 141.4555 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 38.7083 76.1603 L 69.7083 22.4667 L 41.718 40.9474 L 20.718 77.3205 L 53.7278 134.9458 L 72.31 134.9505 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 90 35 L 152 35 L 122 20 L 80 20 L 46.6 77.4 L 55.887 93.495 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 151.2917 58.8397 L 182.2917 112.5333 L 180.282 79.0526 L 159.282 42.6795 L 92.8722 42.4542 L 83.577 58.5445 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 161.2917 123.8397 L 130.2917 177.5333 L 158.282 159.0526 L 179.282 122.6795 L 146.2722 65.0542 L 127.69 65.0495 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        </svg>
    `;
    
    return svgMarkup
}


function lerp(start, end, val) {
    return start + (end - start) * val;
}

(async () => {
    
const baseHeight = 30
const rotation = 60

const svg = generateSvg()

for(let layer = 0; layer < baseHeight; layer++) {
    const currentRotation = lerp(0, rotation, layer / baseHeight)

    const image = sharp(Buffer.from(svg))
    .resize(200, 200)
    .rotate(currentRotation, {background: { r: 0, g: 0, b: 0, alpha: 0 }})
    .resize({
        width: 200,
        height: 200,
        withoutReduction: true,
        withoutEnlargement: true,
        background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .threshold()


    await image.toFile(`base/base_${layer}.png`, (err, info) => { 

    });  


    // Read the image and convert to raw pixel data
    const { data, info } = await image
    .ensureAlpha()   // Ensure the image has an alpha channel
    .raw()           // Get raw pixel data
    .toBuffer({ resolveWithObject: true });

    const { width, height, channels } = info;

    let txtOut = ''

    // Iterate over each pixel
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            const index = (y * width + x) * channels;
            const r = data[index];
            const g = data[index + 1];
            const b = data[index + 2];
            const a = channels === 4 ? data[index + 3] : 255; // Default alpha to 255 if not present


            const isVisible = channels === 4 ? (a != 0) : (r + g + b) === 0

            const block = 'any'

            if(isVisible) {
                txtOut += `${x} ${layer} ${y} ${block}\n`
            }
        }
    }
    
    fs.writeFile(`base/layer_${layer}.txt`, txtOut, () => {})
}
})()