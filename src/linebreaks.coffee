# TODO: Put in `core.coffee`? It is enabled by default, so having it included
# by default would probably make sense.

$ = jQuery

$.htmleditable.linebreaks =
	condition: ['-singleline']

	element: (element) ->
		# TODO: We can probably drop this `@length is 0` check as it won't
		# harm any logic.
		return if @length is 0 or element?

		if @is 'br'
			return document.createElement 'br'
		
		# Paragraphs and headers are represented by two linebreaks, but only
		# if no other features have claimed to have an interpretation for them.
		# This allows for example a list feature to pick out certain paragraphs
		# that represent list items from MS Word.
		if @is 'p, :header'
			return (element, children) ->
				return if element?

				children.appendChild document.createElement 'br'
				children.appendChild document.createElement 'br'

				return
		
		# Similar to the behavior for paragraphs and headers, any element that
		# is not inline should be represented by one linebreak, but once again
		# only if no other features have an idea of what to do with the
		# element.
		if @css('display') in ['block', 'list-item', 'table-row']
			return (element, children) ->
				return if element?

				# Don't add a linebreak of the element's contents already end
				# with a linebreak. In most scenarios this break is the result
				# of a paragraph or header that used to be there, in which case
				# an additional linebreak would not represent the original
				# layout well.
				# TODO: This can obviously be optimized and fine-tuned. For
				# example; in case of a `list-item` we probably don't want to
				# assume that containing breaks stem from a paragraph or
				# header, as they are not common there(?) Or, in case of a list
				# we don't want to add a linebreak, even though it contains no
				# trailing breaks.
				last = children.lastChild
				while last? and last.nodeType is 3 and /^\s*$/.test last.data
					last = last.previousSibling
				children.appendChild document.createElement 'br' unless $(last).is 'br'

				return
		
		return
	
	init: ->
		# TODO: How to deal with elements with default margins other than `p`
		# (or `div`)?
		$('head').append "<style>
			##{ @prop 'id' } p {
				margin-top: 0;
				margin-bottom: 0;
			}
		</style>"
	
	change: ->
		if $(@).find('div, p').length > 0
			# TODO: Use custom cursor preservation technique so we can drop
			# this rangy module.
			sel = rangy.saveSelection()
			$(@).find('div').each ->
				prev = $(@)[0].previousSibling
				if prev? and not $(prev).is 'br'
					$(@).before('<br>')
				$(@).domSplice()
			$(@).find('p').each ->
				unless $(@)[0].previousSibling?.nodeType is 1 and $(@).prev().is 'br'
					$(@).after('<br>')
				$(@).domSplice()
			rangy.restoreSelection sel
