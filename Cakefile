# TODO: This is a mess and ugly as f#ck, but hey it works.

{print} = require 'util'
{exec, spawn} = require 'child_process'

parts = [
	'rangy-core.js'
	'rangy-selectionsaverestore.js'
	'jquery.pluginify.js'
	'jquery.hotkeys.js'

	'core.js'
	'base.js'
	'native.js'
	'singleline.js'
	'linebreaks.js'
	'bold.js'
	'link.js'
	'list.js'
]

build = (watch, bundle, done) ->
	if watch
		options = '--watch --output test/lib/ --compile test/src/'.split ' '
		test = spawn 'coffee', options
		test.stdout.on 'data', print
		test.stderr.on 'data', print
		options = '--watch --output lib/ --compile src/'.split ' '
		lib = spawn 'coffee', options
		lib.stdout.on 'data', print
		lib.stderr.on 'data', print
		done?.call()
	else
		test = "coffee --output test/lib/ --compile test/src/"
		exec test, (err, stdout, stderr) ->
			print(stdout) if stdout?
			print(stderr) if stderr?
			return if err?
			lib = "coffee --output lib/ --compile src/"
			exec lib, (err, stdout, stderr) ->
				print(stdout) if stdout?
				print(stderr) if stderr?
				return if err?
				done?.call() if not bundle
				exec "cat #{ ("lib/#{ part }" for part in parts).join ' ' } > jquery.htmleditable.standalone.js", (err, stdout, stderr) ->
					print(stdout) if stdout?
					print(stderr) if stderr?
					return if err?
					exec "uglifyjs jquery.htmleditable.standalone.js > jquery.htmleditable.standalone.min.js", (err, stdout, stderr) ->
						print(stdout) if stdout?
						print(stderr) if stderr?
						done?.call()

task 'build', 'Compile CoffeeScript source to JavaScript', -> build no, no

task 'dev', 'Compile continuously', -> build yes, no

task 'bundle', 'Compile and bundle', -> build no, yes

option '-m', '--message [TEXT]', 'commit message'
task 'commit', 'Compile, bundle and commit to GitHub', (options) -> build no, yes, ->
	exec "git checkout master; git add .; git commit -m \"#{ options.message }\"; git push origin master", (err, stdout, stderr) ->
		print(stdout) if stdout?
		print(stderr) if stderr?
		return if err?
		print("SUCCESS!");

option '-m', '--message [TEXT]', 'commit message'
task 'release', 'Compile, bundle and commit both master and gh-pages to GitHub', (options) -> build no, yes, ->
	exec "git checkout master; git add .; git commit -m \"#{ options.message }\"; git push origin master; git checkout gh-pages; git pull . master; git push origin gh-pages; git checkout master", (err, stdout, stderr) ->
		print(stdout) if stdout?
		print(stderr) if stderr?
		return if err?
		print("SUCCESS!");
