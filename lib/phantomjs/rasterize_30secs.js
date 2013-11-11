// usage:
// phantomjs public/rasterize.js http://localhost:3000/printable/1/2 dash_1_2.pdf "2200px*2100px"
// phantomjs public/rasterize.js http://localhost:3000/gchartwrapper_tojson.html gc.pdf "Letter"
// phantomjs public/rasterize.js http://localhost:3000/printable/1/2 gc.pdf "Letter"
// phantomjs public/rasterize.js http://localhost:3000/gchartwrapper_tojson.html gc.png
console.log("Phantomjs . . .");

var page = require('webpage').create(),
    system = require('system'),
    address, output, size;

var fs = require("fs"); 

if (system.args.length < 3 || system.args.length > 5) {
    console.log('Usage: rasterize.js URL filename [paperwidth*paperheight|paperformat] [zoom]');
    console.log('  paper (pdf output) examples: "5in*7.5in", "10cm*20cm", "A4", "Letter"');
    phantom.exit(1);
} else {
    address = system.args[1];
		console.log("  address=", address);
    output = system.args[2];
		console.log("  output=", output);
    page.viewportSize = { width: 1800, height: 760 };
    if (system.args.length > 3 && system.args[2].substr(-4) === ".pdf") {
				console.log("  size=", system.args[3]);
        size = system.args[3].split('*');
        page.paperSize = size.length === 2 ? { width: size[0], height: size[1], margin: '0px' }
                                           : { format: system.args[3], orientation: 'portrait', margin: '0px', border: '0px' };
    }
    if (system.args.length > 4) {
        page.zoomFactor = system.args[4];
    }
    page.open(address, function (status) {
				console.log("  in: page.open:");
				// cls: phantomjs does not return http codes like 422/500 ... just success/failed
        if (status !== 'success') {
            console.log('    URL(address) not found!');
				    // fs.write("/dev/stdout", "URL not found!\n", "w");
            phantom.exit();
        } else {
						console.log("    page.open status=", status);
						console.log("    waiting for page to fully render via setTimeout...");
            window.setTimeout(function () {
               	page.render(output);
 								console.log(". . . phantom.exit ... done!");
                phantom.exit();
            }, 30000); // x sec.s to give google time to render charts, might need longer?
        }
    });
}