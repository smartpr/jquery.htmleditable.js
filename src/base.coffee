###*

Is defined in `$.htmleditable.base` and does some generic cleaning. Is enabled
by default. You usually wouldn't have to deal with this one.

###


# TODO: Put in `core.coffee`? It is enabled by default, so having it included
# by default would probably make sense.

$ = jQuery

$.htmleditable.base =
	input: (html) -> html.replace /Version:[\d.]+\nStartHTML:\d+\nEndHTML:\d+\nStartFragment:\d+\nEndFragment:\d+/gi, ''
