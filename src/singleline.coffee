$ = jQuery

$.htmleditable.singleline =
	condition: ['-multiline']
	init: ->
		@bind 'keydown', 'return', (e) -> e.preventDefault()
