express = require "express"
resource = require "express-resource"
util = require "util"

app = express.createServer()
app.use express.bodyParser()

class HTTPError extends Error
  constructor: (@msg, @status) ->
    Error.call @, @msg
    Error.captureStackTrace @, arguments.callee

app.error (err, req, res, next) ->
  unless err instanceof HTTPError
    return next(err)
  res.statusCode = err.status
  res.contentType "txt"
  res.send(err.msg + "\n")

class Buckets

  constructor: ->
    @store = {}
    @names = "ABCDEFG".split ""

  index: (req, res) =>
    res.contentType "txt"
    res.send "Buckets: " + (name for name,data of @store) + "\n"

  create: (req, res) =>
    unless @names.length > 0
      throw new HTTPError "The maximum number of buckets has been created.", 403
    name = @names.shift()
    @store[name] = ""
    res.statusCode = 201
    res.header "location", "http://" + (req.header "host") + '/' + name
    res.contentType "txt"
    res.send "Created bucket " + name + ".\n"
    
  update: (req, res) =>
    unless req.params.id of @store
      throw new HTTPError "No such bucket exists.", 404
    unless "data" of req.body
      throw new HTTPError "No data was specified.", 400
    name = req.params.id
    @store[name] = req.body.data
    res.contentType "txt"
    res.send "Added '" + req.body.data + "' to bucket " + name + ".\n"

  show: (req, res) =>
    unless req.params.id of @store
      throw new HTTPError "No such bucket exists.", 404
    name = req.params.id
    res.contentType "txt"
    if @store[name].length > 0
      res.send "Bucket " + name + ": " + @store[name] + "\n"
    else
      res.send "Bucket " + name + " is empty.\n"
      
  destroy: (req, res) =>
    unless req.params.id of @store
      throw new HTTPError "No such bucket exists.", 404
    name = req.params.id
    delete @store[name]
    @names.push(name)
    res.contentType "txt"
    res.send "Deleted bucket " + name + ".\n"
    
app.resource(new Buckets)

module.exports = app
