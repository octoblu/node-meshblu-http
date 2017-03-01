{beforeEach, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'
MeshbluRequest = require '../src/meshblu-request'

describe 'MeshbluRequest', ->
  describe 'SRV resolve', ->
    describe 'when constructed with resolveSrv and secure true', ->
      beforeEach ->
        @dns = resolveSrv: sinon.stub()
        @request = sinon.stub()
        @request.get = sinon.stub()

        options = resolveSrv: true, service: 'meshblu', domain: 'octoblu.com', secure: true
        dependencies = {@dns, @request}

        @sut = new MeshbluRequest options, dependencies

      describe 'when one of the methods is called', ->
        beforeEach 'making the request', (done) ->
          @dns.resolveSrv.withArgs('_meshblu._https.octoblu.com').yields null, [{
            name: 'mesh.biz'
            port: 34
            priority: 1
            weight: 100
          }]
          @request.yields null, statusCode: 204
          @sut.get '/foo', {}, done

        it 'should call request with the resolved url', ->
          expect(@request).to.have.been.calledWith {method: 'get', baseUrl: 'https://mesh.biz:34', uri: '/foo'}

    describe 'when constructed with resolveSrv and secure false', ->
      beforeEach ->
        @dns = resolveSrv: sinon.stub()
        @request = sinon.stub()

        options = resolveSrv: true, service: 'meshblu', domain: 'octoblu.com', secure: false
        dependencies = {@dns, @request}

        @sut = new MeshbluRequest options, dependencies

      describe 'when one of the methods is called', ->
        beforeEach 'making the request', (done) ->
          @dns.resolveSrv.withArgs('_meshblu._http.octoblu.com').yields null, [{
            name: 'insecure.xxx'
            port: 80
            priority: 1
            weight: 100
          }]
          @request.yields null, statusCode: 204
          @sut.get '/foo', {}, done

        it 'should call request with the resolved url', ->
          expect(@request).to.have.been.calledWith {method: 'get', baseUrl: 'http://insecure.xxx:80', uri: '/foo'}

    describe 'when constructed without resolveSrv', ->
      beforeEach ->
        @request = sinon.stub()

        options = resolveSrv: false, protocol: 'https', hostname: 'thug.biz', port: 123
        dependencies = {@request}

        @sut = new MeshbluRequest options, dependencies

      describe 'when one of the methods is called', ->
        beforeEach 'making the request', (done) ->
          @request.yields null, statusCode: 204
          @sut.get '/foo', {}, done

        it 'should call request with the formatted url', ->
          expect(@request).to.have.been.calledWith {baseUrl: 'https://thug.biz:123', method: 'get', uri: '/foo'}
