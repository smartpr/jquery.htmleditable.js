---
layout: demo
---

Proof that <dfn>htmleditable</dfn> is Versatile -- yeah that's right, with a
capital *V*.

### Rich text area

It can be used as a `textarea` replacement, including resizing corner tip (in
browsers that have them on text areas).

{% include demo.area.html %}
<details>
<summary>Source</summary>
{% highlight html %}
{% include demo.area.html %}
{% endhighlight %}
</details>

### Rich text input

Similar to the rich text area, we can mimic a regular text input. Note the
auto-resizing coolness!

{% include demo.input.html %}
<details>
<summary>Source</summary>
{% highlight html %}
{% include demo.input.html %}
{% endhighlight %}
</details>

### Simple rich text editor

Or leverage the fact that we are dealing with a regular block element and let
it fit the content. (An entirely browser-powered auto-resizing text area, how
cool is that?!)

{% include demo.simple.html %}
<details>
<summary>Source</summary>
{% highlight html %}
{% include demo.simple.html %}
{% endhighlight %}
</details>

### Word processor wannabe

&hellip;

### Inline editing

{% include demo.inline.html %}
<details>
<summary>Source</summary>
{% highlight html %}
{% include demo.inline.html %}
{% endhighlight %}
</details>
