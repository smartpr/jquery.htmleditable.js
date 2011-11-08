---
layout: sponsored
---

Let's face it; [contenteditable](http://dev.w3.org/html5/spec/Overview.html#
attr-contenteditable) is pretty cool but a major pain to work with.
<dfn>htmleditable</dfn> is here to fix that by giving you an elegant API that
makes interacting with a contenteditable element browser-independent, flexible
and fun!

### Work in progress

This site and the code that it describes has not been officially released yet!

### Show me some code!

It's simple:

{% highlight js %}
$('#editable').htmleditable();
{% endhighlight %}

### Engine, not editor

Aren't there plenty of attempts at web-based rich text editing out there? Sure,
but none of them is like htmleditable, for various reasons:

*   Flexible and multi-purpose because it is an engine with an elegant API (as
	opposed to a clunky attempt at cloning Microsoft Word 2003).
*   Guarantees tidy, valid and semantic HTML containing only tags that were
	explicitly allowed.
*   Capable of dealing with copy-paste from even the most hellacious of
	hellacious sources (yes I'm looking at you Microsoft Word).
*	Configurable and extensible.

### Browser support

We aim for support of the following browsers:

*	latest version of Chrome;
*	latest version of Safari;
*	latest version of Firefox;
*	Internet Explorer 8 and later.