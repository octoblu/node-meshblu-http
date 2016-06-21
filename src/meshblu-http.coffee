_     = require 'lodash'
url   = require 'url'
debug = require('debug')('meshblu-http')
stableStringify = require 'json-stable-stringify'
MeshbluRequest  = require './meshblu-request.coffee'

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
    options = _.defaults _.cloneDeep(options), protocol: 'https', hostname: 'meshblu.octoblu.com'
    {
      uuid
      token
      hostname
      port
      protocol
      resolveSrv
      auth
      @raw
      @keepAlive
    } = options
    @keepAlive ?= true
    auth ?= {username: uuid, password: token} if uuid? || token?

    @protocol ?= 'https'
    throw new Error('protocol must be one of http/https/<null>') unless _.includes ['http', 'https'], @protocol

    try port = parseInt port

    {@request, @NodeRSA} = @dependencies
    @request ?= new MeshbluRequest {protocol, hostname, port, resolveSrv, request: {auth}}
    @NodeRSA ?= require 'node-rsa'

  authenticate: (callback) =>
    options = @_getDefaultRequestOptions()

    @request.post "/authenticate", options, (error, response, body) =>
      debug "authenticate", error, body
      return callback @_userError(500, error.message) if error?
      return callback @_userError(response.statusCode, body?.error) if body?.error?
      return callback @_userError(response.statusCode, body) if response.statusCode >= 400

      callback null, body

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

  device: (deviceUuid, callback=->) =>
    options = @_getDefaultRequestOptions()

    @request.get "/v2/devices/#{deviceUuid}", options, (error, response, body) =>
      debug "device", error, body
      @_handleResponse {error, response, body}, callback

  devices: (query={}, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_devices query, metadata, callback

  generateAndStoreToken: (deviceUuid, callback=->) =>
    options = @_getDefaultRequestOptions()

    @request.post "/devices/#{deviceUuid}/tokens", options, (error, response, body) =>
      debug "generateAndStoreToken", error, body
      @_handleResponse {error, response, body}, callback

  generateAndStoreTokenWithOptions: (deviceUuid, tokenOptions, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.json = tokenOptions if tokenOptions?
    @request.post "/devices/#{deviceUuid}/tokens", options, (error, response, body) =>
      debug "generateAndStoreToken", error, body
      @_handleResponse {error, response, body}, callback

  generateKeyPair: =>
    key = new @NodeRSA()
    key.generateKeyPair()

    privateKey: key.exportKey('private'), publicKey: key.exportKey('public')

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

  updateDangerously: (uuid, params, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.json = params

    @request.put "/v2/devices/#{uuid}", options, (error, response, body) =>
      debug "update", error, body
      @_handleResponse {error, response, body}, callback

  verify: (message, signature) =>
    @privateKey.verify stableStringify(message), signature, 'utf8', 'base64'

  whoami: (callback=->) =>
    options = @_getDefaultRequestOptions()

    @request.get "/v2/whoami", options, (error, response, body) =>
      debug "whoami", error, body
      @_handleResponse {error, response, body}, callback

  _devices: (query, metadata, callback=->) =>
    options = @_getDefaultRequestOptions()
    options.qs = query

    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.get "/v2/devices", options, (error, response, body) =>
      debug "devices", error, body
      @_handleResponse {error, response, body}, callback

  _getDefaultRequestOptions: =>
    return {
      json: true
      forever: @keepAlive
    }

  _getMetadataHeaders: (metadata) =>
    _.transform metadata, (newMetadata, value, key) =>
      kebabKey = _.kebabCase key
      newMetadata["x-meshblu-#{kebabKey}"] = @_possiblySerializeHeaderValue value
      return true
    , {}

  _getRawRequestOptions: =>
    return {
      json: false,
      headers:
        'content-type': 'application/json'
    }

  _handleError: ({message, code}, callback) =>
    message ?= 'Unknown Error Occurred'
    error = @_userError code, message
    callback error

  _handleResponse: ({error, response, body}, callback) =>
    return @_handleError message: error.message, callback if error?

    if response.headers?['x-meshblu-error']?
      error = JSON.parse response.headers['x-meshblu-error']
      return @_handleError message: error.message, code: response.statusCode, callback

    if body?.error?
      return @_handleError message: body.error, code: response.statusCode, callback

    if response.statusCode >= 400
      return @_handleError code: response.statusCode, message: body, callback

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
      return callback @_userError(500, error.message) if error?
      return callback @_userError(response.statusCode, body?.error) if body?.error?

      callback null, body

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

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    error

module.exports = MeshbluHttp
