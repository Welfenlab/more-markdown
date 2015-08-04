
# simple callback list factory that
_ = require 'lodash'

module.exports = () ->
  callbacks = [];

  clear: () ->
    callbacks = []
  registerCallback: (cb,thisPtr=null) ->
    callbacks.push [cb, thisPtr]
  fire: (args...) ->
    _.each callbacks, (c) ->
      c[0].apply c[1], args
