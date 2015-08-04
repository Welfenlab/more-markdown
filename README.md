# more-markdown

A small sized markdown engine based on
[markdown-it](https://github.com/markdown-it/markdown-it)
that simplifies writing plugins that need DOM access like MathJax etc.

It creates a double buffered output to prevent too much flicker when updating.

# Installation

Via npm

```
npm install more-markdown
```

# Usage

```
var moreMarkdown = require('more-markdown');
var plugin = require( ... );

// create a processor that writes the final html
// to the element with the id 'output'
var proc = moreMarkdown.create('output', processors: [plugin]);

proc.render("# Test Markdown!");
```
