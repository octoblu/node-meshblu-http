MeshbluHttp = require '../src/meshblu-http'

describe 'MeshbluHttp', ->
  describe '->constructor', ->
    describe 'default', ->
      beforeEach ->
        @sut = new MeshbluHttp

      it 'should set urlBase', ->
        expect(@sut.urlBase).to.equal 'https://meshblu.octoblu.com:443'

    describe 'with options', ->
      beforeEach ->
        @sut = new MeshbluHttp
          uuid: '1234'
          token: 'tok3n'
          server: 'google.co'
          port: 555
          protocol: 'ldap'

      it 'should set urlBase', ->
        expect(@sut.urlBase).to.equal 'ldap://google.co:555'

      it 'should set the protocol', ->
        expect(@sut.protocol).to.equal 'ldap'

      it 'should set uuid', ->
        expect(@sut.uuid).to.equal '1234'

      it 'should set token', ->
        expect(@sut.token).to.equal 'tok3n'

      it 'should set server', ->
        expect(@sut.server).to.equal 'google.co'

      it 'should set port', ->
        expect(@sut.port).to.equal 555

    describe 'with other options', ->
      beforeEach ->
        @sut = new MeshbluHttp
          protocol: 'ftp'
          server: 'halo'
          port: 400

      it 'should set urlBase', ->
        expect(@sut.urlBase).to.equal 'ftp://halo:400'

    describe 'with websocket protocol options', ->
      beforeEach ->
        @sut = new MeshbluHttp
          protocol: 'websocket'
          server: 'halo'
          port: 400

      it 'should set urlBase', ->
        expect(@sut.urlBase).to.equal 'http://halo:400'


    describe 'without a protocol on a specific port', ->
      beforeEach ->
        @sut = new MeshbluHttp
          server: 'localhost'
          port: 3000

      it 'should set urlBase', ->
        expect(@sut.urlBase).to.equal 'http://localhost:3000'

  describe '->device', ->
    beforeEach ->
      @request = get: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'when given a valid uuid', ->
      beforeEach (done) ->
        @request.get.yields null, {statusCode: 200}, foo: 'bar'
        @sut.device 'the-uuuuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/devices/the-uuuuid'

      it 'should call callback', ->
        expect(@body).to.deep.equal foo: 'bar'

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.get.yields new Error
        @dependencies = request: @request
        @sut.device 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/devices/invalid-uuid'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.get.yields null, null, error: 'something wrong'
        @sut.device 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/devices/invalid-uuid'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

  describe '->devices', ->
    beforeEach ->
      @request = get: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'with a valid query', ->
      beforeEach (done) ->
        @request.get.yields null, null, foo: 'bar'
        @sut.devices type: 'octoblu:test', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices',
          qs:
            type: 'octoblu:test'
          json: true

      it 'should call callback', ->
        expect(@body).to.deep.equal foo: 'bar'

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.get.yields new Error
        @sut.devices 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.get.yields null, null, error: 'something wrong'
        @sut.devices 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

  describe '->generateAndStoreToken', ->
    beforeEach ->
      @request = post: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'with a valid uuid', ->
      beforeEach (done) ->
        @request.post.yields null, null, foo: 'bar'
        @sut.generateAndStoreToken 'uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/uuid/tokens'

      it 'should call callback', ->
        expect(@body).to.deep.equal foo: 'bar'

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.post.yields new Error
        @sut.generateAndStoreToken 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/invalid-uuid/tokens'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.post.yields null, null, error: 'something wrong'
        @sut.generateAndStoreToken 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/invalid-uuid/tokens'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

  describe '->mydevices', ->
    beforeEach ->
      @request = get: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'with a valid query', ->
      beforeEach (done) ->
        @request.get.yields null, null, foo: 'bar'
        @sut.mydevices type: 'octoblu:test', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/mydevices',
          qs:
            type: 'octoblu:test'
          json: true

      it 'should call callback', ->
        expect(@body).to.deep.equal foo: 'bar'

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.get.yields new Error
        @sut.mydevices 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/mydevices'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.get.yields null, null, error: 'something wrong'
        @sut.mydevices 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/mydevices'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

  describe '->message', ->
    beforeEach ->
      @request = post: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'with a message', ->
      beforeEach (done) ->
        @request.post.yields null, null, foo: 'bar'
        @sut.message devices: 'uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/messages',
          json:
            devices: 'uuid'

      it 'should call callback', ->
        expect(@body).to.deep.equal foo: 'bar'

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.post.yields new Error
        @sut.message test: 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/messages'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.post.yields null, null, error: 'something wrong'
        @sut.message test: 'invalid-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/messages'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

  describe '->register', ->
    beforeEach ->
      @request = post: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'with a device', ->
      beforeEach (done) ->
        @request.post = sinon.stub().yields null, null, null
        @sut.register {uuid: 'howdy', token: 'sweet'}, (@error) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should call request.post on the device', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices'

    describe 'with an invalid device', ->
      beforeEach (done) ->
        @request.post = sinon.stub().yields new Error('unable to register device'), null, null
        @sut.register {uuid: 'NOPE', token: 'NO'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'unable to register device'

    describe 'when request returns an error in the body', ->
      beforeEach (done) ->
        @request.post = sinon.stub().yields null, null, error: new Error('body error')
        @sut.register {uuid: 'NOPE', token: 'NO'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'body error'

  describe '->resetToken', ->
    beforeEach ->
      @request = post: sinon.stub()
      @sut = new MeshbluHttp {}, request: @request

    describe 'when called with a uuid', ->
      beforeEach ->
        @sut.resetToken 'some-uuid'

      it 'should call post on request', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/some-uuid/token'

    describe 'when called with a different-uuid', ->
      beforeEach ->
        @sut.resetToken 'some-other-uuid'

      it 'should call post on request', ->
        expect(@request.post).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/some-other-uuid/token'

    describe 'when request yields a new token', ->
      beforeEach (done) ->
        @request.post.yields null, {statusCode: 201}, uuid: 'the-uuid', token: 'my-new-token'
        @sut.resetToken 'the-uuid', (error, @result) => done()

      it 'should call the callback with the uuid and new token', ->
        expect(@result).to.deep.equal uuid: 'the-uuid', token: 'my-new-token'

    describe 'when request yields a different new token', ->
      beforeEach (done) ->
        @request.post.yields null, {statusCode: 201}, uuid: 'the-other-uuid', token: 'my-other-new-token'
        @sut.resetToken 'the-other-uuid', (error, @result) => done()

      it 'should call the callback with the uuid and new token', ->
        expect(@result).to.deep.equal uuid: 'the-other-uuid', token: 'my-other-new-token'

    describe 'when request yields a 401 response code', ->
      beforeEach (done) ->
        @request.post.yields null, {statusCode: 401}, error: 'unauthorized'
        @sut.resetToken 'uuid', (@error) => done()

      it 'should call the callback with the error', ->
        expect(@error).to.deep.equal new Error('unauthorized')

    describe 'when request yields an error', ->
      beforeEach (done) ->
        @request.post.yields new Error('oh snap'), null
        @sut.resetToken 'the-other-uuid', (@error) => done()

      it 'should call the callback with the error', ->
        expect(@error).to.deep.equal new Error('oh snap')

  describe '->revokeToken', ->
    beforeEach ->
      @request = del: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'with a valid uuid', ->
      beforeEach (done) ->
        @request.del.yields null, null, null
        @sut.revokeToken 'uuid', 'taken', (@error, @body) => done()

      it 'should call del', ->
        expect(@request.del).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/uuid/tokens/taken'

      it 'should not have an error', ->
        expect(@error).to.not.exist

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.del.yields new Error
        @sut.revokeToken 'invalid-uuid', 'tekken', (@error, @body) => done()

      it 'should call del', ->
        expect(@request.del).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/invalid-uuid/tokens/tekken'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.del.yields null, null, error: 'something wrong'
        @sut.revokeToken 'invalid-uuid', 'tkoen', (@error, @body) => done()

      it 'should call del', ->
        expect(@request.del).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/invalid-uuid/tokens/tkoen'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

  describe '->setPrivateKey', ->
    beforeEach ->
      @nodeRSA = {}
      @NodeRSA = sinon.spy => @nodeRSA
      @sut = new MeshbluHttp {}, NodeRSA: @NodeRSA
      @sut.setPrivateKey 'data'

    it 'should new NodeRSA', ->
      expect(@NodeRSA).to.have.been.calledWithNew

    it 'should set', ->
      expect(@sut.privateKey).to.exist

  describe '->generateKeyPair', ->
    beforeEach ->
      @nodeRSA =
        exportKey: sinon.stub().returns ''
        generateKeyPair: sinon.spy()
      @NodeRSA = sinon.spy => @nodeRSA
      @sut = new MeshbluHttp {}, NodeRSA: @NodeRSA
      @result = @sut.generateKeyPair()

    it 'should new NodeRSA', ->
      expect(@NodeRSA).to.have.been.calledWithNew

    it 'should get a privateKey', ->
      expect(@result.privateKey).to.exist

    it 'should get a publicKey', ->
      expect(@result.publicKey).to.exist

  describe '->sign', ->
    beforeEach ->
      @sut = new MeshbluHttp {}
      @sut.privateKey = sign: sinon.stub().returns 'abcd'

    it 'should sign', ->
      expect(@sut.sign('1234')).to.equal 'abcd'

  describe '->unregister', ->
    beforeEach ->
      @request = del: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'with a device', ->
      beforeEach (done) ->
        @request.del = sinon.stub().yields null, null, null
        @sut.unregister {uuid: 'howdy', token: 'sweet'}, (@error) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should call request.del on the device', ->
        expect(@request.del).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/howdy'

    describe 'with an invalid device', ->
      beforeEach (done) ->
        @request.del = sinon.stub().yields new Error('unable to delete device'), null, null
        @sut.unregister {uuid: 'NOPE', token: 'NO'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'unable to delete device'

    describe 'when request returns an error in the body', ->
      beforeEach (done) ->
        @request.del = sinon.stub().yields null, null, error: new Error('body error')
        @sut.unregister {uuid: 'NOPE', token: 'NO'}, (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'body error'

  describe '->update', ->
    beforeEach ->
      @request = {}
      @dependencies = request: @request
      @sut = new MeshbluHttp {uuid: 'uuid', token: 'token'}, @dependencies

    describe 'with a uuid and params', ->
      beforeEach (done) ->
        @request.patch = sinon.stub().yields null, statusCode: 204, uuid: 'howdy'
        @sut.update 'howdy', {sam: 'I am'}, (@error) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should call request.patch on the device', ->
        expect(@request.patch).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/devices/howdy'

    describe 'with an invalid device', ->
      beforeEach (done) ->
        @request.patch = sinon.stub().yields new Error('unable to update device'), null, null
        @sut.update 'NOPE', {}, (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'unable to update device'

    describe 'when request returns an error in the body with a statusCode', ->
      beforeEach (done) ->
        @request.patch = sinon.stub().yields null, {statusCode: 422}, error: 'body error'
        @sut.update 'NOPE', {}, (@error) => done()

      it 'should have an error', ->
        expect(@error).to.be.an.instanceOf Error
        expect(@error.message).to.equal 'body error'

  describe '->updateDangerously', ->
    beforeEach ->
      @request = put: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {uuid: 'uuid', token: 'token'}, @dependencies

    describe 'with a uuid and params', ->
      beforeEach (done) ->
        @request.put = sinon.stub().yields null, statusCode: 204, uuid: 'howdy'
        @sut.updateDangerously 'howdy', {sam: 'I am'}, (@error) => done()

      it 'should not have an error', ->
        expect(@error).to.not.exist

      it 'should call request.put on the device', ->
        expect(@request.put).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/devices/howdy'

    describe 'with an invalid device', ->
      beforeEach (done) ->
        @request.put = sinon.stub().yields new Error('unable to update device'), null, null
        @sut.updateDangerously 'NOPE', {}, (@error) => done()

      it 'should have an error', ->
        expect(@error.message).to.equal 'unable to update device'

    describe 'when request returns an error in the body with a statusCode', ->
      beforeEach (done) ->
        @request.put = sinon.stub().yields null, {statusCode: 422}, error: 'body error'
        @sut.updateDangerously 'NOPE', {}, (@error) => done()

      it 'should have an error', ->
        expect(@error).to.be.an.instanceOf Error
        expect(@error.message).to.equal 'body error'

  describe '->verify', ->
    beforeEach ->
      @sut = new MeshbluHttp {}
      @sut.privateKey = verify: sinon.stub().returns true

    it 'should sign', ->
      expect(@sut.verify('1234', 'bbb')).to.be.true

  describe '->whoami', ->
    beforeEach ->
      @request = get: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'when given a valid uuid', ->
      beforeEach (done) ->
        @request.get.yields null, {statusCode: 200}, foo: 'bar'
        @sut.whoami (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/whoami'

      it 'should call callback', ->
        expect(@body).to.deep.equal foo: 'bar'

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.get.yields new Error
        @dependencies = request: @request
        @sut.whoami (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/whoami'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.get.yields null, null, error: 'something wrong'
        @sut.whoami (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/v2/whoami'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

  describe '->publicKey', ->
    beforeEach ->
      @request = get: sinon.stub()
      @dependencies = request: @request
      @sut = new MeshbluHttp {}, @dependencies

    describe 'when given a valid uuid', ->
      beforeEach (done) ->
        @request.get.yields null, {statusCode: 200}, foo: 'bar'
        @sut.publicKey 'my-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/my-uuid/publickey'

      it 'should call callback', ->
        expect(@body).to.deep.equal foo: 'bar'

    describe 'when an error happens', ->
      beforeEach (done) ->
        @request.get.yields new Error
        @dependencies = request: @request
        @sut.publicKey 'my-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/my-uuid/publickey'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error

    describe 'when a meshblu error body is returned', ->
      beforeEach (done) ->
        @request.get.yields null, null, error: 'something wrong'
        @sut.publicKey 'my-uuid', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices/my-uuid/publickey'

      it 'should callback with an error', ->
        expect(@error).to.deep.equal new Error
