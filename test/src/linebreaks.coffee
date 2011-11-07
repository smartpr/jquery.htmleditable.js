$elem = undefined
beforeEach -> $elem = $ '#editable', fix

describe "$.htmleditable.linebreaks", ->

	it "adds trailing linebreaks to paragraph elements", ->
		$elem.
			# TODO: Set to use `linebreaks` explicitly.
			htmleditable().
			htmleditable 'value', "<p>paragraph</p>text"
		
		# TODO: We could use a dedicated string matcher for these kind of
		# expect statements.
		expect($elem.htmleditable('value').toLowerCase()).toBe "paragraph<br><br>text"
	
	it "adds trailing linebreaks to header elements", ->
		$elem.
			# TODO: Set to use `linebreaks` explicitly.
			htmleditable().
			htmleditable 'value', "<h1>header<br></h1>text"
		
		# TODO: We could use a dedicated string matcher for these kind of
		# expect statements.
		expect($elem.htmleditable('value').toLowerCase()).toBe "header<br><br><br>text"
	
	it "ignores namespaced elements", ->
		$elem.
			# TODO: Set to use `linebreaks` explicitly.
			htmleditable().
			htmleditable 'value', 'text<o:p></o:p>'

		expect($elem.htmleditable('value').toLowerCase()).toBe 'text'
