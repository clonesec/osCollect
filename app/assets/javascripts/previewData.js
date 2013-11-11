var myExampleData = {};

//pie Chart sample data and options
myExampleData.pieChartData = [
{label : '71.191.82.76', data : [[0, 156205]]},
{label : '127.0.0.1', data : [[0, 38815]]},
{label : '173.236.192.213', data : [[0, 644]]},
{label : '50.116.50.120', data : [[0, 198]]}
];
// myExampleData.pieChartData = [
// 	{
// 		data : [[0, 4]],
// 		label : "Comedy",
// 		pie : {
// 			explode : 3 // cls: pulls out a slice
// 		}
// 	},
// 	{
// 		data : [[0, 3]],
// 		label : "Action"
// 	},
// 	{
// 		data : [[0, 1.03]],
// 		label : "Romance"
// 	},
// 	{
// 		data : [[0, 3.5]],
// 		label : "Drama"
// 	}
// ];

myExampleData.pieChartOptions = {
  colors: ["#008080","#FF6347","#6495ED","#FF8C00","#008000","#0000FF","#A52A2A","FF0000"],
	pie3D: false,
	shadowSize: 0,
	HtmlText : false,
	grid : {
		verticalLines : false,
		horizontalLines : false
	},
	xaxis : {
		showLabels : false
	},
	yaxis : {
		showLabels : false
	},
	pie : {
		show : true,
		shadowSize : 0,
		fillOpacity : 1, // solid fill no gradient
		explode : 1 //6 cls: spaces slices apart
	},
	mouse : {
		track : true
	},
	legend : {
		position : "se",
		backgroundColor : "#FFFFFF",
		labelBoxBorderColor: '#ffffff' // cls: hides the grayish border
	}
};
//pie chart sample data ends here

//bar Chart sample data and options
myExampleData.constructBubbleChartData = function() {
	var d1 = [];
	var d2 = []
	var point
	var i;

	for ( i = 0; i < 10; i++) {
		point = [i, Math.ceil(Math.random() * 10), Math.ceil(Math.random() * 10)];
		d1.push(point);

		point = [i, Math.ceil(Math.random() * 10), Math.ceil(Math.random() * 10)];
		d2.push(point);
	}

	return [d1, d2];
};
myExampleData.bubbleChartData = myExampleData.constructBubbleChartData();

myExampleData.bubbleChartOptions = {
  colors: ["#008080","#FF6347","#6495ED","#FF8C00","#008000","#0000FF","#A52A2A","FF0000"],
	bubbles : {
		show : true,
		baseRadius : 5
	},
	xaxis : {
		min : -4,
		max : 14
	},
	yaxis : {
		min : -4,
		max : 14
	},
	mouse : {
		track : true,
		relative : true
	}
};
//bar chart sample data ends here

//bar Chart sample data and options
myExampleData.constructBarChartData = function() {
	var d1 = [];
	var d2 = [];
	var d3 = [];
	var point;
	var i;
	for ( i = 0; i < 24; i++) {
		point = [Math.ceil(Math.random() * 10), i];
		d1.push(point);
		point = [Math.ceil(Math.random() * 10), i + 0.5];
		d2.push(point);
		point = [Math.ceil(Math.random() * 10), i + 1.5];
		d3.push(point);
	}
	return [d1, d2, d3];
};
myExampleData.barChartData = myExampleData.constructBarChartData();

myExampleData.barChartOptions = {
  colors: ["#008080","#FF6347","#6495ED","#FF8C00","#008000","#0000FF","#A52A2A","FF0000"],
	bars : {
		show : true,
		horizontal : true,
		shadowSize : 0,
		barWidth : 0.5
	},
	mouse : {
		track : true,
		relative : true
	},
	yaxis : {
		min : 0,
		autoscaleMargin : 1
	}
};
//bar chart sample data ends here

//line Chart sample data and options
myExampleData.constructLineChartData = function() {
	var d1 = [[0, 3], [4, 8], [8, 5], [9, 13]];
	var d2 = [];
	var i;
	for ( i = 0; i < 14; i += 0.5) {
		d2.push([i, Math.sin(i)]);
	}
	return [d1, d2];
};
myExampleData.lineChartData = myExampleData.constructLineChartData();

myExampleData.lineChartOptions = {
  colors: ["#008080","#FF6347","#6495ED","#FF8C00","#008000","#0000FF","#A52A2A","FF0000"],
	xaxis : {
		minorTickFreq : 4
	},
	grid : {
		minorVerticalLines : true
	},
	selection : {
		mode : "x",
		fps : 30
	}
};
//line chart sample data ends here

//table Widget sample data and options
myExampleData.tableWidgetData = {
	"aaData" : [
	["Muffin", "IE4", "Win 95"], 
	["Trident", "IE5", "Win 95"], 
	["Trident", "IE6", "Win 95"], 
	["Puffin", "IE7", "Win 98"],
	["Trident", "IE8", "Win XP"],
	["Trident", "Chrome1", "OSX"], 
	["Trident", "Chrome2", "OSX"]
	],

	"aoColumns" : [{
		"sTitle" : "Engine"
	}, {
		"sTitle" : "Browser"
	}, {
		"sTitle" : "Platform"
	}]
};
//table widget sample data ends here

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
