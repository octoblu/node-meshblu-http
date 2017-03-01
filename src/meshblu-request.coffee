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
    protocol = 'http'
    protocol = 'https' if secure

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
    @_resolveBaseUrl (error, baseUrl) =>
      return callback error if error?

      @request {baseUrl, uri, method: 'options'}, (error, response) =>
        return @_retrySrvRequest(error, baseUrl, {method, uri, options}, callback) if error || response.statusCode != 204
        return @request @_addDefaultOptions(options, {method, uri, baseUrl}), callback

  _resolveBaseUrl: (callback) =>
    return callback null, url.format {@protocol, @hostname, @port} unless @srvFailover?
    @srvFailover.resolveUrl callback

  _retrySrvRequest: (error, baseUrl, opts, callback) =>
    return callback error unless @srvFailover?
    @srvFailover.markBadUrl baseUrl, ttl: 60000
    return @_doRequest opts, callback

module.exports = MeshbluRequest
