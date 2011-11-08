'use strict';

$ = jQuery.sub()

# Note that returning anything other than `no` means that the element will be
# included in the selection.
jQuery.expr[':'].htmleditable = (el) ->
	$el = $(el)
	$el.is('[contenteditable="true"]') and $el.data('htmleditable')?

$.fn.originalHtml = $.fn.html
jQuery.fn.html = ->
	return @htmleditable 'value', arguments... if @eq(0).is ':htmleditable'
	# A tricky consequence of our setup with `$` being a `jQuery.sub()` is the
	# fact that we *have* to wrap `@` in `$` here, even though `@` is an
	# instance of `jQuery`. This fact, and that it is therefore *not* an
	# instance of `$` is precisely the reason why.
	$(@).originalHtml arguments...

jQuery.fn.htmleditable = $.pluginify
	
	init: (linemode, features) ->
		# Document must be ready before initialization because we need to be
		# capable of setting `styleWithCSS` to `no` before we can reliably let
		# people use it.
		$.error "Initialization of htmleditable is not possible before the document is ready. Have you placed your code in a 'ready' handler?" unless jQuery.isReady

		return @ if $(@).closest(':htmleditable').length > 0 or $(@).parents('[contenteditable="true"]').length > 0
		
		# TODO: Is this [really necessary](http://code.google.com/p/rangy/wiki/
		# RangyObject#rangy.init())?
		rangy.init()

		# TODO: Filter out duplicates.
		features = $.merge [linemode, 'base'], features ? []
		load = $.merge [], features
		for feature in features
			for condition in jQuery.htmleditable[feature]?.condition ? []
				if condition[0] is '-'
					shouldBeIncluded = no
					condition = condition[1..]
				else
					shouldBeIncluded = yes
				if condition in load isnt shouldBeIncluded
					loop
						i = $.inArray feature, load
						break if i is -1
						load.splice i, 1
					break
		features = {}
		for l in load
			features[l] = jQuery.htmleditable[l]

		$(@).
			data('htmleditable',
				features: features
			).
			attr('contenteditable', yes).
			bind('paste', (e) ->
				selection = rangy.saveSelection()
				getRinsebin().focus()
				# TODO: In IE `script` and `style` elements are not stripped
				# from the pasted content, which results in the scripts being
				# executed and the styling being applied (for a brief instance,
				# until the `$rinsebin` is emptied). Other editors such as
				# TinyMCE do not suffer from this problem -- how do they do
				# this? Ideally we would just strip scripts and styling from
				# the content before it ends up in the `$rinsebin`, but that
				# would require access to the clipboard. This is possible in
				# IE, but only as plain text as far as I know.
				# Update: not sure if scripts are stripped, pretty sure that
				# styling is not part of the pasted content.
				# One potential solution could be to use an `iframe` for the
				# `$rinsebin`, but that will probably have complications in
				# other areas, so we should experiment with that before going
				# that route.
				# TODO: Is the try-catch block truly necessary here?
				try e.preventDefault() unless document.execCommand('Paste') is no catch err
				setTimeout =>
					$(@).focus()

					cleaned = cleanTree.call $(@), getRinsebin()[0]
					getRinsebin().empty().append cleaned
					html = getRinsebin().html()
					getRinsebin().empty()

					rangy.restoreSelection selection
					try
						document.execCommand 'insertHTML', undefined, html
					catch err
						document.selection.createRange().pasteHTML html
					# We don't have to manually update the instance's value
					# here because the paste will be notified by
					# `$.event.special.val`, which in turn results in the value
					# being updated per the handler below.
					# TODO: Previous description is from the future.
					# TODO: Note that this code is in a `setTimeout`, which
					# means that any paste handlers will be executed before
					# the value is up-to-date.
			).
			bind('input', ->
				$(@).updateValue()
			).
			bind('change mouseup touchend focus blur', ->
				$(@).updateState()
			).
			bind('keydown', -> setTimeout =>
				$(@).updateState()
				# TODO: This is a temporary work-around the fact that IE
				# doesn't trigger `input` (on contenteditable).
				# $(@).updateValue()
			)
		
		# For some crazy reason the following line cannot be placed outside
		# this method in a `ready` handler of its own, because it will throw
		# an exception as if the document isn't ready yet. (We're talking
		# Firefox here.)
		try document.execCommand 'styleWithCSS', undefined, no catch err
		
		# Initialize a state for every feature.
		$(@).updateState()
		
		# Clean the initial content.
		# TODO: We might want to prevent a `change` event from being triggered
		# as a result of this action, because this is not really a change of
		# value of the htmleditable as it only exists as of now. When we decide
		# to put this change event logic in an external component though, then
		# we *would* expect an event here, because this external component
		# operates at the level of a contenteditable.
		$(@).htmleditable 'value', $(@).originalHtml()

		# Feature-specific initialization.
		for name, feature of $(@).data('htmleditable').features
			feature.init?.call $(@)
			for keys, args of feature.hotkeys
				# `jquery.hotkeys.js` does not seem to support `$.fn.on` (yet?)
				$(@).bind 'keydown', keys, (e) ->
					e.preventDefault()
					e.stopPropagation()
					$(@).htmleditable 'command', name, args...
		
		@
	
	value: (html) ->
		return $(@).data('htmleditable').value unless html?
		
		# We are setting a new value into the htmleditable field. Before we can
		# do so we must check if the new content defines some state settings,
		# after which we have to make sure that the content is clean.

		# TODO: `htmleditable:state` may be not the best key name, as it is not
		# really a state but rather a command specification (?)
		html = html.replace /^([\s\S]*)<!--htmleditable:state\s([\s\S]*?)-->([\s\S]*)$/g, (match, before, settings, after) =>
			features = $(@).data('htmleditable').features
			for name, value of $.parseJSON "{ #{ settings } }"
				if features[name]?.content is yes
					$(@).htmleditable 'command', name, value
			before + after
		
		getRinsebin().html html
		cleaned = cleanTree.call $(@), getRinsebin()[0]
		getRinsebin().empty()

		result = $(@).empty().append cleaned
		$(@).updateValue()

		return result

	state: (features) ->
		state = $(@).data('htmleditable')?.state
		# Return nothing if there is no state (yet).
		return state unless state?
		# Return the requested state value if a feature name was specified
		# directly.
		return state[features] if typeof features is 'string'
		# Return the full state object if no specific features were requested.
		return $.extend({}, state) unless features?.length
		# In all other cases return a selection of the state object with just
		# the requested feature states.
		requested = {}
		for feature in features
			requested[feature] = state[feature]
		requested
	
	command: (command, args...) ->
		state = {}
		feature = $(@).data('htmleditable').features[command]
		if 'command' of feature
			feature.command.call $(@), args...
		else
			state[command] = args[0]
		$(@).updateState state

		$(@).updateValue()

		@
	
	# TODO: Return `null` instead of `undefined` in case no selection is in
	# place? If we are certain that `null` won't be used otherwise, I think it
	# would be a better option than `undefined` because in the context of
	# function arguments the difference between "no argument supplied" and
	# "argument with value `null` supplied" is less subtle than the difference
	# between "no argument supplied" and "argument with value `undefined`
	# supplied."
	selection: (range) ->
		if arguments.length > 0
			if range?.nodeType is 1
				r = rangy.createRange()
				r.selectNodeContents range
				range = r
			rangy.getSelection().setSingleRange range
			$(@).updateState()
			return @
		
		selection = rangy.getSelection()
		# A selection of multiple ranges will be treated as if there is nothing
		# selected, because we do not want to support this scenario.
		return unless selection.rangeCount is 1
		range = selection.getRangeAt 0

		scope = rangy.createRange()
		scope.selectNodeContents @

		# TODO: What should be returned in case the entire editor is selected,
		# including its own DOM element?

		# Using `WrappedRange.containsRange` here would be slightly more
		# elegant, but we can't until [this bug](http://code.google.com/p/
		# rangy/issues/detail?id=74) has been resolved.
		intersection = scope.intersection range
		return if intersection is null or not intersection.equals range

		range

