$ = jQuery

# TODO: How does this feature know which elements it deals with? Probably
# should just try to find a definitive set of elements that tends to have
# margin by default.
$.htmleditable.margins =
	condition: ['multiline']
	output: ($tree) ->
		unless @htmleditable 'state', 'margins'
			# Leave padding alone because it is something else than margin,
			# at least technically. Not sure if this is the most desirable
			# behavior in practice as well.
			$tree.find('p, ul, ol').css
				'margin-top': 0
				'margin-bottom': 0
	init: ->
		$('head').append "<style type=\"text/css\">
			##{ @prop 'id' }.no-margins p, ##{ @prop 'id' }.no-margins ul, ##{ @prop 'id' }.no-margins ol {
				margin-top: 0;
				margin-bottom: 0;
			}
		</style>"
		@bind 'state', (e, state) =>
			@["#{ if state.margins is yes then 'remove' else 'add' }Class"] 'no-margins' if 'margins' of state
		@htmleditable 'command', 'margins', no if @htmleditable('state', 'margins') is null
	content: yes
	context:
		# TODO: This function is really a means of setting the internal state,
		# which is optional to allow for features that want to play via the
		# browser (and get their state change via the `get` function). Can't
		# we think of better naming to reflect this idea?
		set: (selection, margins) ->
			margins ? not @htmleditable 'state', 'margins'
