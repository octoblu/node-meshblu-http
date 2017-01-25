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
| options   | object | no      | can contain any of these keys: uuid, token, hostname, port, protocol, domain, service, secure, resolveSrv, auth |
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
| type      | string | yes     | a string containing the type         |
| url       | string | yes     | a string containing the url          |
| callback  |function| yes     | a function that takes error          |
```
meshbluHttp.createHook('fancy_uuid', 'fancy_token', 'fancy_url', function(error) {
  // code goes here
})
```

### Create Subscription
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
| options   | object | yes     | an object containing three keys: subscriberUuid, emitterUuid, and type |
| callback  |function| yes     | a function that takes error and response |
```
meshbluHttp.createSubscription(
  {
    subscriberUuid: 'fancy_uuid',
    emitterUuid: 'another_fancy_uuid',
    type: 'fancy_type'
  },
  function(error, response){
    // code goes here
  }
)
```

### Delete Subscription
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
| options   | object | yes     | an object containing three keys: subscriberUuid, emitterUuid, and type |
| callback  |function| yes     | a function that takes error and response |

```
meshbluHttp.deleteSubscription(
  {
    subscriberUuid: 'fancy_uuid',
    emitterUuid: 'another_fancy_uuid',
    type: 'fancy_type'
  },
  function(error, response){
    // code goes here
  }
)
```

### Device
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Devices
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Find And Update
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Generate And Store Token
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Generate And Store Token With Options
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Generate Key Pair
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Health Check
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Message
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### My Devices
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Public Key
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Register
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Reset Token
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Revoke Token
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Revoke Token By Query
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Search
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Search Tokens
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Set Private Key
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Sign
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Subscriptions
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Unregister
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Update
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Verify
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```

### Whoami
| Parameter | Type   | Required| Description                          |
| ----------| -------| --------| -------------------------------------|
|       |  |      |          |
```
```