jQuery.htmleditable ?= {}

cleanTree = (root) ->
	features = @data('htmleditable').features
	
	layer = (node) ->
		# Never pass the actual root node to a feature, because it is not
		# something that the feature should have access to. Always pass a
		# jQuery object though, so that features can simply use code like
		# `@is 'selector'` without having to explicitly deal with the scenario
		# in which `@` doesn't hold a node.
		$node = if node is root then $() else $ node
		if node.nodeType is 1
			children = document.createDocumentFragment()
			for child in node.childNodes
				include = layer.call @, child
				children.appendChild include if include?

			processors = (feature.element for name, feature of features)
			i = 0
			element = undefined
			while i < processors.length
				processor = processors[i++]
				result = processor?.call $node, element, children
				if $.isFunction result
					processors.push result
				else if result?
					element = result
			if element?
				if children.hasChildNodes()
					element.appendChild children
				children = element
			
			return children
			
		else if node.nodeType is 3
			return $node.clone(no, no)[0]
	
	layer.call @, root

# TODO: This can be a rather heavy function, so we either have to make sure
# that it is not invoked too frequently, or we have to make it more light-
# weight by only running the cleaning part if there is a chance that it will
# actually result in a changed value.
$.fn.updateValue = ->
	data = @data 'htmleditable'

	for name, feature of data.features
		feature.change?.call @

	# Clone the htmleditable node tree because it should remain unmodified at
	# all times, but do so without copying data so that `:htmleditable` will no
	# longer hold -- which is the desired behavior because we do not want
	# `$.fn.html` to perform its cleaning magic on the cloned content.
	$current = @clone no, no

	settings = {}
	for name, feature of data.features
		feature.output?.call @, $current
		if feature.content is yes
			# TODO: Escape any occurences of `-->` (or `--`?)
			settings[name] = @htmleditable 'state', name
	
	current = $current.html()
	unless $.isEmptyObject settings
		# TODO: Has `JSON.stringify` the browser support we need?
		settings = JSON.stringify settings
		current = "<!--htmleditable:state #{ settings[1...settings.length - 1] } -->#{ current }"

	unless data.value is current
		data.value = current
		# TODO: Rename to `val` in anticipation of `$.event.special.val`.
		@change()

