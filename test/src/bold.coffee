$elem = undefined
beforeEach -> $elem = $ '#editable', fix

describe "$.htmleditable.bold", ->

	describe "interprets headers", ->

		it "makes headers bold", ->
			$elem.
				htmleditable(['bold']).
				htmleditable 'value', "<h1>bold</h1>not bold"
			
			# TODO: We could use a dedicated string matcher for these kind of
			# expect statements.
			expect($elem.htmleditable('value').toLowerCase()).toBe "<p><strong>bold</strong></p>not bold"

		it "keeps trailing whitespace and linebreaks outside of the bold", ->
			$elem.
				# TODO: Set to use `linebreaks` explicitly.
				htmleditable(['bold']).
				htmleditable 'value', "<h1>bold<br></h1>not bold"
			
			# TODO: We could use a dedicated string matcher for these kind of
			# expect statements.
			expect($elem.htmleditable('value').toLowerCase()).toBe "<strong>bold</strong><br><br><br>not bold"
		
		it "does not add element if header already contains bold tag", ->
			$elem.
				# TODO: Set to use `linebreaks` explicitly.
				htmleditable(['bold']).
				htmleditable 'value', "<h1><strong>bold</strong></h1>not bold"
			
			expect($elem.htmleditable('value').toLowerCase()).toBe "<strong>bold</strong><br><br>not bold"
	
		it "does not add element if header is wrapped by bold tag", ->
			$elem.
				htmleditable(['bold']).
				htmleditable 'value', "<strong><h1>bold</h1></strong>not bold"
			
			expect($elem.htmleditable('value').toLowerCase()).toBe "<p><strong>bold</strong><p>not bold"
	
	it "defines hotkeys", ->
		spyOn $.htmleditable.bold, 'command'
		$elem.htmleditable ['bold']

		# Just `b` -- should not trigger command.
		$elem.trigger
			type: 'keydown'
			target: $elem[0]
			which: 66
			altKey: no
			ctrlKey: no
			metaKey: no
			shiftKey: no
		# `ctrl+b` -- should trigger command.
		$elem.trigger
			type: 'keydown'
			target: $elem[0]
			which: 66
			altKey: no
			ctrlKey: yes
			metaKey: no
			shiftKey: no
		# `meta+b` -- should trigger command.
		$elem.trigger
			type: 'keydown'
			target: $elem[0]
			which: 66
			altKey: no
			ctrlKey: no
			metaKey: yes
			shiftKey: no
		
		expect($.htmleditable.bold.command.callCount).toBe 2
