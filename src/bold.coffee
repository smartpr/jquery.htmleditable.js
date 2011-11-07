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
	
	element: (element, children) ->
		return if @length is 0 or element?

		if @is 'strong, b'
			return document.createElement tag()
		
		# TODO: We only recognize nested bold tags that are direct children of
		# the header. Is this sufficient?
		if @is(':header') and $(children.childNodes).filter(tag()).length is 0
			return (element, children) ->
				return if $(element).is ':header'

				# Wrap contents of `children` in a bold tag.
				bold = document.createElement tag()
				child = children.lastChild
				while child?
					next = child.previousSibling
					if bold.hasChildNodes() or not $(child).is('br') and (child.nodeType isnt 3 or not /^\s*$/.test child.data)
						unless bold.hasChildNodes()
							children.insertBefore bold, child
						bold.insertBefore child, bold.firstChild
					child = next
				
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
