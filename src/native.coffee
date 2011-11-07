# TODO: Put in `core.coffee`? It is enabled by default, so having it included
# by default would probably make sense.

$ = jQuery

$.htmleditable.native =

	element: (element) ->
		return if element?

		if @is('p, div, br') and @prop('scopeName') in [undefined, 'HTML']
			return document.createElement @[0].nodeName
		
		if @is ':header'
			return (element) ->
				return if element?

				return document.createElement 'p'
