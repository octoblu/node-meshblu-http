dns     = require 'dns'
_       = require 'lodash'
request = require 'request'
url     = require 'url'

class MeshbluRequest
  constructor: (options={}) ->
    @requestOptions      = options.request
    {@protocol, @hostname, @port, @resolveSrv} = options

  delete: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      request.delete uri, @_addDefaultOptions(options, {baseUrl}), callback

  get: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      request.get uri, @_addDefaultOptions(options, {baseUrl}), callback

  patch: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      request.patch uri, @_addDefaultOptions(options, {baseUrl}), callback

  post: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      request.post uri, @_addDefaultOptions(options, {baseUrl}), callback

  put: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      request.put uri, @_addDefaultOptions(options, {baseUrl}), callback

  _addDefaultOptions: (options, {baseUrl}) =>
    _.defaults {}, options, @requestOptions, {baseUrl}

  _resolveBaseUrl: (callback) =>
    return callback null, url.format {@protocol, @hostname, @port} unless @resolveSrv

    dns.resolveSrv "#{@protocol}.#{@hostname}", (error, addresses) =>
      return callback error if error?
      address = _.minBy addresses, 'priority'
      return callback new Error('SRV record found, but contained no valid addresses') unless address?
      return callback null, url.format {protocol: @protocol, hostname: address.name, port: address.port}

module.exports = MeshbluRequest
