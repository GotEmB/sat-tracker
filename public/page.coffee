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
	"esri/tasks/query"
	"dojo/request"
	"dojo/parser"
	"dijit/layout/BorderContainer"
	"dijit/layout/ContentPane"
	"dijit/TitlePane"
	"esri/dijit/Attribution"
], (ready, Map, Point, SimpleMarkerSymbol, SimpleLineSymbol, Color, Graphic, connect, FeatureLayer, Query, request) ->
	ready ->
		map = new Map "map", center: [-56.049, 38.485], zoom: 3, basemap: "streets"
		connect.connect map, "onLoad", ->
			fl = new FeatureLayer "http://lamborghini:6080/arcgis/rest/services/l7_rowpath/MapServer/0"
			connect.connect fl, "onLoad", ->
				gfx = null
				do setInterval(
					->
						request.get("/l7/getRowPath", handleAs: "json").then ({row, path}) ->
							fl.queryFeatures(
								extend new Query, where: "row = #{row} and path = #{path}"
								({features: [feature]}) ->
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
									if gfx?
										gfx.setGeometry feature.geometry.getExtent().getCenter()
									else
										map.centerAndZoom feature.geometry.getExtent().getCenter(), 3
										gfx = new Graphic feature.geometry.getExtent().getCenter(), sbl
										map.graphics.add gfx
								(error) ->
									console.error error
							)
					1000
				)