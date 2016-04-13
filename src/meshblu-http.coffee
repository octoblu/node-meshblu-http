_       = require 'lodash'
debug   = require('debug')('meshblu-http')
stableStringify = require 'json-stable-stringify'

class MeshbluHttp
  @SUBSCRIPTION_TYPES = [
    'broadcast'
    'sent'
    'received'
    'config'
    "broadcast.received"
    "broadast.sent"
    "configure.received"
    "confiure.sent"
    "message.received"
    "message.sent"
  ]

  constructor: (options={}, @dependencies={}) ->
    options = _.defaults(_.cloneDeep(options), port: 443, server: 'meshblu.octoblu.com')
    {@uuid, @token, @server, @port, @protocol, @auth, @raw} = options
    @protocol = null if @protocol == 'websocket'
    try
      @port = parseInt @port
    catch e

    @protocol ?= 'http'
    @protocol = 'https' if @port == 443

    @urlBase = "#{@protocol}://#{@server}:#{@port}"
    @request = @dependencies.request ? require 'request'
    @NodeRSA = @dependencies.NodeRSA ? require 'node-rsa'

  getDefaultRequestOptions: =>
    _.extend json: true, @getAuthRequestOptions()

  getRawRequestOptions: =>
    headers = 'content-type' : 'application/json'
    _.extend json: false, headers: headers, @getAuthRequestOptions()

  getAuthRequestOptions: =>
    return auth: @auth if @auth?
    return {} unless @uuid && @token
    auth:
      user: @uuid
      pass: @token

  createSubscription: ({subscriberUuid, emitterUuid, type}, callback) =>
    url = @_subscriptionUrl {subscriberUuid, emitterUuid, type}
    requestOptions = @getDefaultRequestOptions()

    @request.post url, requestOptions, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  deleteSubscription: (options, callback) =>
    url = @_subscriptionUrl options
    requestOptions = @getDefaultRequestOptions()

    @request.delete url, requestOptions, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  _subscriptionUrl: (options) =>
    {subscriberUuid, emitterUuid, type} = options
    "#{@urlBase}/v2/devices/#{subscriberUuid}/subscriptions/#{emitterUuid}/#{type}"

  device: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/v2/devices/#{deviceUuid}", options, (error, response, body) =>
      debug "device", error, body
      @_handleResponse {error, response, body}, callback

  search: (query, metadata, callback) =>
    options = @getDefaultRequestOptions()
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers
    options.json = query
    @request.post "#{@urlBase}/search/devices", options, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  devices: (query={}, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_devices query, metadata, callback

  _devices: (query, metadata, callback=->) =>
    options = @getDefaultRequestOptions()
    options.qs = query

    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.get "#{@urlBase}/v2/devices", options, (error, response, body) =>
      debug "devices", error, body
      @_handleResponse {error, response, body}, callback

  subscriptions: (uuid, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}
    @_subscriptions uuid, metadata, callback

  _subscriptions: (uuid, metadata, callback=->) =>
    options = @getDefaultRequestOptions()
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.get "#{@urlBase}/v2/devices/#{uuid}/subscriptions", options, (error, response, body) =>
      debug "subscriptions", error, body
      @_handleResponse {error, response, body}, callback

  mydevices: (query={}, callback=->) =>
    options = @getDefaultRequestOptions()
    options.qs = query

    @request.get "#{@urlBase}/mydevices", options, (error, response, body) =>
      debug "mydevices", error, body
      @_handleResponse {error, response, body}, callback

  generateAndStoreToken: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.post "#{@urlBase}/devices/#{deviceUuid}/tokens", options, (error, response, body) =>
      debug "generateAndStoreToken", error, body
      @_handleResponse {error, response, body}, callback

  generateAndStoreTokenWithOptions: (deviceUuid, tokenOptions, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = tokenOptions if tokenOptions?
    @request.post "#{@urlBase}/devices/#{deviceUuid}/tokens", options, (error, response, body) =>
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

  publicKey: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/devices/#{deviceUuid}/publickey", options, (error, response, body) =>
      debug "publicKey", error, body
      @_handleResponse {error, response, body}, callback

  register: (device, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = device

    @request.post "#{@urlBase}/devices", options, (error, response, body={}) =>
      debug "register", error, body
      @_handleResponse {error, response, body}, callback

  resetToken: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()
    url = "#{@urlBase}/devices/#{deviceUuid}/token"
    @request.post url, options, (error, response, body) =>
      @_handleResponse {error, response, body}, callback

  revokeToken: (deviceUuid, deviceToken, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.del "#{@urlBase}/devices/#{deviceUuid}/tokens/#{deviceToken}", options, (error, response, body={}) =>
      debug "revokeToken", error, body
      @_handleResponse {error, response, body}, callback

  revokeTokenByQuery: (deviceUuid, query, callback=->) =>
    options = @getDefaultRequestOptions()
    options.qs = query

    @request.del "#{@urlBase}/devices/#{deviceUuid}/tokens", options, (error, response, body={}) =>
      debug "revokeToken", error, body
      @_handleResponse {error, response, body}, callback

  setPrivateKey: (privateKey) =>
    @privateKey = new @NodeRSA privateKey

  sign: (data) =>
    @privateKey.sign(stableStringify(data)).toString('base64')

  unregister: (device, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.del "#{@urlBase}/devices/#{device.uuid}", options, (error, response, body) =>
      debug "unregister", error, body
      @_handleResponse {error, response, body}, callback

  update: (uuid, params, rest...) =>
    [callback] = rest
    [metadata, callback] = rest if _.isPlainObject callback
    metadata ?= {}

    @_update uuid, params, metadata, callback

  _update: (uuid, params, metadata, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = params
    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    @request.patch "#{@urlBase}/v2/devices/#{uuid}", options, (error, response, body) =>
      debug "update", error, body
      @_handleResponse {error, response, body}, callback

  updateDangerously: (uuid, params, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = params

    @request.put "#{@urlBase}/v2/devices/#{uuid}", options, (error, response, body) =>
      debug "update", error, body
      @_handleResponse {error, response, body}, callback

  verify: (message, signature) =>
    @privateKey.verify stableStringify(message), signature, 'utf8', 'base64'

  whoami: (callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/v2/whoami", options, (error, response, body) =>
      debug "whoami", error, body
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
      options = @getRawRequestOptions()
      options.body = message
    else
      options = @getDefaultRequestOptions()
      options.json = message

    options.headers = _.extend {}, @_getMetadataHeaders(metadata), options.headers

    debug 'POST', "#{@urlBase}/messages", options

    @request.post "#{@urlBase}/messages", options, (error, response, body) =>
      debug "message", error, body
      return callback @_userError(500, error.message) if error?
      return callback @_userError(response.statusCode, body?.error) if body?.error?

      callback null, body

  _getMetadataHeaders: (metadata) =>
    _.transform metadata, (newMetadata, value, key) =>
      newMetadata["x-meshblu-#{_.kebabCase(key)}"] = @_possiblySerializeHeaderValue value
      return true

  #because request doesn't serialize arrays correctly for headers.
  _possiblySerializeHeaderValue: (value) =>
    return value if _.isString value
    return value if _.isBoolean value
    return value if _.isNumber value
    return JSON.stringify value

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    error

module.exports = MeshbluHttp
