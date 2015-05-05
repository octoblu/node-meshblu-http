_       = require 'lodash'
debug   = require('debug')('meshblu-http')

class Meshblu
  constructor: (options={}, @dependencies={}) ->
    options = _.defaults(_.cloneDeep(options), port: 443, protocol: 'https', server: 'meshblu.octoblu.com')
    {@uuid, @token, @server, @port, @protocol} = options
    try
      @port = parseInt @port
    catch e

    @protocol = 'https' if @port == 443
    @protocol = 'http' if @port == 80

    @urlBase = "#{@protocol}://#{@server}:#{@port}"
    @request = @dependencies.request ? require 'request'

  getDefaultRequestOptions: =>
    _.extend json: true, @getAuthRequestOptions()

  getAuthRequestOptions: =>
    return {} unless @uuid && @token
    auth:
      user: @uuid
      pass: @token

  device: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/v2/devices/#{deviceUuid}", options, (error, response, body) ->
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      return callback new Error(body.message || body) if response.statusCode != 200

      callback null, body

  devices: (query={}, callback=->) =>
    options = @getDefaultRequestOptions()
    options.qs = query

    @request.get "#{@urlBase}/devices", options, (error, response, body) ->
      return callback error if error?
      return callback new Error(body.error) if body?.error?

      callback null, body

  generateAndStoreToken: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.post "#{@urlBase}/devices/#{deviceUuid}/tokens", options, (error, response, body) ->
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?

      callback null, body

  message: (message, callback=->) =>
    options = @getDefaultRequestOptions()
    options.json = message

    debug 'POST', "#{@urlBase}/messages", options
    @request.post "#{@urlBase}/messages", options, (error, response, body) ->
      return callback error if error?
      return callback new Error(body.error) if body?.error?

      callback null, body

  revokeToken: (deviceUuid, deviceToken, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.del "#{@urlBase}/devices/#{deviceUuid}/tokens/#{deviceToken}", options, (error, response, body) ->
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      callback null

module.exports = Meshblu
