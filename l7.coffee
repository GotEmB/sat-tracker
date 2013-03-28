request = require "request"

months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

exports.decodeUrl = (url) ->
	res = /(?:https?:\/\/)?landsat\.usgs\.gov\/L7_Pend_Acq\/y(?:\d{4})\/(?:[a-zA-Z]{3})\/([a-zA-Z]{3})-(\d{2})-(\d{4}).txt/g.exec url
	return unless res?
	[str, month, day, year] = res
	year: Number year
	month: month = months.indexOf month
	day: Number day

exports.createUrl = ({year, month, day}) ->
	"http://landsat.usgs.gov/L7_Pend_Acq/y#{year}/#{months[month]}/#{months[month]}-#{if day < 10 then "0" else ""}#{day}-#{year}.txt"

exports.decodeTimeString = (timeString, fileUrl) ->
	res = /(\d{3})-(\d{2}):(\d{2}):(\d{2})/g.exec timeString
	return unless res?
	[str, days, hour, minute, second] = res
	new Date Date.UTC exports.decodeUrl(fileUrl).year, 0, days, hour,  minute, second

exports.parseFileAtUrl = (url, callback) ->
	request url, (err, res, body) ->
		re = /(\d+)\s+(\d+)\s+(\S+)\s+([A-Z]{3})\s+(\S+)/g
		ret = []
		while (res = re.exec body)?
			[str, path, row, imageTime, station, downlinkTime] = res
			downlinkTime = imageTime if downlinkTime is "<realtime>"
			ret.push
				path: Number path
				row: Number row
				imageTime: exports.decodeTimeString imageTime, url
				station: station
				downlinkTime: exports.decodeTimeString downlinkTime, url
		callback? ret

exports.getRowPath = (time) ->
	

# http://landsat.usgs.gov/L7_Pend_Acq/y2013/Mar/Mar-27-2013.txt