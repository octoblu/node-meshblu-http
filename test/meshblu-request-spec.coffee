{beforeEach, describe, it} = global
MeshbluRequest = require '../src/meshblu-request'

describe 'MeshbluRequest', ->
  describe 'SRV resolve', ->
    describe 'when constructed with resolveSrv and secure true', ->
      beforeEach ->
        @dns = resolveSrv: sinon.stub()
        @request = get: sinon.stub()

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
          @request.get.yields null
          @sut.get '/foo', {}, done

        it 'should call request with the resolved url', ->
          expect(@request.get).to.have.been.calledWith '/foo', {baseUrl: 'https://mesh.biz:34'}

    describe 'when constructed with resolveSrv and secure false', ->
      beforeEach ->
        @dns = resolveSrv: sinon.stub()
        @request = get: sinon.stub()

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
          @request.get.yields null
          @sut.get '/foo', {}, done

        it 'should call request with the resolved url', ->
          expect(@request.get).to.have.been.calledWith '/foo', {baseUrl: 'http://insecure.xxx:80'}

    describe 'when constructed without resolveSrv', ->
      beforeEach ->
        @request = get: sinon.stub()

        options = resolveSrv: false, protocol: 'https', hostname: 'thug.biz', port: 123
        dependencies = {@request}

        @sut = new MeshbluRequest options, dependencies

      describe 'when one of the methods is called', ->
        beforeEach 'making the request', (done) ->
          @request.get.yields null
          @sut.get '/foo', {}, done

        it 'should call request with the formatted url', ->
          expect(@request.get).to.have.been.calledWith '/foo', {baseUrl: 'https://thug.biz:123'}
