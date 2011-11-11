$ = jQuery

# TODO: Rename to `lists` (denoting the fact that it deals with multiple types
# of lists)?
$.htmleditable.list =

	element: (element, children) ->
		if not @is 'ul, ol'
			list = document.createElement 'ul'
			child = children.firstChild

			while child?
				$child = $ child
				# Fetch next child right away, so we can freely move or remove
				# `child`.
				next = child.nextSibling

				if $child.is 'li'
					unless list.hasChildNodes()
						children.insertBefore list, child
					list.appendChild child
					# TODO: Ideally we would be more intelligent about dealing
					# with item contents. We can derive all kinds of list
					# characteristics from it, like type (ordered or unordered)
					# and whether it is nested or not.
					$child.html $child.html().replace /^\S\.?(?:&nbsp;)+([\s\S]+)$/, "$1"
				else if list.hasChildNodes()
					# Whitespace in between list items should not close a list.
					if child.nodeType is 3 and /^\s*$/.test child.data
						children.removeChild child
					else
						list = document.createElement 'ul'
				
				child = next

		return if @length is 0

		for name in @attr('class')?.split(' ') ? []
			if /^MsoListParagraph\S*$/.test name
				return document.createElement 'li'
		
		return if element?

		if @is 'ul, ol, li'
			return document.createElement @prop 'nodeName'

	state: ->
		return null unless $(@).htmleditable('selection')?
		orderedList: document.queryCommandState 'insertOrderedList'
		unorderedList: document.queryCommandState 'insertUnorderedList'
	
	command: (ordered) ->
		console.log 'command: list', ordered
		document.execCommand "insert#{ if ordered then 'Ordered' else 'Unordered' }List"
