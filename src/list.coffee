$ = jQuery

$.htmleditable.list =
	condition: ['multiline']
	allow: (attrs) ->
		return yes if @is 'ul, ol, li'
		# TODO: We can do this with one regular expression test directly on
		# `attrs.class.value`. Better?
		for value in attrs?.class?.value?.split(' ') ? []
			if /^MsoListParagraph\S*$/.test value
				return (element) ->
					# TODO: Distinguish ordered and unordered, and interpret
					# nesting.
					# TODO: Strip bullet and superfluous spacing.
					$element = $(element).wrap('<li />').parent()
					if $element.prev().is 'ul'
						$element.appendTo $element.prev()
					else
						$element.wrap '<ul />'
					yes
	context:
		get: ->
			orderedList: document.queryCommandState 'insertOrderedList'
			unorderedList: document.queryCommandState 'insertUnorderedList'
		set: (selection, ordered) ->
			document.execCommand "insert#{ if ordered then 'Ordered' else 'Unordered' }List"
