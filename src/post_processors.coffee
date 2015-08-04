_ = require 'lodash'
async = require 'async'

processById = (processor, domElement, done) ->
  idSelector = "[data-element-id=#{processor.id}]"
  subElement = domElement.querySelector idSelector
  processor.callback subElement, done

processAll = (processor, domElement, done) ->
  processor.callback domElement, done

class PostProcessors
  constructor: ->
    @processors = []

  clear: ->
    @processors = []

  register: (callback) ->
    @processors.push type: "all", callback: callback

  registerElemenbById: (id, callback) ->
    @processors.push type: "id", id: id, callback: callback

  runProcessors: (domElement, done) ->
    callbacks = _.union [
      _(@processors).chain()
        .select type: "id"
        .map (p) -> _.partial processById, p, domElement, _
        .flatten()
        .value(),
      _(@processors).chain()
        .select type: "all"
        .map (p) -> _.partial processAll, p, domElement, _
        .flatten()
        .value()
    ]

    cbs = _.flatten callbacks
    async.parallel cbs, done

module.exports = PostProcessors
