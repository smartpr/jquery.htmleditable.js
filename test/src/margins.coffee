$elem = undefined
beforeEach -> $elem = $ '#editable', fix

describe "$.htmleditable.margins", ->

	xit "can be initialized", ->
		spyOn $.htmleditable.margins, 'init'
		$elem.htmleditable ['margins']
		expect($.htmleditable.margins.init).toHaveBeenCalled()

# TODO: Test that not just a default state value is assigned, but that the
# actual command is being executed with a default value upon initialization --
# that is, styling has been included and a `no-margins` class may have been
# set.
# Update: hmm, no that's bullshit. The `margins` command really doesn't do
# anything beyond setting the state.