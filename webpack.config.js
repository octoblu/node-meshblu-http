var path              = require('path');
var webpack           = require('webpack');
var CompressionPlugin = require("compression-webpack-plugin");

module.exports = {
  entry: [
    './src/meshblu-http.coffee'
  ],
  output: {
    library: 'MeshbluHttp',
    path: path.join(__dirname, 'deploy', 'browser-meshblu-http', 'latest'),
    filename: 'meshblu-http.bundle.uncompressed.js'
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loader: "coffee" },
      { test: /\.json$/, loader: "json" }
    ]
  },
  resolve: {
    alias: {
      'request': 'browser-request'
    }
  },
  plugins: [
     new CompressionPlugin({
       asset: 'meshblu-http.bundle.js'
     })
   ]
};
