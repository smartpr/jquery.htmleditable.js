$elem = undefined
beforeEach -> $elem = $ '#editable', fix

describe "$.htmleditable.link", ->

	# TODO: Re-enable as soon as we have an external change event library.
	xit "updates link target according to link text change if text is target", ->
		$elem.
			htmleditable(['link']).
			htmleditable 'value', 'This is a link: <a href="http://smart.pr/">http://smart.pr/</a> and this is not'
		
		($link = $elem.find 'a').html "#{ $link.html() }#aboutus"

		expect($link.attr('href')).toBe $link.html()
		expect($elem.htmleditable 'value').toBe 'This is a link: <a href="http://smart.pr/#aboutus">http://smart.pr/#aboutus</a> and this is not'
