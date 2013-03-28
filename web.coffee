express = require "express"

server = express()
server.use express.static __dirname + "/public"

server.get "/:sat/getLocation", (req, res, next) ->
	