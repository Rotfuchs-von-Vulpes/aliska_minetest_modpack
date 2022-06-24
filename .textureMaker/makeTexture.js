import fs from 'fs';
import png from 'fast-png';

function isUsed(colors, colorForUse) {
	for (let color of colors) {
		if (arrayIsEqual(color, colorForUse)) return true;
	}

	return false;
}

function rgbToHex({ r, g, b }) {
	r = r.toString(16);
	g = g.toString(16);
	b = b.toString(16);

	if (r.length < 2) r = '0' + r;
	if (g.length < 2) g = '0' + g;
	if (b.length < 2) b = '0' + b;

	return '#' + r + g + b;
}

function hexToRgb(hex, a) {
	let r = parseInt(hex.slice(1, 3), 16);
	let g = parseInt(hex.slice(3, 5), 16);
	let b = parseInt(hex.slice(5, 7), 16);

	return [r, g, b, a];
}

function filterPallete(data) {
	let color = [];
	let colors = [];
	let lastColors = [[0, 0, 0, 0]];

	for (let n of data) {
		color.push(n);

		if (color.length >= 4) {
			let temp = isUsed(lastColors, color);

			if (!temp) {
				colors.push(...color);
				lastColors.unshift([...color]);
			}
			color = [];
		}
	}

	return colors;
}

function createPalette(data) {
	let color = [];
	let palette = [];

	for (let n of data) {
		color.push(n);

		if (color.length >= 4) {
			palette.push({ r: color[0], g: color[1], b: color[2], a: color[3] });
			color = [];
		}
	}

	return palette;
}

function arrayIsEqual(arr1, arr2) {
	for (let i in arr1) {
		if (arr1[i] != arr2[i]) return false;
	}

	return true;
}

function createItem(data, name) {
	return { data, name }
}

function readColors(metals) {
	let colors = {};

	for (let metal of metals) {
		let data = fs.readFileSync('./textures/palettes/' + metal + '.png');
		let image = png.decode(data).data;

		let palette = [];
		let colorStack = [];

		for (let n of image) {
			colorStack.push(n);

			if (colorStack.length >= 4) {
				palette.push([ ...colorStack ]);
				colorStack = [];
			}
		}

		colors[metal] = palette;
	}

	return colors;
}

function readColorsInJSON(path) {
	return JSON.parse(fs.readFileSync(path)).colors;
}

function writeColorsJson(path, colors) {
	fs.writeFileSync(path, JSON.stringify({ colors }));
}

function searchColor(any, color) {
	for (let i in any) {
		if (arrayIsEqual(any[i], color)) {
			return i;
		}
	}

	return -1;
}

function replaceAnyColors(inputBuffer, metal, any) {
	let colorStack = [];
	let imageBuffer = [];

	for (let n of inputBuffer) {
		colorStack.push(n);

		if (colorStack.length >= 4) {
			let index = searchColor(any, colorStack);

			if (index < 0) {
				imageBuffer.push(...colorStack);
			} else {
				imageBuffer.push(...metal[index]);
			}

			colorStack = [];
		}
	}

	return imageBuffer;
}

function replaceColors(inputBuffer, metal, any) {
	let colorStack = [];
	let imageBuffer = [];

	for (let n of inputBuffer) {
		colorStack.push(n);

		if (colorStack.length >= 4) {
			imageBuffer.push(
				...arrayIsEqual(colorStack, [0, 0, 0, 0])
					? [0, 0, 0, 0]
					: metal[searchColor(any, colorStack)]
			);
			colorStack = [];
		}
	}

	return imageBuffer;
}

function readImage(path) {
	return png.decode(fs.readFileSync(path));
}

function writeImage(path, imageBuffer, width, height) {
	fs.writeFileSync(path, png.encode({width, height, data: imageBuffer}));
}

function makeItemTextures(metals, items, colors) {
	for (let metal of metals) {
		for (let item of items) {
			let imageBuffer = replaceAnyColors(item.data, colors[metal], colors['any']);
		
			writeImage(`./textures/output/aliska_${metal}_${item.name}.png`, imageBuffer, 16, 16);
	
			console.log(`${metal} ${item.name} saved.`);
		}
	}
}

function makeColorsJSON(metals) {
	let colors = readColorsInJSON('./metals.json');
	let newColors = readColors(metals);

	for (let metal in newColors) {
		colors[metal] = newColors[metal];
	}

	writeColorsJson('./metals.json', colors);
}


function contrastOne(byte) {
	let a = byte + 128;

	return 143*a / (Math.sqrt(a*a - 4096)) + 128
}

function contrast(color) {
	color[0] = contrastOne(color[0]);
	color[1] = contrastOne(color[1]);
	color[2] = contrastOne(color[2]);

	return color
}

function dataForEach(data, func) {
	let colorStack = [];
	let imageBuffer = [];

	for (let n of data) {
		colorStack.push(n);

		if (colorStack.length >= 4) {
			colorStack = func(colorStack)
			imageBuffer.push(...colorStack);
			colorStack = [];
		}
	}

	return imageBuffer
}

function makeContrast(path, outputPath) {
	let data = readImage(path);
	let imageBuffer = dataForEach(data.data, (stack) => {
		stack = contrast(stack);

		return stack;
	})

	writeImage(outputPath, imageBuffer, data.width, data.height)
}

function makeTransparency(path, alpha, outputPath) {
	let data = readImage(path);
	let imageBuffer = dataForEach(data.data, (stack) => {
		stack[3] = alpha;

		return stack;
	})

	writeImage(outputPath, imageBuffer, data.width, data.height)
}

// code texturing here

// const colors = readColorsInJSON('./metals.json');
// const metals = [
// 	'silver',
// 	'bronze',
// 	'copper',
// 	'brass',
// 	'steel',
// 	'gold',
// 	'lead',
// 	'zinc',
// 	'iron',
// 	'tin',
// 	'aluminium',
// 	'nickel',
// 	'titanium',
// 	'electrum',
// 	'monel',
// 	'nitinol',
// 	'invar',
// ];
// let items = [
// 	// createItem(readImage('./textures/aliska_raw_any_ore.png'), 'ore'),
// 	// createItem(readImage('./textures/items/aliska_any_gear.png'), 'gear'),
// 	createItem(readImage('./textures/items/aliska_any_block.png'), 'block'),
// 	// createItem(readImage('./textures/items/aliska_any_ingot.png'), 'ingot'),
// 	// createItem(readImage('./textures/items/aliska_any_powder.png'), 'powder'),
// 	// createItem(readImage('./textures/items/aliska_any_tiny_powder.png'), 'tiny_powder'),
// 	// createItem(readImage('./textures/items/aliska_any_nugget.png'), 'nugget'),
// 	// createItem(readImage('./textures/items/aliska_any_sword.png'), 'sword'),
// 	// createItem(readImage('./textures/items/aliska_any_pickaxe.png'), 'pickaxe'),
// 	// createItem(readImage('./textures/items/aliska_any_shovel.png'), 'shovel'),
// 	// createItem(readImage('./textures/items/aliska_any_hoe.png'), 'hoe'),
// 	// createItem(readImage('./textures/items/aliska_any_axe.png'), 'axe'),
// 	// createItem(readImage('./textures/items/aliska_any_plate.png'), 'plate'),
// ]

// makeColorsJSON(metals);
// makeItemTextures(metals, items, colors);

makeTransparency(
	'./textures/items/aliska_polished2.png',
	128,
	'./textures/output/aliska_polished2.png'
);

console.log('feito.');
