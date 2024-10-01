const express = require('express');
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static('public'));

// List all schematics
app.get('/api/schematics', (req, res) => {
    const schematicsDir = path.join(__dirname, 'schematics');
    
    fs.readdir(schematicsDir, (err, files) => {
        if (err) {
            return res.status(500).json({ error: 'Unable to retrieve schematics' });
        }
        
        // Filter for directories only
        const directories = files.filter(file => fs.statSync(path.join(schematicsDir, file)).isDirectory());
        res.json(directories);
    });
});

// Endpoint to get the contents of all layer files
app.get('/api/schematics/:baseName', (req, res) => {
    const baseName = req.params.baseName;
    const basePath = path.join(__dirname, 'schematics', baseName);

    // Check if directory exists
    if (!fs.existsSync(basePath)) {
        return res.status(404).json({ error: 'Schematic not found' });
    }

    fs.readdir(basePath, (err, files) => {
        if (err) {
            return res.status(500).json({ error: 'Unable to read schematic files' });
        }

        const layerFiles = files.filter(file => file.startsWith('layer_') && file.endsWith('.txt'));
        const results = [];

        layerFiles.forEach(file => {
            const filePath = path.join(basePath, file);
            const content = fs.readFileSync(filePath, 'utf8');

            const lines = content.split('\n').filter(line => line.trim() !== '');
            lines.forEach(line => {
                const parts = line.split(' ');
                if (parts.length === 4) {
                    results.push({
                        x: parseInt(parts[0], 10),
                        y: parseInt(parts[1], 10),
                        z: parseInt(parts[2], 10),
                        block: parts[3]
                    });
                }
            });
        });

        res.json(results);
    });
});

app.delete('/api/schematics/:baseName', (req, res) => {
    const baseName = req.params.baseName;
    const basePath = path.join(__dirname, 'schematics', baseName);

    if (!fs.existsSync(basePath)) {
        return res.status(404).json({ error: 'Schematic not found' });
    }

    // Recursively delete the directory
    fs.rmdir(basePath, { recursive: true }, (err) => {
        if (err) {
            return res.status(500).json({ error: 'Unable to delete schematic' });
        }
        res.json({ message: 'Schematic deleted successfully!' });
    });
});

// Endpoint to get options for a schematic
app.get('/api/schematics/:baseName/options', (req, res) => {
    const baseName = req.params.baseName;
    const optionsPath = path.join(__dirname, 'schematics', baseName, 'options.json');

    if (!fs.existsSync(optionsPath)) {
        return res.status(404).json({ error: 'Options file not found' });
    }

    const options = JSON.parse(fs.readFileSync(optionsPath, 'utf8'));
    res.json(options);
});

function generateSvg() {
    return `
         <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" version="1.0">
        <path d="M 110 165 L 48 165 L 78 180 L 120 180 L 153.4 122.6 L 144.113 106.505 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 48.7083 141.1603 L 17.7083 87.4667 L 19.718 120.9474 L 40.718 157.3205 L 107.1278 157.5458 L 116.423 141.4555 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 38.7083 76.1603 L 69.7083 22.4667 L 41.718 40.9474 L 20.718 77.3205 L 53.7278 134.9458 L 72.31 134.9505 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 90 35 L 152 35 L 122 20 L 80 20 L 46.6 77.4 L 55.887 93.495 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 151.2917 58.8397 L 182.2917 112.5333 L 180.282 79.0526 L 159.282 42.6795 L 92.8722 42.4542 L 83.577 58.5445 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        <path d="M 161.2917 123.8397 L 130.2917 177.5333 L 158.282 159.0526 L 179.282 122.6795 L 146.2722 65.0542 L 127.69 65.0495 Z" fill="none" stroke="#000000" stroke-width="1.2"/>
        </svg>
    `;
}

function lerp(start, end, val) {
    return start + (end - start) * val;
}

app.post('/api/generate', async (req, res) => {
    let { baseHeight, rotation, sizeX, sizeY, baseName, svg } = req.body;

    baseHeight = parseInt(baseHeight)
    rotation = parseInt(rotation)
    sizeX = parseInt(sizeX)
    sizeY = parseInt(sizeY)

    if (!baseName) {
        return res.status(400).json({ error: 'Base name is required.' });
    }

    const schematicsDir = path.join(__dirname, 'schematics');
    if (!fs.existsSync(schematicsDir)) {
        fs.mkdirSync(schematicsDir);
    }
    
    const basePath = path.join(schematicsDir, baseName);
    if (!fs.existsSync(basePath)) {
        fs.mkdirSync(basePath);
    }

    fs.writeFileSync(path.join(basePath, 'options.json'), JSON.stringify(req.body, null, 2));

    for (let layer = 0; layer < baseHeight; layer++) {
        const currentRotation = lerp(0, rotation, layer / baseHeight);

        const image = sharp(Buffer.from(svg))
            .resize(sizeX, sizeY)
            .rotate(currentRotation, {background: { r: 0, g: 0, b: 0, alpha: 0 }})
            .resize({
                width: sizeX,
                height: sizeY,
                withoutReduction: true,
                withoutEnlargement: true,
                background: { r: 0, g: 0, b: 0, alpha: 0 },
            })
            .threshold()

        // await image.toFile(`${basePath}/base_${layer}.png`);

        const { data, info } = await image.raw().toBuffer({ resolveWithObject: true });
        const { width, height, channels } = info;

        let txtOut = '';
        const shiftX = sizeX / 2;
        const shiftY = sizeY / 2;

        for (let y = 0; y < height; y++) {
            for (let x = 0; x < width; x++) {
                const index = (y * width + x) * channels;
                const a = channels === 4 ? data[index + 3] : 255;

                if (a !== 0) {
                    txtOut += `${x - shiftX} ${layer} ${y - shiftY} any\n`;
                }
            }
        }

        fs.writeFileSync(`${basePath}/layer_${layer}.txt`, txtOut);
    }

    res.json({ message: 'SVG files generated successfully!' });
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
