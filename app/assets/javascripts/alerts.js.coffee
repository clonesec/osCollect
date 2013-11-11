jQuery ->

	# for index page:
	jQuery ->
		$(".share-alert").click (event) ->
			okOrCancel = confirm "Sharing this alert will make it available to all users.\n\nAlso, this may be shared with users on other osCollect instances, so be careful that sensitive information is not exposed in the selection criteria, such as passwords.\n\nAre you sure?"
			if okOrCancel == false
				event.preventDefault()

	$("#alertActive").click ->
		activeState = ((if $("#alertActive .b1").is(".btn-success") then 0 else 1))
		$("#alert_active").val activeState
		$("#alertActive").attr "data-state", activeState
		$("#alertActive .b1").toggleClass "btn-success"
		$("#alertActive .b0").toggleClass "btn-danger"

	$("#alertLogsInEmail").click ->
		activeState = ((if $("#alertLogsInEmail .b3").is(".btn-success") then 0 else 1))
		$("#alert_logs_in_email").val activeState
		$("#alertLogsInEmail").attr "data-state", activeState
		$("#alertLogsInEmail .b3").toggleClass "btn-success"
		$("#alertLogsInEmail .b2").toggleClass "btn-danger"
		
