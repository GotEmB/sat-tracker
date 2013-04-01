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
				do rec = ->
					request.get("/l7/getRowPath", handleAs: "json").then ({snaps: [p1, p2], time}) ->
						fl.queryFeatures(
							extend new Query, where: "row = #{p1.row} and path = #{p1.path}"
							({features: [f1]}) ->
								fl.queryFeatures(
									extend new Query, where: "row = #{p2.row} and path = #{p2.path}"
									({features: [f2]}) ->
										c1 = f1.geometry.getExtent().getCenter()
										c2 = f2.geometry.getExtent().getCenter()
										t0 = Number new Date time
										t1 = Number new Date p1.time
										t2 = Number new Date p2.time
										c0 = new Point
											x: c1.x + (c1.x - c2.x) / (t1 - t2) * (t0 - t1)
											y: c1.y + (c1.y - c2.y) / (t1 - t2) * (t0 - t1)
											spatialReference: c1.spatialReference
										
										d1 = Math.abs t1 - t0
										d2 = Math.abs t2 - t0
										v0 =  new Point
											x: (c1.x * d2 + c2.x * d1) / (d1 + d2)
											y: (c1.y * d2 + c2.y * d1) / (d1 + d2)
											spatialReference: c1.spatialReference
										v0 = c0
										if gfx?
											gfx.setGeometry v0
										else
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
											map.centerAndZoom v0, 3
											gfx = new Graphic v0, sbl
											map.graphics.add gfx
								)
						)
				setInterval rec, 1000