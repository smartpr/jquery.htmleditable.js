# TODO:
# * Specify features that do not exist.
# * Test `$.fn.val` as an addendum to testing `$.fn.html` (or vice versa).
# * Test features' `input` and `output`.

$elem = undefined
beforeEach -> $elem = $ '#editable', fix
# Make sure that we don't clean out the fixture before all the pending code
# (which may be from `setTimeout`s in the library) has executed.
# TODO: Still relevant after refactory?
afterEach -> waits 0

describe "$.fn.htmleditable()", ->
	
	describe "init", ->

		it "takes line mode and features", ->
			expect($elem.htmleditable('init', 'linebreaks', ['bold']).get()).toEqual $elem.get()
			expect($elem).toBe ':htmleditable'

		it "makes features an optional argument", ->
			$elem.htmleditable 'init', 'linebreaks'
			expect(key for key of $elem.data('htmleditable').features).toEqual ['linebreaks', 'base']
		
		it "makes line mode an optional argument", ->
			$elem.htmleditable 'init', ['bold']
			expect(key for key of $elem.data('htmleditable').features).toEqual ['native', 'base', 'bold']
		
		it "can be invoked implicitly (although not recommended if first argument is a string)", ->
			expect($elem.htmleditable()).toBe ':htmleditable'

		# TODO: Test with features, syntax similar to 'state'.

		xit "cancels features that are invalidated by later features", ->
			spyOn $.htmleditable.multiline, 'init'
			$elem.htmleditable ['singleline']
			expect($.htmleditable.multiline.init).not.toHaveBeenCalled()
		
		it "registers hotkeys", ->
			spyOn $.htmleditable.bold, 'command'
			spyOn $.htmleditable.list, 'command'
			$elem.
				# Initialize with multiple features that define a command, so
				# we are also verifying that the correct command is invoked.
				htmleditable(['bold', 'list']).
				trigger
					type: 'keydown'
					target: $elem[0]
					which: 66
					altKey: no
					ctrlKey: no
					metaKey: yes
					shiftKey: no
			expect($.htmleditable.bold.command).toHaveBeenCalled()
			expect($.htmleditable.list.command).not.toHaveBeenCalled()
	
	describe "value", ->

		it "gets clean content", ->
			# TODO: Add `.toBeTrimmed` to `jasmine-string.js`?
			expect($.trim $elem.htmleditable().htmleditable 'value').toBe "Initial content!"
		
		it "sets clean content", ->
			$elem.htmleditable().htmleditable 'value', 'Scrutiny is <strong>strong</strong>!'
			# Using `innerHTML` bypasses `$.fn.html`.
			expect($.trim $elem[0].innerHTML).toBe 'Scrutiny is strong!'
		
		it "sets content that will be cleaned based on the right instance's features", ->
			$elem.htmleditable()
			($elem2 = $ '#settings', fix).
				htmleditable(['bold']).
				html 'this editable <strong>allows</strong> bold'
			
			# What we are verifying here is that the content that we just put
			# in has not been cleaned based on the first instance's feature
			# set.
			expect($elem2.htmleditable 'value').toBe 'this editable <strong>allows</strong> bold'
	
	describe "selection", ->

		it "returns undefined if no focus or selection has been set", ->
			$elem.htmleditable()
			expect($elem.htmleditable 'selection').toBeUndefined()

		it "returns undefined if selection is not (entirely) contained by the editable field", ->
			$elem.htmleditable()
			range = rangy.createRange()
			# This selection will start before and end after the htmleditable -
			# starting (or ending) the selection inside the htmleditable will
			# not work because the browser will not allow that (or something?)
			range.setStart $('#before-editable', fix).contents()[0], 3
			range.setEnd $('#uneditable', fix).contents()[0], 5
			rangy.getSelection().setSingleRange range
			expect($elem.htmleditable 'selection').toBeUndefined()
		
		it "returns a Rangy range object if selection exists", ->
			$elem.htmleditable()
			range = rangy.createRange()
			range.selectNodeContents $elem[0]
			rangy.getSelection().setSingleRange range
			selection = $elem.htmleditable 'selection'
			# TODO: Add `.toBeInstanceOf` (to which add-on)?
			expect(selection instanceof rangy.WrappedRange).toBe yes
			expect(selection.toString()).toBe 'Initial content!'
		
		it "sets the selection given a Rangy range object", ->
			$elem.htmleditable()

			range = rangy.createRange()
			range.selectNodeContents $elem[0]
			$elem.htmleditable 'selection', range
			expect($elem.htmleditable('selection').toString()).toBe 'Initial content!'
		
		it "sets the selection given a DOM node", ->
			$elem.htmleditable()

			$elem.htmleditable 'selection', $elem[0]
			expect($elem.htmleditable('selection').toString()).toBe 'Initial content!'
	
	describe "state", ->

		it "gets a specific state", ->
			$elem.htmleditable(['bold']).htmleditable 'selection', $elem[0]
			expect($elem.htmleditable 'state', 'bold').toBe no

			$elem.htmleditable 'selection', $elem.find('strong, b')[0]
			expect($elem.htmleditable 'state', 'bold').toBe yes
		
		it "gets a selection of states", ->
			$elem.htmleditable(['bold', 'link']).htmleditable 'selection', $elem[0]
			expect($elem.htmleditable 'state', ['bold']).toEqual
				bold: no
		
		it "gets the full state", ->
			$elem.htmleditable(['bold', 'link']).htmleditable 'selection', $elem[0]
			expect($elem.htmleditable 'state').toEqual
				bold: no
				link: []
		
		it "returns null for disabled states", ->
			$elem.htmleditable ['bold']	# The editable is not focused.
			expect($elem.htmleditable 'state', 'bold').toBeNull()
		
		it "updates on keydown, reflecting the state that takes effect only after its handlers executed", ->
			runs ->
				$elem.
					htmleditable(['bold']).
					# Focus now because we want setting the selection not to
					# trigger any events that may be used by the htmleditable
					# to update its state.
					focus().
					trigger 'keydown'
				range = rangy.createRange()
				range.setStart $elem.find('strong, b').contents()[0], 1
				range.setEnd range.startContainer, range.startOffset
				rangy.getSelection().setSingleRange range
			waits 0
			runs ->
				expect($elem.htmleditable 'state', 'bold').toBe yes
		
		# TODO: This stuff doesn't really belong under `state` I think.

		xit "sets content-level state settings for features that desire so", ->
			val = $elem.htmleditable(['margins']).htmleditable 'value'
			expect(val.indexOf "<!--htmleditable:state \"margins\":#{ $elem.htmleditable 'state', 'margins' } -->").not.toBe -1
		
		# TODO: Test using `#settings`.
		xit "gets state according to content-level settings where applicable", ->
			$elem.htmleditable ['margins']
			# Make sure current state is different from new state that will be
			# assigned via content-level setting.
			expect($elem.htmleditable 'state', 'margins').toBe no

			$elem.htmleditable 'value', '	[noise]	<!--htmleditable:state "margins": true --><strong>content</strong>bla'
			expect($elem.htmleditable 'state', 'margins').toBe yes
		
		xit "never leaves any content-level settings linger at edit-time", ->
			($elem = $ '#settings', fix).htmleditable ['margins']
			expect($elem[0].innerHTML.indexOf '<!--htmleditable:state').toBe -1

			$elem.htmleditable 'value', 'bla<!--htmleditable:state "margins":false -->bla'
			expect($elem[0].innerHTML).toBe 'blabla'
		
		# TODO: Test that settings of features that do not do content-level
		# settings or of non-existent features will be ignored and not put on
		# state object.

	describe "command", ->

		it "invokes a feature command", ->
			$elem.
				htmleditable(['bold']).
				htmleditable('selection', $elem.find('strong, b')[0]).
				htmleditable('command', 'bold')
			
			expect($elem.htmleditable 'state', 'bold').toBe no

