$ = jQuery

tag = 'b'
$testbed = $()
getTestbed = ->
	unless $testbed.length is 1
		$testbed = $('<div contenteditable="true" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;">text</div>').prependTo 'body'
	$testbed
$ ->
	# TODO: This is in the incorrect place, as it will be executed before the
	# editor is initialized (which does stuff like setting `styleWithCSS`).
	$testbed = getTestbed()
	# TODO: Bring all the rangy-related stuff behind a simple `htmleditable`-level
	# API.
	rangy.init()
	range = rangy.createRange()
	range.selectNodeContents $testbed[0]
	rangy.getSelection().setSingleRange range
	$testbed.focus()
	document.execCommand 'bold', null, null
	tag = $testbed.children()[0].nodeName
	$testbed.remove()

$.htmleditable.bold =
	allow: ->
		# TODO: What about `@is 'b'` with `$(tag).is 'strong'`?
		return yes if @is tag
		return document.createElement tag if @is 'strong'
		return ((element, remove) -> $(element).contents().wrapAll "<#{ tag } />" if remove) if @is ':header'
	output: ($tree) ->
		$tree.find(tag).domSplice '<strong />'
	init: ->
		# TODO: Hmm, very strictly speaking, this is not (necessarily) part of
		# the feature. It's similar to the event handler that binds a click on
		# some tool button to the invocation of a command.
		# @bind('keydown', 'ctrl+b meta+b', (e) =>
		# 	e.preventDefault()
		# 	e.stopPropagation()
		# 	@htmleditable 'command', 'bold'
		# )
	context:
		get: (selection) ->
			return null unless selection?
			document.queryCommandState 'bold'
		set: ->
			document.execCommand 'bold', null, null
			return
