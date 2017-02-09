_     = require 'lodash'
url   = require 'url'
debug = require('debug')('meshblu-http')
stableStringify = require 'json-stable-stringify'

class MeshbluHttp
  @SUBSCRIPTION_TYPES = [
    'broadcast'
    'sent'
    'received'
    'config'
    "broadcast.received"
    "broadcast.sent"
    "configure.received"
    "configure.sent"
    "message.received"
    "message.sent"
  ]

  constructor: (options={}, @dependencies={}) ->
    options = _.cloneDeep options
    {
      uuid
      token
      hostname
      port
      protocol
      domain
      service
      secure
      resolveSrv
      auth
      @raw
      @keepAlive
      @gzip
      @timeout
      @serviceName
    } = options
    @keepAlive ?= true
    @gzip ?= true

    throw new Error 'a uuid is provided but the token is not' if uuid? && !token?
    throw new Error 'a token is provided but the uuid is not' if token? && !uuid?

    auth ?= {username: uuid, password: token} if uuid? && token?

    {request, @MeshbluRequest, @NodeRSA} = @dependencies
    @MeshbluRequest ?= require './meshblu-request'
    @NodeRSA        ?= require 'node-rsa'
    @request = @_buildRequest {request, protocol, hostname, port, service, domain, secure, resolveSrv, auth}

  authenticate: (callback) =>
    options = @_getDefaultRequestOptions()

    @request.post "/authenticate", options, (error, response, body) =>
      debug "authenticate", error, body
      @_handleResponse {error, response, body}, callback

  createHook: (uuid, type, url, callback) =>
    error = new Error "Hook type not supported. supported types are: #{MeshbluHttp.SUBSCRIPTION_TYPES.join ', '}"
    return callback error unless type in MeshbluHttp.SUBSCRIPTION_TYPES

    updateRequest =
      $addToSet:
        "meshblu.forwarders.#{type}":
          type: 'webhook'
          url: url
          method: 'POST',
          generateAndForwardMeshbluCredentials: true

    @updateDangerously(uuid, updateRequest, callback)

  createSubscription: ({subscriberUuid, emitterUuid, type}, callback) =>
    url = @_subscriptionUrl {subscriberUuid, emitterUuid, type}
    requestOptions = @_getDefaultRequestOptions()

    @request.post url, requestOptions, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  deleteSubscription: (options, callback) =>
    url = @_subscriptionUrl options
    requestOptions = @_getDefaultRequestOptions()

    @request.delete url, requestOptions, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  device: (uuid, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}
    @_device uuid, metadata, callback

  _device: (uuid, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.get "/v2/devices/#{uuid}", options, (error, response, body) =>
      debug "device", error, body
      @_handleResponse {error, response, body}, callback

  devices: (query={}, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_devices query, metadata, callback

  findAndUpdate: (uuid, params, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    options = @_getDefaultRequestOptions()
    options.json = params
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.put "/v2/devices/#{uuid}/find-and-update", options, (error, response, body) =>
      debug "update", error, body
      @_handleResponse {error, response, body}, callback

  generateAndStoreToken: (uuid, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}
    params = true
    @_generateAndStoreToken uuid, params, metadata, callback

  generateAndStoreTokenWithOptions: (uuid, params, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_generateAndStoreToken uuid, params, metadata, callback

  _generateAndStoreToken: (uuid, params, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.json = params
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers
    @request.post "/devices/#{uuid}/tokens", options, (error, response, body) =>
      debug "generateAndStoreToken", error, body
      @_handleResponse {error, response, body}, callback

  generateKeyPair: =>
    key = new @NodeRSA()
    key.generateKeyPair()

    privateKey: key.exportKey('private'), publicKey: key.exportKey('public')

  healthcheck: (callback=->) =>
    options = @_getDefaultRequestOptions()
    @request.get '/healthcheck', options, (error, response) =>
      return callback error if error?
      healthy = response.statusCode == 200
      return callback null, healthy, response.statusCode

  message: (message, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_message message, metadata, callback

  mydevices: (query={}, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.qs = query

    @request.get "/mydevices", options, (error, response, body) =>
      debug "mydevices", error, body
      @_handleResponse {error, response, body}, callback

  publicKey: (deviceUuid, callback=->) =>
    options = @_getDefaultRequestOptions()

    @request.get "/devices/#{deviceUuid}/publickey", options, (error, response, body) =>
      debug "publicKey", error, body
      @_handleResponse {error, response, body}, callback

  register: (device, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.json = device

    @request.post "/devices", options, (error, response, body={}) =>
      debug "register", error, body
      @_handleResponse {error, response, body}, callback

  resetToken: (deviceUuid, callback=->) =>
    options = @_getDefaultRequestOptions()
    url = "/devices/#{deviceUuid}/token"
    @request.post url, options, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  revokeToken: (deviceUuid, deviceToken, callback=->) =>
    options = @_getDefaultRequestOptions()

    @request.delete "/devices/#{deviceUuid}/tokens/#{deviceToken}", options, (error, response, body={}) =>
      debug "revokeToken", error, body
      @_handleResponse {error, response, body}, callback

  revokeTokenByQuery: (deviceUuid, query, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.qs = query

    @request.delete "/devices/#{deviceUuid}/tokens", options, (error, response, body={}) =>
      debug "revokeToken", error, body
      @_handleResponse {error, response, body}, callback

  search: (query, metadata, callback) =>
    options = @_getDefaultRequestOptions()
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers
    options.json = query
    @request.post "/search/devices", options, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  searchTokens: (query, metadata, callback) =>
    options = @_getDefaultRequestOptions()
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers
    options.json = query
    @request.post "/search/tokens", options, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  setPrivateKey: (privateKey) =>
    @privateKey = new @NodeRSA privateKey

  sign: (data) =>
    @privateKey.sign(stableStringify(data)).toString('base64')

  subscriptions: (uuid, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}
    @_subscriptions uuid, metadata, callback

  unregister: (device, callback=->) =>
    options = @_getDefaultRequestOptions()

    @request.delete "/devices/#{device.uuid}", options, (error, response, body) =>
      debug "unregister", error, body
      @_handleResponse {error, response, body}, callback

  update: (uuid, params, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_update uuid, params, metadata, callback

  updateDangerously: (uuid, params, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_updateDangerously uuid, params, metadata, callback

  _updateDangerously: (uuid, params, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.json = params
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.put "/v2/devices/#{uuid}", options, (error, response, body) =>
      debug "updated", uuid, params
      debug "update", error, body
      @_handleResponse {error, response, body}, callback

  verify: (message, signature) =>
    @privateKey.verify stableStringify(message), signature, 'utf8', 'base64'

  whoami: (callback=->) =>
    options = @_getDefaultRequestOptions()

    @request.get "/v2/whoami", options, (error, response, body) =>
      debug "whoami", error, body
      @_handleResponse {error, response, body}, callback

  _assertNoSrv: ({service, domain, secure}) =>
    throw new Error('domain property only applies when resolveSrv is true')  if domain?
    throw new Error('service property only applies when resolveSrv is true') if service?
    throw new Error('secure property only applies when resolveSrv is true')  if secure?

  _assertNoUrl: ({protocol, hostname, port}) =>
    throw new Error('protocol property only applies when resolveSrv is false') if protocol?
    throw new Error('hostname property only applies when resolveSrv is false') if hostname?
    throw new Error('port property only applies when resolveSrv is false')     if port?

  _buildRequest: ({request, protocol, hostname, port, service, domain, secure, resolveSrv, auth}) =>
    return request if request?

    return @_buildSrvRequest({protocol, hostname, port, service, domain, secure, auth}) if resolveSrv
    return @_buildUrlRequest({protocol, hostname, port, service, domain, secure, auth})

  _buildSrvRequest: ({protocol, hostname, port, service, domain, secure, auth}) =>
    @_assertNoUrl({protocol, hostname, port})
    service ?= 'meshblu'
    domain ?= 'octoblu.com'
    secure ?= true
    request = {}
    request.auth = auth if auth?
    request.timeout = @timeout if @timeout?
    return new @MeshbluRequest {resolveSrv: true, service, domain, secure, request}

  _buildUrlRequest: ({protocol, hostname, port, service, domain, secure, auth}) =>
    @_assertNoSrv({service, domain, secure})
    protocol ?= 'https'
    hostname ?= 'meshblu.octoblu.com'
    port     ?= 443
    try port = parseInt port
    request = {}
    request.auth = auth if auth?
    request.timeout = @timeout if @timeout?
    return new @MeshbluRequest {resolveSrv: false, protocol, hostname, port, request }

  _devices: (query, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.qs = query

    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.get "/v2/devices", options, (error, response, body) =>
      debug "devices", error, body
      @_handleResponse {error, response, body}, callback

  _getDefaultHeaders: =>
    return unless @serviceName?
    return {
      'x-meshblu-service-name': @serviceName
    }

  _getDefaultRequestOptions: =>
    headers = @_getDefaultHeaders()
    options = {
      json: true
      forever: @keepAlive
      gzip: @gzip
    }
    options.headers = headers if headers?
    return options

  _getMetadataHeaders: (metadata) =>
    _.transform metadata, (newMetadata, value, key) =>
      kebabKey = _.kebabCase key
      newMetadata["x-meshblu-#{kebabKey}"] = @_possiblySerializeHeaderValue value
      return true
    , {}

  _getRawRequestOptions: =>
    headers = @_getDefaultHeaders() ? {}
    headers['content-type'] = 'application/json'
    return {
      json: false
      headers
    }

  _handleError: ({message,code,response}, callback) =>
    message ?= 'Unknown Error Occurred'
    response = response?.toJSON?()
    debug 'handling error', JSON.stringify({ message, code, response }, null, 2)
    error = @_userError code, message, response
    callback error

  _handleResponse: ({error, response, body}, callback) =>
    return @_handleError { message: error.message, code: error?.code, response }, callback if error?
    code = response?.statusCode

    if response?.headers?['x-meshblu-error']?
      error = JSON.parse response.headers['x-meshblu-error']
      return @_handleError { message: error.message, response, code }, callback

    if body?.error?
      return @_handleError { message: body.error, response, code }, callback

    if code >= 400
      message = body if _.isString body
      message ?= "Invalid Response Code #{code}"
      return @_handleError { message, response, code }, callback

    callback null, body


  _message: (message, metadata, callback=->) =>
    if @raw
      options = @_getRawRequestOptions()
      options.body = message
    else
      options = @_getDefaultRequestOptions()
      options.json = message

    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    debug 'POST', "/messages", options

    @request.post "/messages", options, (error, response, body) =>
      debug "message", error, body
      @_handleResponse {error, response, body}, callback

  # because request doesn't serialize arrays correctly for headers.
  _possiblySerializeHeaderValue: (value) =>
    return value if _.isString value
    return value if _.isBoolean value
    return value if _.isNumber value
    return JSON.stringify value

  _subscriptions: (uuid, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.get "/v2/devices/#{uuid}/subscriptions", options, (error, response, body) =>
      debug "subscriptions", error, body
      @_handleResponse {error, response, body}, callback

  _subscriptionUrl: (options) =>
    {subscriberUuid, emitterUuid, type} = options
    "/v2/devices/#{subscriberUuid}/subscriptions/#{emitterUuid}/#{type}"

  _update: (uuid, params, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.json = params
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.patch "/v2/devices/#{uuid}", options, (error, response, body) =>
      debug "update", error, body
      @_handleResponse {error, response, body}, callback

  _userError: (code, message, response) =>
    error = new Error message
    error.code = code
    error.response = response if response?
    error

module.exports = MeshbluHttp
