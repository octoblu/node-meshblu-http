_       = require 'lodash'
request = require 'request'

class MeshbluRequest
  constructor: (options={}) ->
    @requestOptions      = options.request
    {hostname, protocol} = options

    @srvUrl = "#{protocol}.#{hostname}"

  delete: (uri, options, callback) =>
    request.delete uri, @_addDefaultOptionss(options), callback

  get: (uri, options, callback) =>
    request.get uri, @_addDefaultOptionss(options), callback

  patch: (uri, options, callback) =>
    request.patch uri, @_addDefaultOptionss(options), callback

  post: (uri, options, callback) =>
    request.post uri, @_addDefaultOptionss(options), callback

  put: (uri, options, callback) =>
    request.put uri, @_addDefaultOptionss(options), callback

  _addDefaultOptionss: (options) =>
    _.defaults {}, options, @requestOptions


module.exports = MeshbluRequest
