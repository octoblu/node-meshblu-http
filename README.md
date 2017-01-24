# Meshblu HTTP
A node package to use the Meshblu HTTP API...

[![Build Status](https://travis-ci.org/octoblu/node-meshblu-http.svg?branch=master)](https://travis-ci.org/octoblu/node-meshblu-http)
[![Code Climate](https://codeclimate.com/github/octoblu/node-meshblu-http/badges/gpa.svg)](https://codeclimate.com/github/octoblu/node-meshblu-http)
[![Test Coverage](https://codeclimate.com/github/octoblu/node-meshblu-http/badges/coverage.svg)](https://codeclimate.com/github/octoblu/node-meshblu-http)
[![npm version](https://badge.fury.io/js/meshblu-http.svg)](http://badge.fury.io/js/meshblu-http)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)

# Usage
### Install:
```
npm install --save meshblu-http
```

### Use:
```
var MeshbluHttp = require('meshblu-http');

var meshbluHttp = new MeshbluHttp();

meshbluHttp.register({}, function(error, response) {
  // code goes here
})
```

# Functions
### Constructor
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
| options   | object | no      | Can contain any of these keys: uuid, token, hostname, port, protocol, domain, service, secure, resolveSrv, auth |
```
var meshbluHttp = new MeshbluHttp({uuid: 'fancy_uuid', token: 'fancy_token'})
```

### Authenticate
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
| callback  |function| yes     | a function that takes error and response |
```
meshbluHttp.authenticate(function(error, response) {
  // code goes here
})
```

### Create Hook
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
| uuid      | string | yes     | a string containing the uuid         |
| token     | string | yes     | a string containing the token        |
| url       | string | yes     | a string containing the url          |
| callback  |function| yes     | a function that takes error          |

```
meshbluHttp.createHook('fancy_uuid', 'fancy_token', 'fancy_url', function(error) {
  // code goes here
})
```

### Create Subscription

### Delete Subscription

### Device

### Devices

### Find And Update

### Generate And Store Token

### Generate And Store Token With Options

### Generate Key Pair

### Health Check

### Message

### My Devices

### Public Key

### Register

### Reset Token

### Revoke Token

### Revoke Token By Query

### Search

### Search Tokens

### Set Private Key

### Sign

### Subscriptions

### Unregister

### Update

### Verify

### Whoami
