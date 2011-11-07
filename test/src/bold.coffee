$elem = undefined
beforeEach -> $elem = $ '#editable', fix

describe "$.htmleditable.bold", ->

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
