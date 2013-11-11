jQuery ->

  $('#charts, #searches').nestedFields()

	# for index page:
	jQuery ->
		$(".share-report").click (event) ->
			okOrCancel = confirm "Sharing this report will make it available to all users.\n\nAlso, this may be shared with users on other osCollect instances, so be careful that sensitive information is not exposed in the selection criteria, such as passwords.\n\nAre you sure?"
			if okOrCancel == false
				event.preventDefault()
