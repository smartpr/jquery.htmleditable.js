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
		# TODO: Shouldn't we keep track of this element, so that we make sure
		# we do not append it twice in some edge case scenarios? If an instance
		# is removed (because the element gets removed), style should ideally
		# disappear with it.
		$('head').append "<style>
			##{ @prop 'id' }.no-margins p, ##{ @prop 'id' }.no-margins ul, ##{ @prop 'id' }.no-margins ol {
				margin-top: 0;
				margin-bottom: 0;
			}
		</style>"
		@bind 'state', (e, state) =>
			# TODO: Make a (very simple) stand-alone plugin to make this type
			# of toggle more concise? I am doing this all over the place.
			@["#{ if state.margins is yes then 'remove' else 'add' }Class"] 'no-margins' if 'margins' of state
		# TODO: We could get rid of this and just depend on `context.get` to
		# make sure that a state will be set.
		# @htmleditable 'command', 'margins', no if @htmleditable('state', 'margins') is undefined
	content: yes

	# TODO: Here we basically define an initial state value -- we can choose to
	# introduce a separate property for that.
	state: ->
		@htmleditable('state', 'margins') ? no
