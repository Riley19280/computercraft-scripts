let distance  = function( x, y, ratio ) {
    return (Math.pow(y * ratio, 2)) + Math.pow(x, 2);
}
let filled    = function( x, y, radius, ratio ) {
    return distance(x, y, ratio) <= radius * radius;
}

let fatfilled = function( x, y, radius, ratio ) {
    return filled(x, y, radius, ratio) && !(
           filled(x + 1, y, radius, ratio) &&
           filled(x - 1, y, radius, ratio) &&
           filled(x, y + 1, radius, ratio) &&
           filled(x, y - 1, radius, ratio) &&
           filled(x + 1, y + 1, radius, ratio) &&
           filled(x + 1, y - 1, radius, ratio) &&
           filled(x - 1, y - 1, radius, ratio) &&
           filled(x - 1, y + 1, radius, ratio)
        );
};

points = []
let thickness = 'thin' // thick, thin, filled

var radiusX = 2.5
var radiusY = 2.5

var ratio = radiusX / radiusY;

var maxblocks_x, maxblocks_y;

if( (radiusX * 2) % 2 == 0 ) {
    maxblocks_x = Math.ceil(radiusX - .5) * 2 + 1;
} else {
    maxblocks_x = Math.ceil(radiusX) * 2;
}

if( (radiusY * 2) % 2 == 0 ) {
    maxblocks_y = Math.ceil(radiusY - .5) * 2 + 1;
} else {
    maxblocks_y = Math.ceil(radiusY) * 2;
}

for( var y = -maxblocks_y / 2 + 1; y <= maxblocks_y / 2 - 1; y++ ) {
    for( var x = -maxblocks_x / 2 + 1; x <= maxblocks_x / 2 - 1; x++ ) {
        var xfilled;

        if( thickness == 'thick' ) {
            xfilled = fatfilled(x, y, radiusX, ratio);
        } else if( thickness == 'thin' ) {
            xfilled = fatfilled(x, y, radiusX, ratio) && !(fatfilled(x + (x > 0 ? 1 : -1), y, radiusX, ratio) && fatfilled(x, y + (y > 0 ? 1 : -1), radiusX, ratio));

        } else if( thickness == 'filled' ) {
            xfilled = filled(x, y, radiusX, ratio);
        } else {
            console.log('option not supported')
        }

        if(xfilled)
        points.push({x:x,y:y})
    }
}

res = points.reduce((a,x) => 
    a + `(${x.x}, ${x.y}),`
, '')

console.log(res)