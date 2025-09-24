// Convert files from 
// https://drububu.com/miscellaneous/voxelizer/?out=txt

const fs = require('fs');
const path = require('path');

const readFile = (filePath) => {
    try {
        const data = fs.readFileSync(filePath, 'utf-8');
        return data.split('\n').filter(Boolean);
    } catch (error) {
        console.error('Error reading file:', error);
        return [];
    }
};

const parseLine = (line) => {
    const [x, y, z] = line.split(',').map(Number);
    return { x, y, z };
};

const groupDataByY = (lines) => {
    const groupedData = {};
    lines.forEach((line) => {
        const { x, y, z } = parseLine(line);
        if (!groupedData[y]) {
            groupedData[y] = [];
        }
        groupedData[y].push({ x, y, z });
    });
    return groupedData;
};

const saveGroupedData = (folderName, groupedData, offsetX = 0, offsetZ = 0) => {
    Object.keys(groupedData).forEach((y) => {
        const filePath = path.join(__dirname, 'schematics', folderName, `layer_${y}.txt`);

        if (!fs.existsSync(path.dirname(filePath))){
            fs.mkdirSync(path.dirname(filePath), { recursive: true });
        }

        const content = groupedData[y]
            .map(point => `${point.x - offsetX} ${point.y} ${point.z - offsetZ} any`)
            .join('\n');

        fs.writeFileSync(filePath, content);
        console.log(`Saved data to ${filePath}`);
    });
};

// const main = async () => { 
//     const args = process.argv.slice(2);
//     if (args.length === 0) {
//         console.error('Please provide a file path as an argument.');
//         process.exit(1);
//     }

//     const filePath = args[0];

//     const lines = readFile(filePath);
//     const groupedData = groupDataByY(lines);
    
//     const saveFolderName = path.basename(filePath).replace(/\..*$/,'')

//     if (Object.keys(groupedData).length > 0) {
//         saveGroupedData(saveFolderName,groupedData);
//     }
// };

module.exports = { groupDataByY, saveGroupedData }