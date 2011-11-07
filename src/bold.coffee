$ = jQuery

name = undefined
tag = ->
	return name if name?

	$testbed = $('<div contenteditable="true" tabindex="-1" style="position: absolute; top: -100px; left: -100px; width: 1px; height: 1px; overflow: hidden;">text</div>').prependTo 'body'
	range = rangy.createRange()
	range.selectNodeContents $testbed[0]
	rangy.getSelection().setSingleRange range
	document.execCommand 'bold', null, null
	name = $testbed.children()[0].nodeName
	$testbed.remove()

	name ? 'b'

$.htmleditable.bold =
	
	element: (element) ->
		return if @length is 0 or element?

		if @is 'strong, b'
			return document.createElement tag()
		
		if @is ':header'
			return (element, children) ->
				return if element?

				# Wrap contents of `children` in a bold tag.
				bold = document.createElement tag()
				while children.firstChild?
					bold.appendChild children.firstChild
				children.appendChild bold

				return

		return

	# TODO: Probably nicer to pass `$tree` as `@`.
	output: ($tree) ->
		$tree.find(tag()).domSplice '<strong />'
	
	state: ->
		# TODO: Isn't `@` a jQuery object already?
		return null unless $(@).htmleditable('selection')?
		document.queryCommandState 'bold'
	
	# TODO: Allow for short-cut notation like `hotkeys: 'ctrl+b meta+b'`
	hotkeys:
		'ctrl+b meta+b': []
	
	command: ->
		document.execCommand 'bold', null, null
