var page = require('webpage').create(),
    system = require('system'),
	  render_time = system.args[4] || 20000,
	  margin = system.args[5] || '0cm',
	  orientation = system.args[6] || 'portrait',
	  time_out = system.args[7] || 60000,
    address,
		output,
		size;

console.log("render_time: " + render_time + " ms");

if (system.args.length < 3 || system.args.length > 8) {
    phantom.exit(1);
} else {
    address = system.args[1];
    output = system.args[2];
    page.viewportSize = { width: 1800, height: 760 };
    if (system.args.length > 3 && system.args[2].substr(-4) === ".pdf") {
        size = system.args[3].split('*');
        page.paperSize = size.length === 2 ? { width: size[0], height: size[1], margin: '0px' }
                                           : { format: system.args[3], orientation: 'portrait', margin: '0px', border: '0px' };
    }
    page.open(address, function (status) {
				// cls: phantomjs does not return http codes like 422/500 ... just success/failed
        if (status !== 'success') {
						// page.close();
            phantom.exit(1);
        } else {
            window.setTimeout(function () {
               	page.render(output);
								// page.close();
                phantom.exit();
            }, render_time); // x sec.s to give google time to render charts, might need longer?
        }
    });
}