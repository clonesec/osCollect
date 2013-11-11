jQuery ->
	$("#userEmailWeeklyLogCounts").click ->
		activeState = ((if $("#userEmailWeeklyLogCounts .b1").is(".btn-success") then 0 else 1))
		$("#user_send_weekly_log_counts").val activeState
		$("#userEmailWeeklyLogCounts").attr "data-state", activeState
		$("#userEmailWeeklyLogCounts .b1").toggleClass "btn-success"
		$("#userEmailWeeklyLogCounts .b0").toggleClass "btn-danger"
