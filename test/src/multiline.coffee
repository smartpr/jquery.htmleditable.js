$elem = undefined
beforeEach -> $elem = $ '#editable', fix

describe "$.htmleditable.multiline", ->

	it "is enabled (and thus initialized) by default", ->
		spyOn $.htmleditable.multiline, 'init'
		$elem.htmleditable()
		expect($.htmleditable.multiline.init).toHaveBeenCalled()
	
	it "only allows p, div & br elements", ->
		$elem.
			htmleditable().
			htmleditable 'value', "<div>a<p>b</p>c<br /><strong>not bold</strong></div>"
		expect $elem.htmleditable('value'), "<div>a<p>b</p>c<br />not bold</div>"
	
	it "transforms :header elements into p elements", ->
		$elem.
			htmleditable().
			htmleditable 'value', "<h1>a</h1><h2>b<h2>"
		expect $elem.htmleditable('value'), "<p>a</p><p>b</p>"
