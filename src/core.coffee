###*

# core

The core editor *engine* jQuery plugin.

###

# TODO: Good idea?
"use strict";

# TODO: Make `$` a `jQuery.sub()`, so we have both a public and a private
# jQuery environment to extend. Tricky part is to do this at the right moment,
# because extensions to `jQuery` beyond this point will not be part of `$`.
$ = jQuery

# Note that returning anything other than `no` means that the element will be
# included in the selection.
$.expr[':'].htmleditable = (el) ->
	$el = $(el)
	$el.is('[contenteditable="true"]') and $el.data('htmleditable')?

# TODO: Use some more meaningful name instead of `overriddenHtml`. Something
# that carries the idea of not entailing all the cleaning magic. Also; put it
# on `$.fn`.
# Perhaps it would be a good idea to keep `$.fn.html` as it is internally, and
# use a different name for the overridden version with all the cleaning magic.
# Then, on the public jQuery environment, put the overridden version on
# `$.fn.html`.
overriddenHtml = $.fn.html
$.fn.html = (html) ->
	# Retrieving the value of the `$rinsebin` should always involve cleaning
	# it, so that cleaning HTML is just a matter of dropping it in there and we
	# are done.
	if @[0] is getRinsebin()[0] and not html?

		# Take current contents of the `$rinsebin`, generate a clean DOM tree
		# from it and put it back in the bin.

		html = overriddenHtml.call @

		# TODO: How to obtain the features from this call on `$rinsebin`?
		$editable = $ ':htmleditable:first'
		features = $editable.data('htmleditable').features

		# Incoming cleaning.

		for name, feature of features
			# TODO: We can replace `feature?.input` with `feature.input`(?)
			result = feature?.input?.call $editable, html
			html = result if typeof result is 'string'
		
		$decoder = $ '<div />'
		cursor = @empty()[0]
		process = []
		HTMLParser html,
			start: (name, attrs, empty) ->
				try
					element = document.createElement name
				catch err

				return unless element

				$element = $ element
				element = undefined
				elementProcess = []
				for name, feature of features
					result = feature?.allow?.call $element, attrs
					if $.isFunction result
						elementProcess.push result
					else unless element
						element = $element[0] if result is yes
						element = result if result?.nodeType is 1
				
				if elementProcess.length > 0
					remove = not element?
					element ?= $element[0]
					process.push [element, elementProcess, remove]
				
				return unless element

				cursor.appendChild element
				cursor = element unless element.nodeName of empty
				yes
			end: (name) ->
				cursor = cursor.parentNode
			chars: (text) ->
				cursor.appendChild document.createTextNode $decoder.html(text).text()
		
		for [element, elementProcess, remove] in process
			forceRemove = no
			for p in elementProcess
				forceRemove = forceRemove or p.call(@, element, remove) is yes
			$(element).domSplice() if forceRemove or remove

		return overriddenHtml.call @

	if @eq(0).is ':htmleditable'

		return @data('htmleditable').value unless html?
		
		# We are setting a new value into the htmleditable field. Before we can
		# do so we must check if the new content defines some state settings,
		# after which we have to make sure that the content is clean.

		html = html.replace /^([\s\S]*)<!--htmleditable:state\s([\s\S]*?)-->([\s\S]*)$/g, (match, before, settings, after) =>
			features = @data('htmleditable').features
			for name, value of $.parseJSON "{ #{ settings } }"
				if features[name]?.content is yes
					@htmleditable 'command', name, value
			before + after
		
		# Passing content through the `$rinsebin` will clean it.
		html = getRinsebin().html(html).html()
		getRinsebin().empty()

		# `html` is now clean and ready for editing.
		result = overriddenHtml.call @, html
		updateValue.call @[0]

		return result
	
	overriddenHtml.call @, html

# TODO: This can be a rather heavy function, so we either have to make sure
# that it is not invoked too frequently, or we have to make it more light-
# weight by only running the cleaning part if there is a chance that it will
# actually result in a changed value.
window.updateValue = ->
	# TODO: This is experimental -- should probably go into a feature, which in
	# turn would rely on an external plugin that is capable of doing something
	# similar for any input element? Or maybe it should not be part of
	# htmleditable at all -- just an external plugin that puts some `valHooks`
	# in place? Or, then one could argue why not leaving prettification up to
	# the renderer (dataview and the likes) -- it would keep the data
	# unmodified from what the user entered (prettify is a no-way-back-type-of-
	# operation)
	# jsprettif.y.prettify()

	data = $(@).data 'htmleditable'
	# Clone the htmleditable node tree because it should remain unmodified at
	# all times, but do so without copying data so that `:htmleditable` will no
	# longer hold -- which is the desired behavior because we do not want
	# `jQuery.fn.html` to perform its cleaning magic on the cloned content.
	$current = $(@).clone no, no

	# Outgoing cleaning.

	settings = {}
	for name, feature of data.features
		feature.output?.call $(@), $current
		if feature.content is yes
			# TODO: Escape any occurences of `-->` (or `--`?)
			settings[name] = $(@).htmleditable 'state', name
	
	current = $current.html()
	unless $.isPlainObject settings
		# TODO: Has `JSON.stringify` the browser support we need?
		settings = JSON.stringify settings
		current = "<!--htmleditable:state #{ settings[1...settings.length - 1] } -->#{ current }"

	unless data.value is current
		data.value = current
		$(@).change()

