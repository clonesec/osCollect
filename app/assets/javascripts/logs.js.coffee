jQuery ->
	$('#facet_date_table').dataTable

	$('#facet_table').dataTable
		sDom: "<'row'<'span3'l><'span3'T><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
		oTableTools:
		  sSwfPath: "/swfs/copy_csv_xls_pdf.swf"
		  aButtons: [ "print", "copy", "csv", "xls",
		    sExtends: "pdf"
		    sPdfOrientation: "landscape"
		    sTitle: "osCollect Logs"
		    # sPdfMessage: "osCollect Logs"
		  ]
		sPaginationType: "bootstrap"
		iDisplayLength: 25
		aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
		bProcessing: false
		bSort: false

	$('#log-totals-by-host').dataTable
		sDom: "<'row'<'span3'l><'span3'T><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
		oTableTools:
		  sSwfPath: "/swfs/copy_csv_xls_pdf.swf"
		  aButtons: [ "print", "copy", "csv", "xls",
		    sExtends: "pdf"
		    sPdfOrientation: "landscape"
		    sTitle: "osCollect Logs"
		    # sPdfMessage: "Logs"
		  ]
		sPaginationType: "bootstrap"
		iDisplayLength: 25
		aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
		bProcessing: true
		bSort: false

