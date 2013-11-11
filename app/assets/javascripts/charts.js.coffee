jQuery ->

	$('#chart_name').focus()

	$("#chart-help").modal show: false

	jQuery ->
		$(".share-chart").click (event) ->
			okOrCancel = confirm "Sharing this chart will make it available to all users.\n\nAlso, this may be shared with users on other osCollect instances, so be careful that sensitive information is not exposed in the selection criteria, such as passwords.\n\nAre you sure?"
			if okOrCancel == false
				event.preventDefault()
