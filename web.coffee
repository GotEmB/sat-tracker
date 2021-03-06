express = require "express"
l7 = require "./l7"

server = express()
server.use express.static __dirname + "/public"

server.get "/l7/getRowPath", (req, res, next) ->
	l7.getRowPath new Date(new Date().setDate(new Date().getDate()-1)), (result) ->
		res.send result

server.listen (port = process.env.PORT ? 5000), -> console.log "Listening on port #{port}."