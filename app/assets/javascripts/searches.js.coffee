jQuery ->

	# for list page:
	jQuery ->
		# $(".share-search").click (event) ->
		$(document).on "click", "td.share-search", ->
			okOrCancel = confirm "Sharing this search will make it available to all users.\n\nAlso, this may be shared with users on other osCollect instances, so be careful that sensitive information is not exposed in the selection criteria, such as passwords.\n\nAre you sure?"
			if okOrCancel == false
				event.preventDefault()

  $('.datepicker').datepicker()

  # $("#search_sources").select2
  #   placeholder: "match any of the selected log sources"
  #   allowClear: true

  $('#search form').nestedFields()

  # cls: this is old jquery:
  # $(".data_source_list").live "change", (->
	$(document).on "change", "select.data_source_list", (->
    beforeIndex = "search_search_fields_attributes_"
    afterIndex = "_data_source_id"
    afterIndexRemoved = $(this).attr("id").replace(afterIndex, "")
    indexPart = afterIndexRemoved.replace(/\D/g, "")
    afterIndex = "_data_source_field_id"
    $('#' + beforeIndex + indexPart + afterIndex).empty()
    selectedValue = $(this).val()
    if selectedValue == ''
      options = [ "<option value=\"\">first, select a source</option>" ]
      $('#' + beforeIndex + indexPart + afterIndex).html options.join("")
      return
    data = "id="+selectedValue
    $.getJSON "/data_fields?", data, (json) ->
      ids_names_for_fields = json.fields
      options = []
      $.each ids_names_for_fields, (i, item) ->
        options.push "<option value=\"" + ids_names_for_fields[i].id + "\">" + ids_names_for_fields[i].name + "</option>"
      # console.log("options="+options)
      # console.log("beforeIndex="+beforeIndex)
      # console.log("indexPart="+indexPart)
      # console.log("afterIndex="+afterIndex)
      $('#' + beforeIndex + indexPart + afterIndex).html(options.join(""))
  )

  $('#search_query').focus()

  $("#search-help").modal show: false

  searchResultsPageSize = 10 if typeof searchResultsPageSize is "undefined"

  $('#logs').dataTable
    sDom: "<'row'<'span3'l><'span3'T><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    oTableTools:
      sSwfPath: "/swfs/copy_csv_xls_pdf.swf"
      aButtons: [ "print", "copy", "csv", "xls",
        sExtends: "pdf"
        sPdfOrientation: "landscape"
        sTitle: "osCollect Report"
        sPdfMessage: "Search results"
      ]
    # bJQueryUI: true
    # sPaginationType: "full_numbers"
    sPaginationType: "bootstrap"
    iDisplayLength: searchResultsPageSize
    aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
    bProcessing: true
    aaSorting: [[0,'desc']]
    aoColumns: [ { "bSearchable": false }, null ]
    oLanguage:
      sProcessing: "Standby . . .  processing  . . ."
      sLengthMenu: "show: _MENU_"
      sSearch: "filter: _INPUT_"
      sInfoFiltered: "(total: _MAX_)"
      sZeroRecords: "Your filter found nothing."
      sEmptyTable: "Your search found no matches."
      # sInfoEmpty: ""

	# cls: May 4, 2013: disable highlighting:
  # highlight_words_in_datatables = (words) ->
  #   for word in words
  #     $('.dataTable').highlight(word)
  # 
  # # on initial page load:
  # highlight_words_in_datatables terms
  # 
  # # when user changes page size, i.e. clicks "show:" drop-down:
  # $('.dataTables_length select').on "change", ->
  #   highlight_words_in_datatables terms
  # 
  # # when user pages thru table, i.e. clicks Previous/Next or page numbers:
  # $('#logs').bind "draw", ->
  #   highlight_words_in_datatables terms

  $("#and-all").on "click", (event) ->
    event.preventDefault()
    search_terms = $("#search_query").val()
    unless typeof search_terms is "undefined"
      search_terms = search_terms.strip()
      search_terms = search_terms.removeOrs()
      search_terms = search_terms.removeAnds()
      words = search_terms.split(/[\s]/)
      words = words.filter(Boolean)
      terms = words.join(" AND ")
      $("#search_query").val(terms)
      $('#search_query').focus()

  $("#or-all").on "click", (event) ->
    event.preventDefault()
    search_terms = $("#search_query").val()
    unless typeof search_terms is "undefined"
      search_terms = search_terms.strip()
      search_terms = search_terms.removeOrs()
      search_terms = search_terms.removeAnds()
      # words = search_terms.split(/(\s|\n|\t)+/g)
      words = search_terms.split(/[\s]/)
      # for word in words
      #   console.log "word.strip()=>"+word.strip()+"<"
      #   console.log "word=>"+word+"<"
      words = words.filter(Boolean)
      terms = words.join(" OR ")
      # console.log terms.length
      # console.log terms
      $("#search_query").val(terms)
      $('#search_query').focus()

  String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

  String::removeAnds = -> @replace /\AND/g, " "

  String::removeOrs = -> @replace /\OR/g, " "