$.fn.updateState = (state) ->
	selection = @htmleditable 'selection'
	featuresState = {}
	for name, feature of @data('htmleditable').features
		featureState = feature?.state?.call @
		if featureState isnt undefined
			unless $.isPlainObject featureState
				value = featureState
				(featureState = {})[name] = value
			$.extend featuresState, featureState
	$.extend featuresState, state
	
	data = @data 'htmleditable'
	data.state ?= {}
	
	delta = {}
	for key, value of featuresState
		# TODO: This should be a deep compare (or delegate comparison to the
		# feature).
		unless data.state[key] is value
			data.state[key] = value
			delta[key] = value
	
	@trigger('state', delta) unless $.isEmptyObject delta

$rinsebin = $()
getRinsebin = ->
	unless $rinsebin.length is 1
		$rinsebin = $('<div contenteditable="true" tabindex="-1" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;" />').prependTo 'body'
	$rinsebin

# TODO: Move to dedicated plugin project.
jQuery.fn.domSplice = (element) ->
	elements = []
	@each ->
		if element
			$element = $(element)
			elements.push $element.get()...
		if @nodeType is 1 and @nodeName.toLowerCase() in ['style', 'script', 'iframe']
			if element
				$(@).replaceWith $element
			else
				$(@).remove()
		else if element
			$element.insertBefore(@).prepend($(@).contents())
			$(@).remove()
		else
			$(@).replaceWith $(@).contents()
	$(elements)