describe "events", ->

	it "triggers change upon value change", ->
		$elem.
			bind('change', handler = jasmine.createSpy()).
			htmleditable()
		
		$elem.htmleditable 'value', "Changed content"
		expect(handler).toHaveBeenCalled()
	
	it "triggers state upon initialization", ->
		$elem.
			bind('state', handler = jasmine.createSpy()).
			htmleditable ['bold', 'link']
		
		expect(handler.mostRecentCall.args[1]).toEqual
			bold: null
			link: null
	
	it "triggers state upon state change", ->
		$elem.
			bind('state', handler = jasmine.createSpy()).
			htmleditable ['bold']
		
		$elem.htmleditable 'selection', $elem.find('strong, b')[0]
		expect(handler.mostRecentCall.args[1]).toEqual
			bold: yes

xdescribe "$.fn.html() & $.fn.val()", ->

	it "gets like $.fn.htmleditable('value')", ->
		$elem.htmleditable()
		expect($elem.html()).toBe $elem.htmleditable 'value'
		expect($elem.val()).toBe $elem.htmleditable 'value'
	
	it "sets like $.fn.htmleditable('value')", ->
		$elem.htmleditable()
		expect($elem.html('Scrutiny is <strong>strong</strong>!').html()).toBe 'Scrutiny is strong!'
		expect($elem.val('Strong is the <strong>scrutiny</strong>!').val()).toBe 'Strong is the scrutiny!'

describe ":htmleditable", ->

	it "does not match regular contenteditables", ->
		expect($ '[contenteditable="true"]', fix).not.toBe ':htmleditable'
	
	it "matches htmleditables", ->
		expect($elem.htmleditable()).toBe ':htmleditable'
