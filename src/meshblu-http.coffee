_       = require 'lodash'
debug   = require('debug')('meshblu-http')
stableStringify = require 'json-stable-stringify'

class MeshbluHttp
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

  createSubscription: (options, callback) =>
    url = @_subscriptionUrl options
    requestOptions = @getDefaultRequestOptions()

    @request.post url, requestOptions, (error, response, body) =>
      return callback new Error(body?.error ? 'Unknown Error Occurred') if response.statusCode != 204
      callback()

  deleteSubscription: (options, callback) =>
    url = @_subscriptionUrl options
    requestOptions = @getDefaultRequestOptions()

    @request.delete url, requestOptions, (error, response, body) =>
      return callback new Error(body?.error ? 'Unknown Error Occurred') if response.statusCode != 204
      callback()

  _subscriptionUrl: (options) =>
    {subscriberId, emitterId, type} = options
    "#{@urlBase}/v2/devices/#{subscriberId}/subscriptions/#{emitterId}/#{type}"

  device: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/v2/devices/#{deviceUuid}", options, (error, response, body) ->
      debug "device", error, body
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      return callback new Error(body.message || body) if response.statusCode != 200

      callback null, body

  devices: (query={}, callback=->) =>
    options = @getDefaultRequestOptions()
    options.qs = query

    @request.get "#{@urlBase}/devices", options, (error, response, body) ->
      debug "devices", error, body
      return callback error if error?
      return callback new Error(body.error) if body?.error?

      callback null, body

  mydevices: (query={}, callback=->) =>
    options = @getDefaultRequestOptions()
    options.qs = query

    @request.get "#{@urlBase}/mydevices", options, (error, response, body) ->
      debug "mydevices", error, body
      return callback error if error?
      return callback new Error(body.error) if body?.error?

      callback null, body

  generateAndStoreToken: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.post "#{@urlBase}/devices/#{deviceUuid}/tokens", options, (error, response, body) ->
      debug "generateAndStoreToken", error, body
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?

      callback null, body

  generateKeyPair: =>
    key = new @NodeRSA()
    key.generateKeyPair()

    privateKey: key.exportKey('private'), publicKey: key.exportKey('public')

  message: (message, callback) =>
    if @raw
      options = @getRawRequestOptions()
      options.body = message
    else
      options = @getDefaultRequestOptions()
      options.json = message

    debug 'POST', "#{@urlBase}/messages", options

    return @request.post "#{@urlBase}/messages", options unless callback?

    @request.post "#{@urlBase}/messages", options, (error, response, body) ->
      debug "message", error, body
      return callback error if error?
      return callback new Error(body.error) if body?.error?

      callback null, body

  publicKey: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/devices/#{deviceUuid}/publickey", options, (error, response, body) ->
      debug "publicKey", error, body
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      return callback new Error(body.message || body) if response.statusCode != 200

      callback null, body

  register: (device, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = device

    @request.post "#{@urlBase}/devices", options, (error, response, body) ->
      debug "register", error, body
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      callback null, body

  resetToken: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()
    url = "#{@urlBase}/devices/#{deviceUuid}/token"
    @request.post url, options, (error, response, body) =>
      return callback error if error?
      return callback new Error body.error unless response.statusCode == 201

      callback null, body

  revokeToken: (deviceUuid, deviceToken, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.del "#{@urlBase}/devices/#{deviceUuid}/tokens/#{deviceToken}", options, (error, response, body) ->
      debug "revokeToken", error, body
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      callback null

  setPrivateKey: (privateKey) =>
    @privateKey = new @NodeRSA privateKey

  sign: (data) =>
    @privateKey.sign(stableStringify(data)).toString('base64')

  unregister: (device, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.del "#{@urlBase}/devices/#{device.uuid}", options, (error, response, body) ->
      debug "unregister", error, body
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      callback null

  update: (uuid, params, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = params

    @request.patch "#{@urlBase}/v2/devices/#{uuid}", options, (error, response, body) ->
      debug "update", error, body
      return callback error if error?
      return callback new Error(body.error) unless response.statusCode == 204
      callback null, body

  updateDangerously: (uuid, params, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = params

    @request.put "#{@urlBase}/v2/devices/#{uuid}", options, (error, response, body) ->
      debug "update", error, body
      return callback error if error?
      return callback new Error(body.error) unless response.statusCode == 204
      callback null, body

  verify: (message, signature) =>
    @privateKey.verify stableStringify(message), signature, 'utf8', 'base64'

  whoami: (callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/v2/whoami", options, (error, response, body) ->
      debug "whoami", error, body
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      return callback new Error(body.message || body) if response.statusCode != 200

      callback null, body

module.exports = MeshbluHttp