getState = (inactive) ->
	selection = $(@).htmleditable 'selection'
	state = {}
	for name, feature of $(@).data('htmleditable').features
		featureState = feature?.context?.get?.call $(@), selection
		if featureState isnt undefined
			unless $.isPlainObject featureState
				value = featureState
				(featureState = {})[name] = value
			$.extend state, featureState
	# if inactive
	# 	# TODO: Wouldn't it be better to use `undefined` for initial/
	# 	# inactive state? This value is already excluded from being used as
	# 	# state value because it is indistinguishable from "no state" as
	# 	# used by feature functions such as `context.set`.
	# 	for key of state
	# 		state[key] = null
	state

# A slightly more appropriate name would be `updateStateFromContext`, as it
# will only try to update state for those features that get their state from
# context.
updateState = ->
	# Something happened that may have changed any of the
	# features's state.
	# Using `activeElement` to determine if the state should be active or not
	# is not a good idea because why not just leave this up to
	# `htmleditable('selection')` which is supposed to find out if an active
	# state can be given.
	setState.call @, getState.call @, document.activeElement isnt @

setState = (state) ->
	data = $(@).data 'htmleditable'
	data.state ?= {}
	
	delta = {}
	for key, value of state
		unless data.state[key] is value
			data.state[key] = value
			delta[key] = value
	
	$(@).trigger('state', delta) unless $.isEmptyObject delta

$rinsebin = $()
getRinsebin = ->
	unless $rinsebin.length is 1
		$rinsebin = $('<div contenteditable="true" tabindex="-1" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;" />').prependTo 'body'
	$rinsebin

$.fn.htmleditable = $.pluginify
	
	init: (features) ->
		return @ if $(@).closest(':htmleditable').length > 0 or $(@).parents('[contenteditable="true"]').length > 0
		
		# TODO: Is this [really necessary](http://code.google.com/p/rangy/wiki/
		# RangyObject#rangy.init())?
		rangy.init()

		# TODO: Filter out duplicates.
		features = $.merge ['base', 'multiline'], features ? []
		load = $.merge [], features
		for feature in features
			for condition in $.htmleditable[feature]?.condition ? []
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
			features[l] = $.htmleditable[l]

		$(@).
			data('htmleditable',
				features: features
			).
			attr('contenteditable', yes).
			bind('paste', (e) ->
				selection = rangy.saveSelection()
				getRinsebin().focus()
				# TODO: Is the try-catch block truly necessary here?
				try e.preventDefault() unless document.execCommand('Paste') is no catch err
				setTimeout =>
					$(@).focus()
					rangy.restoreSelection selection
					html = getRinsebin().html()
					try
						document.execCommand 'insertHTML', undefined, html
					catch err
						document.selection.createRange().pasteHTML html
					getRinsebin().empty()
			).
			bind('focus', ->
				try document.execCommand 'styleWithCSS', undefined, no catch err
			).
			bind('input', updateValue).
			bind('change mouseup focus blur', updateState).
			bind('keydown', -> setTimeout => updateState.call @)
		
		# Make sure every feature has a state, so `updateValue` can be run.
		setState.call @, getState.call @, true
		
		# Clean initial content before `updateValue` is called -- doing so will
		# invoke `updateValue` eventually. By setting a value using `$.fn.val`
		# we automatically clean it.
		# TODO: Use `$(@).val`.
		$(@).html overriddenHtml.call $(@)

		# Feature-specific initialization.
		for name, feature of $(@).data('htmleditable').features
			feature?.init?.call $(@)
		
		@
	
	value: ->
		$(@).html arguments...

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
		state = $(@).data('htmleditable').features[command]?.context?.set?.call $(@), $(@).htmleditable('selection'), args...
		# TODO: Do we really want to update state here? Isn't that what
		# `updateState` is for?
		if state?
			unless $.isPlainObject state
				value = state
				state = {}
				state[command] = value
			setState.call @, state
		
		# TODO: This is superfluous in many (all?) scenarios. Think about how
		# we can leanify this.
		updateValue.call @
		updateState.call @

		@
	
	# TODO: Return `null` instead of `undefined` in case no selection is in
	# place? If we are certain that `null` won't be used otherwise, I think it
	# would be a better option than `undefined` because in the context of
	# function arguments the difference between "no argument supplied" and
	# "argument with value `null` supplied" is less subtle than the difference
	# between "no argument supplied" and "argument with value `undefined`
	# supplied."
	selection: (range) ->
		rangy.init()

		if arguments.length > 0
			if range?.nodeType is 1
				r = rangy.createRange()
				r.selectNodeContents range
				range = r
			rangy.getSelection().setSingleRange range
			updateState.call @
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

$.htmleditable ?= {}

# TODO: Move to dedicated plugin project.
$.fn.domSplice = (element) ->
	elements = []
	@each ->
		if element
			$element = $(element)
			elements.push $element.get()...
		if @nodeType is 3 and @nodeName.toLowerCase() in ['style']
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
