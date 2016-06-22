dns       = require 'dns'
_         = require 'lodash'
request   = require 'request'
url       = require 'url'
debug     = require('debug')('meshblu-http:meshblu-request')

class MeshbluRequest
  constructor: (options={}, dependencies={}) ->
    {@dns, @request} = dependencies
    @dns ?= dns
    @request ?= request

    @requestOptions = options.request
    {@protocol, @hostname, @port} = options
    {@service, @domain, @secure, @resolveSrv} = options

  delete: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      @request.delete uri, @_addDefaultOptions(options, {baseUrl}), callback

  get: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      @request.get uri, @_addDefaultOptions(options, {baseUrl}), callback

  patch: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      @request.patch uri, @_addDefaultOptions(options, {baseUrl}), callback

  post: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      @request.post uri, @_addDefaultOptions(options, {baseUrl}), callback

  put: (uri, options, callback) =>
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?
      @request.put uri, @_addDefaultOptions(options, {baseUrl}), callback

  _addDefaultOptions: (options, {baseUrl}) =>
    _.defaults {}, options, @requestOptions, {baseUrl}

  _getDomain: =>
    parts       = _.split @hostname, '.'
    domainParts = _.takeRight parts, 2
    return _.join domainParts, '.'

  _getSrvAddress: =>
    return "_#{@service}._#{@_getSrvProtocol()}.#{@domain}"

  _getSrvProtocol: =>
    return 'https' if @secure
    return 'http'

  _getSubdomain: =>
    parts          = _.split @hostname, '.'
    subdomainParts = _.dropRight parts, 2
    return _.join subdomainParts, '.'

  _resolveBaseUrl: (callback) =>
    return callback null, url.format {@protocol, @hostname, @port} unless @resolveSrv

    @dns.resolveSrv @_getSrvAddress(), (error, addresses) =>
      return callback error if error?
      return callback new Error('SRV record found, but contained no valid addresses') if _.isEmpty addresses
      return callback null, @_resolveUrlFromAddresses(addresses)

  _resolveUrlFromAddresses: (addresses) =>
    address = _.minBy addresses, 'priority'
    return url.format {
      protocol: @_getSrvProtocol()
      hostname: address.name
      port: address.port
    }


module.exports = MeshbluRequest
