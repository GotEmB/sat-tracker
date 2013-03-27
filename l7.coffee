request = require "request"

exports.parseFileAtUrl = (url) ->
	request url, (err, res, body) ->
		console.log body

# (\d+)\s+(\d+)\s+(\S+)\s+([A-Z]{3})\s+(\S+)
# http://landsat.usgs.gov/L7_Pend_Acq/y2013/Mar/Mar-27-2013.txt