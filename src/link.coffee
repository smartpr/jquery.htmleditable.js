$ = jQuery

$.htmleditable.link =
	
	element: (element) ->
		return if @length is 0 or element?

		if @is 'a[href^="http://"]'
			link = document.createElement 'a'
			link.setAttribute 'href', @attr 'href'
			return link
	
	init: ->
		# TODO: Rather not use this deprecated event. Potential alternative:
		#     @on 'a', 'val', (e) ->
		# We would piggyback `$.event.special.val` because that one will be
		# capable of detecting content change inside a contenteditable, and
		# a subelement of a contenteditable element is also a contenteditable.
		# It would require adding a hard dependency on this external component
		# though, but this may be not a problem? If we don't want to add this
		# dependency we could bind the underlying DOM events ourselves.
		# Update: I think we need a hard dependency on the `val` event anyway,
		# because it is already indispensible for `core.coffee`.
		# @bind 'DOMCharacterDataModified', (e) ->
		# 	$target = $ e.target
		# 	if $target.is('a') and e.originalEvent.prevValue is $target.attr 'href'
		# 		# TODO: Don't change `href` if it results in an invalid link.
		# 		$target.attr 'href', e.originalEvent.newValue
		# 		# TODO: `updateValue` should not be public. Perhaps we can
		# 		# reuse the same wrapper that we will be using when emitting
		# 		# the state? Or, add some kind of hook that will be invoked
		# 		# upon change, before `updateValue` is called?
		# 		# Or: call `@htmleditable('invalidate')`
		# 		updateValue.call @
	
	state: ->
		selection = $(@).htmleditable 'selection'

		# TODO: Why not just use `undefined` here?
		return null unless selection?

		$(if selection.collapsed then selection.commonAncestorContainer else selection.getNodes()).closest('a').get()
	
	command: (url) ->
		selection = $(@).htmleditable 'selection'

		return unless selection?

		url ?= 'http://'
		unless selection.collapsed
			document.execCommand 'createLink', null, url
		else
			# If nothing is selected (but the cursor is inside the editor),
			# we cannot reliably use `createLink` because Gecko's Midas
			# will not do anything in that scenario. Therefore we create a
			# link by other means.
			try
				document.execCommand 'insertHTML', null, "<a href=\"#{ url }\">#{ url }</a>"
			catch err
				# TODO: I think in IE we end up here because `insertHTML`
				# is not supported(?) We can probably use [this method to
				# paste HTML instead](http://stackoverflow.com/questions/
				# 3398378/execcommand-inserthtml-in-internet-explorer/
				# 3398431#3398431).
