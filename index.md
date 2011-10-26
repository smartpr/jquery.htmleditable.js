---
layout: sponsored
---

Let's face it; [contenteditable](http://dev.w3.org/html5/spec/Overview.html#
attr-contenteditable) is pretty cool but a major pain to work with.
<dfn>htmleditable</dfn> is here to fix that by giving you an elegant API that
makes interacting with a contenteditable element browser-independent, flexible
and fun!

### Show me some code!

It's simple:

{% highlight js %}
$('#editable').htmleditable();
for (var i = 0; i < j; i++) window.alert("W00t!");                  char 80 -->
{% endhighlight %}

And then we have the other scenario in which you `inline some stuff that may
actually not fit on one line` so we have to deal with that as well...

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

Blub