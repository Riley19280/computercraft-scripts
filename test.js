center = {x: 0, y:0}
radius = 30
let top    = Math.ceil(center.y - radius)
let bottom = Math.floor(center.y + radius);

let left  = Math.ceil(center.x - radius)
let right = Math.floor(center.x + radius);


points = []

for (let y = top; y <= bottom; y++) {
    let dy = y - center.y

    let dx = parseInt(Math.floor(Math.sqrt(radius * radius - dy * dy)));

    let left  = center.x - dx;
    let right = center.x + dx;

    points.push({x: right, y: y})
    points.push({x: left, y: y})
}

for (let x = left; x <= right; x++) {
    let dx = x - center.x

    let dy = parseInt(Math.floor(Math.sqrt(radius * radius - dx * dx)));

    let top    = center.y - dy;
    let bottom = center.y + dy;

    points.push({x: x, y: top})
    points.push({x: x, y: bottom})
}


res = points.reduce((a,x) => 
    a + `(${x.x}, ${x.y}),`
, '')

console.log(res)