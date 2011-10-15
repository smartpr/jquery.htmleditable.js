$ = jQuery

$.htmleditable.link =
	allow: (attrs) ->
		if @is('a') and attrs?.href.value
			@attr 'href', attrs.href.value
			return yes
	init: ->
		@bind 'DOMCharacterDataModified', (e) ->
			$target = $ e.target
			if $target.is('a') and e.originalEvent.prevValue is $target.attr 'href'
				# TODO: Don't change `href` if it results in an invalid link.
				$target.attr 'href', e.originalEvent.newValue
				# TODO: `updateValue` should not be public. Perhaps we can
				# reuse the same wrapper that we will be using when emitting
				# the state? Or, add some kind of hook that will be invoked
				# upon change, before `updateValue` is called?
				updateValue.call @
	context:
		get: (selection) ->
			# Not sure if `selection` will ever be `undefined`. That would mean
			# that the editor field has focus but the cursor is not in there --
			# is that even possible?
			return null unless selection?
			# TODO: Don't return bare DOM elements, but wrappers around them
			# that control which attributes can be modified and that make sure
			# that the editor's value is updated.
			$(if selection.collapsed then selection.commonAncestorContainer else selection.getNodes()).closest('a').get()
		set: (selection, url) ->
			# We can only create a link if no links are currently selected or
			# around the cursor, but the feature is not a disabled state (i.e.
			# the cursor *is* inside the editor field).
			state = $(@).htmleditable 'state', 'link'
			return unless state? and state.length is 0

			# I think we can safely assume that `selection` will not be
			# `undefined`, as we already ascertained that `state` is not
			# `null`.
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
			
			return
