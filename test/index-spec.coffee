Meshblu = require '../index'
describe 'Meshblu', ->
  it 'should exist', ->
    expect(Meshblu).to.exist

  describe '-> constructor', ->
    describe 'default', ->
      beforeEach ->
        @sut = new Meshblu

      it 'should set urlBase', ->
        expect(@sut.urlBase).to.equal 'https://meshblu.octoblu.com:443'

    describe 'with options', ->
      beforeEach ->
        @sut = new Meshblu
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
        @sut = new Meshblu
          protocol: 'ftp'
          server: 'halo'
          port: 400

      it 'should set urlBase', ->
        expect(@sut.urlBase).to.equal 'ftp://halo:400'

  describe '-> device', ->
    beforeEach ->
      @request = get: sinon.stub()
      @dependencies = request: @request
      @sut = new Meshblu {}, @dependencies

    describe 'when given a valid uuid', ->
      beforeEach (done) ->
        @request.get.yields null, null, foo: 'bar'
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

  describe '-> devices', ->
    beforeEach ->
      @request = get: sinon.stub()
      @dependencies = request: @request
      @sut = new Meshblu {}, @dependencies

    describe 'with a valid query', ->
      beforeEach (done) ->
        @request.get.yields null, null, foo: 'bar'
        @sut.devices 'octoblu:test', (@error, @body) => done()

      it 'should call get', ->
        expect(@request.get).to.have.been.calledWith 'https://meshblu.octoblu.com:443/devices',
          qs:
            type: 'octoblu:test'
          json: true
          auth:
            user: undefined
            pass: undefined

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

  describe '-> generateAndStoreToken', ->
    beforeEach ->
      @request = post: sinon.stub()
      @dependencies = request: @request
      @sut = new Meshblu {}, @dependencies

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

  describe '-> revokeToken', ->
    beforeEach ->
      @request = del: sinon.stub()
      @dependencies = request: @request
      @sut = new Meshblu {}, @dependencies

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
