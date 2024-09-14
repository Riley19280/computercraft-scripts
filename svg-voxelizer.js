const sharp = require('sharp');

let inputBuffer = Buffer.from(
    '<svg xmlns="http://www.w3.org/2000/svg" width="266.67" height="266.67" version="1.0" viewBox="0 0 200 200">\
<path d="M 62.1 45.5 L 58.3 60.6 L 119.8 32 L 171.1 55.9 L 153.5 33.6 L 119.5 17.4 Z" />\
<path d="M 106.6 43.9 L 166.2 72.9 L 178 128 L 186.2 101.1 L 177.6 64.3 L 119.7 37 Z" />\
<path d="M 149 70.4 L 163.8 135.8 L 128.4 180.2 L 153.9 168.5 L 176.7 139.4 L 162.7 76.4 Z" />\
<path d="M 113.5 172.9 L 56.3 173.7 L 79.4 184 H 118.8 L 158.9 134.3 L 155.5 119.6 Z" />\
<path d="M 16 111.3 L 22 139 L 45.5 168.8 L 110.9 169 L 119.9 155.5 L 52.2 155.5 L 16 111.3Z" />\
<path d="M 22 63.7 L 14 99.7 L 54.2 151 H 70.1 L 27.8 95.8 S 39.7 42.4 39.6 42.3 Z" />\
<path d="M 46.5 33.7 L 32.6 94.2 L 42.3 108.3 L 57.4 42.7 L 108.5 18.1 H 79.5 Z" />\
</svg>'
  );


  sharp(inputBuffer)
  .resize(300, 300)
  .threshold()
  .toFile('output.png', (err, info) => { 
    
   });