###
# Author: Gautham Badhrinathan (gbadhrinathan@esri.com)
###

# Extend `obj` with `mixin`
extend = (obj, mixin) ->
 	obj[name] = method for name, method of mixin        
 	obj

require [
	"dojo/ready"
	"esri/map"
	"esri/geometry/Point"
	"esri/symbols/SimpleMarkerSymbol"
	"esri/symbols/SimpleLineSymbol"
	"dojo/_base/Color"
	"esri/graphic"
	"dojo/_base/connect"
	"esri/layers/FeatureLayer"
	"esri/tasks/Query"
	"dojo/parser"
	"dijit/layout/BorderContainer"
	"dijit/layout/ContentPane"
	"dijit/TitlePane"
	"esri/dijit/Attribution"
], (ready, Map, Point, SimpleMarkerSymbol, SimpleLineSymbol, Color, Graphic, connect, FeatureLayer, Query) ->
	ready ->
		map = new Map "map", center: [-56.049, 38.485], zoom: 3, basemap: "streets"
		connect.connect map, "onLoad", ->
			# Using HTML5 Geolocation API
			navigator.geolocation?.getCurrentPosition ({coords}) ->
				map.centerAndZoom new Point(coords.longitude, coords.latitude), 8
				sbl = new SimpleMarkerSymbol(
					SimpleMarkerSymbol.STYLE_CIRCLE
					20
					new SimpleLineSymbol(
						SimpleLineSymbol.STYLE_SOLID
						new Color [200, 50, 50]
						4
					)
					new Color [200, 200, 50, 0.6]
				)
				gfx = new Graphic new Point(coords.longitude, coords.latitude), sbl
				map.graphics.add gfx
			fl = new FeatureLayer "http://lamborghini:6080/arcgis/rest/services/l7_rowpath/MapServer/0"
			connect.connect fl, "onLoad", ->
				fl.queryFeatures (extend new Query,
					where: "row = #{22} and path = #{202}"
				), (features) =>