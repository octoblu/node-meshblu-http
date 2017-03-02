dns         = require 'dns'
_           = require 'lodash'
request     = require 'request'
SrvFailover = require 'srv-failover'
url         = require 'url'

class MeshbluRequest
  constructor: (options={}, dependencies={}) ->
    {@dns, @request} = dependencies

    @request ?= request

    @requestOptions = options.request
    {@protocol, @hostname, @port} = options
    {service, domain, secure, resolveSrv} = options

    return unless resolveSrv
    protocol = 'https'
    protocol = 'http' if secure == false

    @srvFailover = new SrvFailover {service, domain, protocol}, {dns: dependencies.dns ? dns}

  delete: (uri, options, callback) =>
    @_doRequest {method: 'delete', uri, options}, callback

  get: (uri, options, callback) =>
    @_doRequest {method: 'get', uri, options}, callback

  patch: (uri, options, callback) =>
    @_doRequest {method: 'patch', uri, options}, callback

  post: (uri, options, callback) =>
    @_doRequest {method: 'post', uri, options}, callback

  put: (uri, options, callback) =>
    @_doRequest {method: 'put', uri, options}, callback

  _addDefaultOptions: (options, {method, uri, baseUrl}) =>
    _.defaults {}, options, @requestOptions, {method, uri, baseUrl}

  _doRequest: ({method, uri, options}, callback) =>
    @_resolveBaseUrl uri, (error, baseUrl) =>
      return callback error if error?
      return @request @_addDefaultOptions(options, {method, uri, baseUrl}), callback

  _resolveBaseUrl: (uri, callback) =>
    return callback null, url.format {@protocol, @hostname, @port} unless @srvFailover?

    @srvFailover.resolveUrl (error, baseUrl) =>
      return callback error if error?

      @request {baseUrl, uri, method: 'options'}, (error, response) =>
        if error? || response.statusCode != 204
          @srvFailover.markBadUrl baseUrl, ttl: 60000
          return @_resolveBaseUrl uri, callback
        return callback null, baseUrl

module.exports = MeshbluRequest
