###*

* Defined in `$.htmleditable.multiline`.
* Will not be loaded if [singleline](#docs.features.singleline) is enabled.
* Allows `p`, `div` and `br`.

This feature makes sure that new lines can be created. It is enabled by default
because we need either multiline or singleline support, and multiline is the
most sensible default.

###

# TODO: Put in `core.coffee`? It is enabled by default, so having it included
# by default would probably make sense.

$ = jQuery

$.htmleditable.multiline =
	condition: ['-singleline']
	allow: ->
		return yes if @is 'p, div, br'
		return ((element, remove) -> $(element).wrap '<p />' if remove) if @is ':header'
	init: ->
		# TODO: This is not correct because it doesn't provide for the
		# situation in which there are text nodes before the first or after the
		# last paragraph.
		# $('head').append "<style type=\"text/css\">
		# 	##{ @prop 'id' } p:first-child {
		# 		margin-top: 0;
		# 	}
		# 	##{ @prop 'id' } p:last-child {
		# 		margin-bottom: 0;
		# 	}
		# </style>"
