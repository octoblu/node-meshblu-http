dns       = require 'dns'
_         = require 'lodash'
request   = require 'request'
url       = require 'url'
debug     = require('debug')('meshblu-http:meshblu-request')

class MeshbluRequest
  constructor: (options={}) ->
    @requestOptions = options.request
    {@protocol, @hostname, @port, @resolveSrv} = options
    throw new Error('Missing required argument: protocol') unless @protocol?

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

  _getDomain: =>
    parts       = _.split @hostname, '.'
    domainParts = _.takeRight parts, 2
    return _.join domainParts, '.'

  _getSrvAddress: =>
    domain = @_getDomain()
    subdomain = @_getSubdomain()
    return "_#{subdomain}._#{@protocol}.#{domain}"

  _getSubdomain: =>
    parts          = _.split @hostname, '.'
    subdomainParts = _.dropRight parts, 2
    return _.join subdomainParts, '.'

  _resolveBaseUrl: (callback) =>
    debug '_resolveBaseUrl'
    return callback null, url.format {@protocol, @hostname, @port} unless @resolveSrv

    srvAddress = @_getSrvAddress()
    debug 'resolve srv from:', srvAddress
    dns.resolveSrv srvAddress, (error, addresses) =>
      return callback error if error?
      address = _.minBy addresses, 'priority'
      return callback new Error('SRV record found, but contained no valid addresses') unless address?
      debug 'resolved srv to: ', JSON.stringify(address)
      return callback null, url.format {protocol: @protocol, hostname: address.name, port: address.port}

module.exports = MeshbluRequest
