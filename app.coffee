http = require "http"

module.exports = http.createServer (req,res) ->
  res.writeHead 200, 'Content-Type:': 'text/plain'
  res.end 'Hello World\n'
