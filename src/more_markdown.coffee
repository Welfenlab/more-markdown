MarkdownIt = require 'markdown-it'
cbo = require './callback_objects'
PostProcessors = require './post_processors'
_ = require 'lodash'

createDoubleBuffer = (element_id, config) ->
  element = document.querySelector "##{element_id}"
  element.innerHTML = "<div activeBuffer></div><div invisibleBuffer></div>"
  return element

getParts = (element) ->
  active = element.querySelectorAll "[activeBuffer]"
  invisible = element.querySelectorAll "[invisibleBuffer]"

  [active[0], invisible[0]]

finishOnceAsync = (cbo) ->
  (done) ->
    cbo.registerCallback once done

# swaps the current buffer with the currently processed one
swap = (active, buffer) ->
  active.removeAttribute "activeBuffer"
  active.setAttribute "invisibleBuffer", ""
  active.style.display = "none"
  buffer.setAttribute "activeBuffer", ""
  buffer.removeAttribute "invisibleBuffer"
  buffer.style.display = "block"

  # creates an advanced markdown processor for that specific dom element
  # does some magic to remove flickering etc.
module.exports =
  create: (element_id, config) ->
    activeProcessors = config.processors

    mdInstance = new MarkdownIt config
    postProcessors = new PostProcessors()

    mdInstance.domReady = cbo()
    # register processors
    events = _(activeProcessors).chain()
      .map (p) ->
        p.register mdInstance, postProcessors
      .map _.pairs
      .flatten()
      .object()
      .value()

    preprocessors = _(activeProcessors).chain()
      .map ".preprocessor"
      .compact()
      .value()

    element = null

    clearEvent: (event) ->
      events[event]?.clearCallbacks()
    hasEvent: (event) ->
      events[event]?
    on: (event, callback, thisArg=null) ->
      events[event]?.registerCallback callback, thisArg
    listEvents: () ->
      _.keys events
    parse: (markdown) ->
      # run the markdown through all preprocessors
      # (considered bad.. but currently necessary for single $ mathjax escapes)
      processedMD = _.reduce preprocessors, ((md, p) -> p md), markdown

      # start parsing
      mdInstance.parse processedMD
    parseInline: (markdown) ->
      # run the markdown through all preprocessors
      # (considered bad.. but currently necessary for single $ mathjax escapes)
      processedMD = _.reduce preprocessors, ((md, p) -> p md), markdown

      # start parsing
      mdInstance.parseInline processedMD
    render: (markdown) ->
      # ensure that we have a valid element
      element = element or createDoubleBuffer element_id
      if not element then return
      [active, buffer] = getParts element

      # clear all postProcessors
      postProcessors.clear()

      # run the markdown through all preprocessors
      # (considered bad.. but currently necessary for single $ mathjax escapes)
      processedMD = _.reduce preprocessors, ((md, p) -> p md), markdown

      # start rendering
      html = mdInstance.render processedMD
      buffer.innerHTML = html

      mdInstance.domReady.fire()

      # start post-processing
      postProcessors.runProcessors buffer, _.partial swap, active, buffer