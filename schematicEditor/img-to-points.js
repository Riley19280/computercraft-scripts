const sharp = require('sharp');
const fs = require('fs');
const path = require('path')

const sizeX = 200
const sizeY = 200

const shiftX = sizeX / 2;
const shiftY = sizeY / 2;

(async () => {
    const dir = path.resolve(process.argv[2])
    const files = fs.readdirSync(path.resolve(process.argv[2]))

    for(const file of files) {
        if (file.endsWith('.txt') || file.endsWith('.json'))
            continue

        const outputPath = `${dir}/${file.replace(/\.[^/.]+$/, '.txt')}`

        const layer = outputPath.match(/layer_(\d+)\./)[1];
    
        const { data, info } = await sharp(`${dir}/${file}`)
        .resize(sizeX, sizeY)
        .resize({
            width: sizeX,
            height: sizeY,
            withoutReduction: true,
            withoutEnlargement: true,
            background: { r: 0, g: 0, b: 0, alpha: 0 },
        })
        .threshold()
        .ensureAlpha()
        .raw()          
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
                    txtOut += `${x - shiftX} ${layer} ${y - shiftY} ${block}\n`
                }
            }
        }
        
        fs.writeFile(outputPath, txtOut, () => {})

    }

    const options = {
        baseHeight: height,
        rotation: 0,
        sizeX: sizeX,
        sizeY: sizeY,
        baseName: "unknown",
    }

    fs.writeFile(`${dir}/options.json`, JSON.stringify(opts, null, 2), () => {})
})()
