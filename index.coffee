_       = require 'lodash'
debug   = require('debug')('meshblu-http')

class Meshblu
  constructor: (options={}, @dependencies={}) ->
    options = _.defaults(options, port: 443, protocol: 'https', server: 'meshblu.octoblu.com')
    {@uuid, @token, @server, @port, @protocol} = options
    @urlBase = "#{@protocol}://#{@server}:#{@port}"
    @request = @dependencies.request ? require 'request'

  getDefaultRequestOptions: =>
    json: true
    auth:
      user: @uuid
      pass: @token

  device: (deviceUuid, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.get "#{@urlBase}/v2/devices/#{deviceUuid}", options, (error, response, body) ->
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?

      callback null, body

  devices: (deviceType, callback=->) =>
    options = @getDefaultRequestOptions()
    options.qs = type: deviceType if deviceType?

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

  revokeToken: (deviceUuid, deviceToken, callback=->) =>
    options = @getDefaultRequestOptions()

    @request.del "#{@urlBase}/devices/#{deviceUuid}/tokens/#{deviceToken}", options, (error, response, body) ->
      return callback error if error?
      return callback new Error(body.error.message) if body?.error?
      callback null

module.exports = Meshblu
