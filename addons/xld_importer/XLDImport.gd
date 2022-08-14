tool
extends Button
class_name XLDImport

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var editorInterface: EditorInterface

const WALL_MESHLIB_INDEX_OFFSET = 4096
const OBJECT_MESHLIB_INDEX_OFFSET = 2*4096

func importTilesets():
	print("Starting import of tilesets")
	
	
	var xldIcons = XLD.new()
	xldIcons.load("res://XLDLIBS/ICONGFX0.XLD", funcref(XLDIconSprite, "new"))
	
	var xldTiles = XLD.new()
	xldTiles.load("res://XLDLIBS/ICONDAT0.XLD", funcref(XLDIconData, "new"))
	
	var paletteIndex = 5
	for tilesetIndex in range(2,3): #xldIcons.sections.size():
		print("Loading Tileset ", tilesetIndex)
		var iconSprite : XLDIconSprite = xldIcons.sections[tilesetIndex]
		iconSprite.paletteIndex = paletteIndex
		iconSprite.load()
		
		var iconData : XLDIconData = xldTiles.sections[tilesetIndex]
		iconData.load()
		
		print("Loaded Tileset ", tilesetIndex)

		var texture = ImageTexture.new()
		texture.create_from_image(iconSprite.image, 0)

		var iconSize = Vector2(iconSprite.width, iconSprite.height)


		var tileset = TileSet.new()
		var tileMeta = {}
		var tileIndex = 1
		for tileData in iconData.tiles:
			tileIndex = tileIndex + 1
			if tileData.iconIndex == 0:
				pass
				
			tileset.create_tile(tileIndex)
			var tileName = "Tile %s" % [tileIndex]
			
			if tileData.iconCount > 1:
				#print("Animated tile found at tile ", tileIndex, " with icon count ", tileData.iconCount)
				tileName = tileName + " (animated)"
				var animatedTexture = AnimatedTexture.new()
				animatedTexture.frames = tileData.iconCount
				animatedTexture.fps = 8
				for frameIndex in tileData.iconCount:
					var frameImage = Image.new()
					frameImage.create(iconSprite.width, iconSprite.height, false, Image.FORMAT_RGBA8)
					var region = Rect2(iconSprite.getIconOffset(tileData.iconIndex + frameIndex), iconSize)
					frameImage.blit_rect(iconSprite.image, region, Vector2.ZERO)
					var frameTexture = ImageTexture.new()
					frameTexture.create_from_image(frameImage, 0)
					animatedTexture.set_frame_texture(frameIndex, frameTexture)
				
				tileset.tile_set_texture(tileIndex, animatedTexture)
				tileset.tile_set_region(tileIndex, Rect2(Vector2.ZERO, iconSize))
			else:	
				tileset.tile_set_texture(tileIndex, texture)
				var region = Rect2(iconSprite.getIconOffset(tileData.iconIndex), iconSize)
				tileset.tile_set_region(tileIndex, region)
				
			

			if tileData.collision > 0:
				tileName += " (colliding %d)" % tileData.collision
				#print("Colliding tile found at tile ", tileIndex, " with collision value ", tileData.collision)
				
				var shape = RectangleShape2D.new()
				shape.extents = iconSize / 2
				var transform = Transform2D(0, iconSize / 2)
				tileset.tile_add_shape(tileIndex, shape, transform)
				
			
			var layerType = tileData.getLayerType()
			tileName += " (layer %d) " % layerType
			
			var sortByYPosition = layerType == XLDIconData.TILE_LAYER.UNDERLAY || XLDIconData.TILE_LAYER.DYNAMIC_1 || layerType == XLDIconData.TILE_LAYER.DYNAMIC_2 || layerType == XLDIconData.TILE_LAYER.DYNAMIC_3
			tileMeta[tileIndex] = {"layer": layerType, "collision": tileData.collision }	
			if sortByYPosition:
				
				var originShift = Vector2(0, (layerType - XLDIconData.TILE_LAYER.DYNAMIC_1) * 16)
				
				if originShift.y > 0:
					tileset.tile_set_texture_offset(tileIndex, -originShift)
			
			tileset.tile_set_name(tileIndex, tileName)
			
		tileset.set_meta("tile_meta", tileMeta)	

		ResourceSaver.save("res://xldimports/tileset_%d.res" % [tilesetIndex + 1], tileset)
	print("Finished import of tilesets")

func importMeshLibrary():
	print("Starting import of mesh libraries")
	
	var xldLabData = XLD.new()
	xldLabData.load("res://XLDLIBS/LABDATA1.XLD", funcref(XLDLabData, "new"))
	
	# TODO: Read from Mapdata
	var paletteIndex = 14
	
	for labdataIndex in range(106,107): 
		print("Loading LabData ", labdataIndex)
		var labData : XLDLabData = xldLabData.sections[labdataIndex % 100]
		labData.paletteIndex = paletteIndex
		labData.load()
	
		print("Loaded LabData ", labdataIndex)

#		var texture = ImageTexture.new()
#		texture.create_from_image(iconSprite.image, 0)
#
#		var iconSize = Vector2(iconSprite.width, iconSprite.height)


		var meshLibrary = MeshLibrary.new()
		var meshMeta = {}
			
		
		for floorIndex in labData.floors.size():
			var floorData = labData.floors[floorIndex]
			meshLibrary.create_item(floorIndex)
			var mesh = QuadMesh.new()
			mesh.center_offset = Vector3(0, 0, -0.5)
			
			var material = SpatialMaterial.new()
			material.albedo_texture = floorData.texture
			material.params_cull_mode = SpatialMaterial.CULL_DISABLED
			mesh.material = material
			
			meshLibrary.set_item_mesh(floorIndex, mesh)
			meshLibrary.set_item_name(floorIndex, "Floor %d" % floorIndex)
			meshLibrary.set_item_preview(floorIndex, floorData.texture)
			var transform = Transform.IDENTITY.translated(Vector3(0,0,0)).rotated(Vector3.RIGHT, -PI/2).rotated(Vector3.UP, -PI/2)
			meshLibrary.set_item_mesh_transform(floorIndex, transform)
		
		for wallIndex in labData.walls.size():
			var wallData = labData.walls[wallIndex]
			var itemIndex = wallIndex + WALL_MESHLIB_INDEX_OFFSET
			meshLibrary.create_item(itemIndex)
			var mesh = CubeMesh.new()
			mesh.size = Vector3(1, labData.wallHeight, 1)
	
			var material = SpatialMaterial.new()
			material.albedo_texture = wallData.texture
			material.uv1_scale = Vector3(3, 2, 1)
			material.flags_transparent = true
			material.params_use_alpha_scissor = true
			mesh.material = material
			
			meshLibrary.set_item_mesh(itemIndex, mesh)
			meshLibrary.set_item_name(itemIndex, "Wall %d (%d overlays)" % [wallIndex, wallData.overlayCount])
			meshLibrary.set_item_preview(itemIndex, wallData.texture)
			var transform = Transform.IDENTITY.translated(Vector3(0, (labData.wallHeight - 1) / 2, 0))
			meshLibrary.set_item_mesh_transform(itemIndex, transform)
			
		for objectIndex in labData.objects.size():
			var objectData = labData.objects[objectIndex]
			var itemIndex = objectIndex + OBJECT_MESHLIB_INDEX_OFFSET
			meshLibrary.create_item(itemIndex)
			
			var arrayMesh = ArrayMesh.new()
			
			var firstTexture = null
			var firstSubObject = null
			var firstObjectInfo = null
			
			for subObject in objectData.subObjects:
				var objectInfo = labData.objectInfos[subObject.objectInfoIndex-1]
				
				if !firstTexture:
					firstTexture = objectInfo.texture
					firstSubObject = subObject
					firstObjectInfo = objectInfo
				
				var mesh = QuadMesh.new()
				
				mesh.size = Vector2(objectInfo.mapXSize, objectInfo.mapYSize) / 256
				#mesh.center_offset = Vector3(0, (float(objectInfo.mapYSize) / 256 - 1)/2, 0)
				mesh.center_offset = Vector3(subObject.offset.x/512 - 0.5, 
				
				(float(objectInfo.mapYSize) / 256)/2 + subObject.offset.y / 512 - 0.5, subObject.offset.z / 512 - 0.5) 
								
				var material : ShaderMaterial = ShaderMaterial.new()
				material.shader = preload("res://BillboardObject.gdshader")
				material.set_shader_param("texture_albedo", objectInfo.texture)
				material.set_shader_param("pivot_transform", Transform.IDENTITY.translated(-mesh.center_offset))
				var surfaceIndex = arrayMesh.get_surface_count()
				arrayMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.get_mesh_arrays())
				arrayMesh.surface_set_material(surfaceIndex, material)
			
			meshLibrary.set_item_mesh(itemIndex, arrayMesh)
			meshLibrary.set_item_name(itemIndex, "Object %d texture %d x %d mapsize %d x %d offset %s" 
			% [objectIndex, firstTexture.get_width(), firstTexture.get_height(), firstObjectInfo.mapXSize, firstObjectInfo.mapYSize, firstSubObject.offset])
			meshLibrary.set_item_preview(itemIndex, firstTexture)
			
		
		meshLibrary.set_meta("mesh_meta", meshMeta)	
		meshLibrary.set_meta("wall_height", labData.wallHeight)
		
		meshLibrary.set_meta("fog_color", labData.fogColor)
		meshLibrary.set_meta("fog_depth_begin", labData.fogDepthBegin)
		meshLibrary.set_meta("fog_depth_end", labData.fogDepthEnd)

		ResourceSaver.save("res://xldimports/meshlib_%d.res" % [labdataIndex], meshLibrary)
	print("Finished import of tilesets")

func addLayers(parent: Node2D, owner: Node2D, name: String, tileSet: TileSet, cellYSort: bool, layerOffset : Vector2):
	var layers = []
	
	layers.append(addLayer(parent, owner, name + "_0", tileSet, cellYSort, layerOffset))
	layers.append(addLayer(parent, owner, name + "_1", tileSet, cellYSort, layerOffset))
	
	return layers

func addLayer(parent: Node2D, owner: Node2D, name: String, tileSet: TileSet, cellYSort: bool, layerOffset: Vector2) -> TileMap:
	var layer = TileMap.new()
	parent.add_child(layer)
	layer.owner = owner
	layer.name = name
	layer.cell_size = Vector2(16, 16)
	layer.tile_set = tileSet
	layer.cell_tile_origin = TileMap.TILE_ORIGIN_BOTTOM_LEFT
	layer.cell_y_sort = cellYSort
	layer.set_meta("layerOffset", layerOffset)
	return layer

	
static func clearCell(v, tilesetLayers, layerIndex ): 
	for layers in tilesetLayers.values():
		var layer : TileMap = layers[layerIndex]
		var cellv = v + layer.get_meta("layerOffset")	
		layer.set_cellv(cellv, -1)
		
static func setCell(v, tilesetLayers, tileIndex, tileMeta, layerIndex ): 
	if tileMeta.has(tileIndex):
		var layerType = tileMeta[tileIndex].layer
		var layer: TileMap = tilesetLayers[layerType][layerIndex]
		var cellv = v + layer.get_meta("layerOffset")	
		layer.set_cellv(cellv, tileIndex)
#		print("Setting tile at ", cellv, " for layer ", layer, " to ", tileIndex)
#	else:
#		print("No metadata known for tileIndex ", tileIndex, " in metadata ", tileMeta)
		
		#var collision = tileMeta[tileIndex].collision
		
		# Code to display some numerical value per tile
#		if collision > 0:
#			var textNode = Label.new()
#			textNode.name = "collision %s_%s" % [v.x, v.y]
#			textNode.text = str(collision)
#			textNode.margin_top = v.y * 16
#			textNode.margin_left = v.x * 16
#			owner.add_child(textNode)
#			textNode.owner = owner

func generateEventCode(mapScript : File, xldMap : XLDMap, xldMapText : XLDMapText, eventsPassed, eventId, indentation):
	if eventId == 0xFFFF:
		mapScript.store_line(indentation + "pass # eventId = 0xFFFF")

	while eventId != 0xFFFF:
		if eventsPassed.has(eventId):
			mapScript.store_line(indentation + "pass # loop back to event %d" % eventId )
			break	
			
		eventsPassed[eventId] = true
		
		var event = xldMap.events[eventId]

		if !event:
			mapScript.store_line(indentation + 'pass # unknown event ID %d' % eventId)
			break
		
		var eventTypeName = XLDMap.getEventTypeName(event.type)
		
		match event.type:
			XLDMap.EventType.Text:
				var textType = event.byte1
				var textId = event.byte5
				var text = xldMapText.texts[textId]
				mapScript.store_line(indentation + "get_node(\"/root/Node2D/\").showText(%s, \"%s\")" % [textType, text.c_escape() ])
			XLDMap.EventType.Query:
				var queryType = event.byte1
				var otherNextEvent = event.word8
				
				var condition = "true"
				match queryType:
					XLDMap.QueryType.CheckTriggerAction:
						var triggerTypeName = XLDMap.getTriggerTypeName(1 << event.word6)
						condition = "eventTriggerType == XLDMap.EVENT_TRIGGER.%s" % triggerTypeName
				
				mapScript.store_line(indentation + "if %s: #%s" % [condition, XLDMap.getQueryTypeName(queryType)])
				generateEventCode(mapScript, xldMap, xldMapText, eventsPassed.duplicate(), event.nextId, indentation + "    ")
				
				if otherNextEvent != 0xFFFF:
					mapScript.store_line(indentation + "else:")
					generateEventCode(mapScript, xldMap, xldMapText, eventsPassed.duplicate(), otherNextEvent, indentation + "    ")
				
				break
			XLDMap.EventType.ChangeMap:
				var changeType = event.byte4
				# Turn into signed bytes
				var x = event.byte1 if event.byte1 & 0x80 == 0 else -(0x100 - event.byte1)
				var y = event.byte2 if event.byte2 & 0x80 == 0 else -(0x100 - event.byte2)
				var absolutePosition = event.byte3 & 1 == 0
				var persistentChange = "true" if event.byte3 & 2 == 0 else "false"
				
				var positionExpression = "Vector2(%d, %d)" % [x, y]
				
				if !absolutePosition:
					positionExpression = "tilePosition + " + positionExpression
				
				match changeType:
#					XLDMap.ChangeMapType.ChangeTileEvent:
#						var newEventId = event.word6
#						mapScript.store_line(indentation 
#						+ "get_node(\"/root/Node2D/\").changeTileEvent(%s, %s, %d)" % [positionExpression, persistentChange, newEventId])
					XLDMap.ChangeMapType.ChangeLayer0Tile:
						var newTileId = event.word6
						mapScript.store_line(indentation
						+ "get_node(\"/root/Node2D/\").changeTile(0, %s, %s, %d)" % [positionExpression, persistentChange, newTileId])
					XLDMap.ChangeMapType.ChangeLayer1Tile:
						var newTileId = event.word6
						mapScript.store_line(indentation
						+ "get_node(\"/root/Node2D/\").changeTile(1, %s, %s, %d)" % [positionExpression, persistentChange, newTileId])
					XLDMap.ChangeMapType.ChangeTileObjectNoOverwrite:
						var layersBitset = event.byte5
						var blockListId = event.word6
						mapScript.store_line(indentation
						+ "get_node(\"/root/Node2D/\").placeTileObject(%s, %d, %d, %s, false)" % [positionExpression, blockListId, layersBitset, persistentChange])
					XLDMap.ChangeMapType.ChangeTileObjectOverwrite:
						var layersBitset = event.byte5
						var blockListId = event.word6
						mapScript.store_line(indentation
						+ "get_node(\"/root/Node2D/\").placeTileObject(%s, %d, %d, %s, true)" % [positionExpression, blockListId, layersBitset, persistentChange])
					_:
						var changeTypeName = XLDMap.getChangeMapTypeName(changeType)
						mapScript.store_line(indentation + "pass # Event ID %d - Type ChangeMap - ChangeType %s" % [eventId, changeTypeName])
			_:
				mapScript.store_line(indentation + "pass # Event ID %d - Type %s" % [eventId, eventTypeName])
			
		eventId = event.nextId

func createEvent(eventTrigger, eventScene, mapScript : File, xldMap : XLDMap, xldMapText : XLDMapText, root : Node2D):
	var eventTriggerNode : Area2D = eventScene.instance()
	eventTriggerNode.name = "EventTrigger %d" % [eventTrigger.eventId]
	root.add_child(eventTriggerNode)
	eventTriggerNode.owner = root
	eventTriggerNode.eventId = eventTrigger.eventId
	# Technically the type of trigger could differ per triggering tile,
	# but we assume it's the same for now
	eventTriggerNode.triggerTypes = eventTrigger.trigger
	
	var eventMethodName = "_Event%d" % eventTrigger.eventId
	
	if eventTrigger.trigger & XLDMap.EVENT_TRIGGER.Examine:
		eventTriggerNode.connect("examine", root, eventMethodName, [], CONNECT_PERSIST)
		
	if eventTrigger.trigger & XLDMap.EVENT_TRIGGER.Touch:
		eventTriggerNode.connect("touch", root, eventMethodName, [], CONNECT_PERSIST)
	
	if eventTrigger.trigger & XLDMap.EVENT_TRIGGER.Take:
		eventTriggerNode.connect("take", root, eventMethodName, [], CONNECT_PERSIST)
	
	
	mapScript.store_line("func " + eventMethodName + "(eventTriggerType, tilePosition):")
	
	var eventId = eventTrigger.eventId
	
	var eventsPassed = {}
	
	generateEventCode(mapScript, xldMap, xldMapText, eventsPassed, eventId, "    ")
	
	mapScript.store_line("")
	
	return eventTriggerNode
				
				
func import3DMap(mapNumber: int):
	var xld = XLD.new()
	xld.load("res://XLDLIBS/MAPDATA%d.XLD" % (mapNumber / 100), funcref(XLDMap, "new"))
	
	var xldMap : XLDMap = xld.sections[mapNumber % 100]	
	xldMap.load()
	
	var meshlib = load("res://xldimports/meshlib_%d.res" % (xldMap.tilesetId))
	
	var root = Spatial.new()
	root.name = "XLD Map"
	
	
	
	
	
	var ceilingMap = GridMap.new()
	root.add_child(ceilingMap)
	ceilingMap.name = "Ceiling"
	ceilingMap.owner = root
	ceilingMap.mesh_library = meshlib
	ceilingMap.cell_size = Vector3(1,1,1)
	ceilingMap.translation = Vector3(0, meshlib.get_meta("wall_height"), 0)
	
	var wallMap = GridMap.new()
	root.add_child(wallMap)
	wallMap.name = "Wall"
	wallMap.owner = root
	wallMap.mesh_library = meshlib
	wallMap.cell_size = Vector3(1,1,1)
	
	
	var floorMap = GridMap.new()
	root.add_child(floorMap)
	floorMap.name = "Floor"
	floorMap.owner = root
	floorMap.mesh_library = meshlib
	floorMap.cell_size = Vector3(1,1,1)
	
	var worldEnvironment = WorldEnvironment.new()
	
	root.add_child(worldEnvironment)
	worldEnvironment.owner = root
	var environment = Environment.new()
	worldEnvironment.environment = environment
	
	environment.fog_color = meshlib.get_meta("fog_color")
	environment.fog_depth_begin = float(meshlib.get_meta("fog_depth_begin")) / 256
	environment.fog_depth_end = meshlib.get_meta("fog_depth_end")
	environment.fog_enabled = true
	
	environment.ambient_light_color = Color.white
	
	for x in xldMap.width:
		for y in xldMap.height:
			var wallOrObjectIndex = xldMap.wallLayer[y][x] 
			var floorIndex = xldMap.floorLayer[y][x]
			var ceilingIndex = xldMap.ceilingLayer[y][x]	
					
			var wallIndex = -1
			var objectIndex = -1
			
			if wallOrObjectIndex > 100:
				wallIndex = wallOrObjectIndex - 100 
			else:
				objectIndex = wallOrObjectIndex
				
			if wallIndex > 0:
				wallMap.set_cell_item(x, 0, y, wallIndex - 1 + WALL_MESHLIB_INDEX_OFFSET)
			
			if objectIndex > 0:
				wallMap.set_cell_item(x, 0, y, objectIndex - 1 + OBJECT_MESHLIB_INDEX_OFFSET)
			
			if floorIndex > 0:
				floorMap.set_cell_item(x, 0, y, floorIndex - 1)
		
			if ceilingIndex > 0:
				ceilingMap.set_cell_item(x, 0, y, ceilingIndex - 1)
				
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	
	ResourceSaver.save("res://xldimports/map_%d.tscn" % mapNumber, packed_scene)
	
func importMaps():
	print("Starting import of tilemaps")
	
	var xld = XLD.new()
	xld.load("res://XLDLIBS/MAPDATA1.XLD", funcref(XLDMap, "new"))
	
	print("Loading Map 11")

	var xldMap : XLDMap = xld.sections[11]	
	xldMap.load()
	
	var mapTextXld = XLD.new()
	mapTextXld.load("res://XLDLIBS/ENGLISH/MAPTEXT1.XLD", funcref(XLDMapText, "new"))
	
	var xldMapText = mapTextXld.sections[11]
	xldMapText.load()
	
	print("Loaded Map 11")
	
	print("Tileset ID: ", xldMap.tilesetId)
	assert(xldMap.tilesetId <= 11)
	
	print("Palette: ", xldMap.palette)
	
	var tileset = load("res://xldimports/tileset_%d.res" % xldMap.tilesetId)
	
	var root = Node2D.new()
	root.name = "XLD Map"
	
	var layers = {}
	
	layers[XLDIconData.TILE_LAYER.UNDERLAY] = addLayers(root, root, "Underlay", tileset, false, Vector2(0, 0))
	
	var ysort = YSort.new()
	ysort.name = "YSort"
	root.add_child(ysort)
	ysort.owner = root
	
	layers[XLDIconData.TILE_LAYER.DYNAMIC_1] = addLayers(ysort, root, "Inlay", tileset, true, Vector2(0, 0))
	layers[XLDIconData.TILE_LAYER.DYNAMIC_2] =  addLayers(ysort, root, "InlayMinus16", tileset, true, Vector2(0, 1))
	layers[XLDIconData.TILE_LAYER.DYNAMIC_3] = addLayers(ysort, root, "InlayMinus32", tileset, true, Vector2(0, 2) )
	layers[XLDIconData.TILE_LAYER.OVERLAY] = addLayers(root, root, "Overlay", tileset, false, Vector2(0, 0))
	
#	inlay.cell_y_sort = true
#	inlayMinus16.cell_y_sort = true
#	inlayMinus32.cell_y_sort = true

	
	var tileMeta = tileset.get_meta("tile_meta")
	
	for x in xldMap.width:
		for y in xldMap.height:
			setCell(Vector2(x, y), layers, xldMap.tileLayers[0][y][x], tileMeta, 0 )
			setCell(Vector2(x, y), layers, xldMap.tileLayers[1][y][x], tileMeta, 1 )
			
			
	var xldGraphics = XLD.new()
	xldGraphics.load("res://XLDLIBS/NPCGR0.XLD", funcref(XLDSprite, "new"))
	
	var paletteIndex = 5
		
		
	print("NPC count: ", xldMap.npcs.size())
	for npc in xldMap.npcs:
		print("Loading NPC ")
		if npc.id > 100 && npc.id <= 200:
			var xldSprite : XLDSprite = xldGraphics.sections[npc.objectId-1]
			xldSprite.paletteIndex = paletteIndex
			xldSprite.load()

			print("Loaded NPC ")

			var texture = ImageTexture.new()
			texture.create_from_image(xldSprite.image, 0)
			texture.flags = 0
			

			var npcScene = preload("res://npc.tscn").instance()
			npcScene.texture = texture
			npcScene.startPos = npc.positions[0]
			npcScene.label = str(npc.movementType)

			ysort.add_child(npcScene)
			npcScene.owner = root
			
	# display events
	
	var dir = Directory.new()
	dir.remove("res://xldimports/tilemap_0.gd")

	var mapScript = File.new()
	mapScript.open("res://xldimports/tilemap_0.gd", File.WRITE)
	mapScript.store_line("extends Node2D")
	mapScript.store_line("")
	mapScript.store_line("export var tilesetId = %d" % xldMap.tilesetId)
	mapScript.store_line("")
	
	
	var eventScene = preload( "res://map_event.tscn" )
	
	var triggerNodeByEventId = {}
	for eventTrigger in xldMap.eventTriggers:
#		var textNode = Label.new()
#		var v = eventTrigger.position
#		textNode.name = "EventTrigger %s_%s" % [v.x, v.y]
		
#		var triggerText = ""
#		for triggerName in XLDMap.EVENT_TRIGGER:
#				if XLDMap.EVENT_TRIGGER[triggerName] & eventTrigger.trigger:
#					triggerText += " " + triggerName
#		var triggerText = ""
#		var eventType = xldMap.events[eventTrigger.eventId]
#
#		for eventTypeName in XLDMap.EventType:
#			if XLDMap.EventType[eventTypeName] == eventType:
#				triggerText += eventTypeName
#
#		textNode.text = triggerText
#		textNode.margin_top = v.y * 16
#		textNode.margin_left = v.x * 16
#		root.add_child(textNode)
#		textNode.owner = root
		
		var v = eventTrigger.position
		
		if !triggerNodeByEventId.has(eventTrigger.eventId):
			var eventTriggerNode = createEvent(eventTrigger, eventScene, mapScript, xldMap, xldMapText, root)
			triggerNodeByEventId[eventTrigger.eventId] = eventTriggerNode
			
		
		var eventTriggerNode : Area2D = triggerNodeByEventId[eventTrigger.eventId] 
		
		var collision2d = CollisionShape2D.new()
		collision2d.shape = RectangleShape2D.new()
		collision2d.shape.extents = Vector2(8, 8)
		collision2d.position = v * 16 + Vector2(8,8)
		
		eventTriggerNode.add_child(collision2d)
		collision2d.owner = root
	
	mapScript.close()
	
	root.set_script(load("res://xldimports/tilemap_0.gd"))
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	
	ResourceSaver.save("res://xldimports/tilemap_0.tscn", packed_scene)
	print("Finished import of tilemaps")

func addWalkAnimation(animationPlayer: AnimationPlayer, direction: String, offset: int):
	var animation = Animation.new()
	animation.loop = true
	animation.length = 2 
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Sprite:frame")
	animation.track_insert_key(track_index, 0.0, 0 + offset)
	animation.track_insert_key(track_index, 0.5, 1 + offset)
	animation.track_insert_key(track_index, 1.0, 2 + offset)
	animation.track_insert_key(track_index, 1.5, 1 + offset)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)

	animationPlayer.add_animation("walk_" + direction, animation)
	
func addSitAnimation(animationPlayer: AnimationPlayer, direction: String, offset: int):
	var animation = Animation.new()
	animation.loop = true
	animation.length = 0.5 
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Sprite:frame")
	animation.track_insert_key(track_index, 0.0, offset)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)

	animationPlayer.add_animation("sit_" + direction, animation)
	
func addSleepAnimation(animationPlayer: AnimationPlayer, offset: int):
	var animation = Animation.new()
	animation.loop = true
	animation.length = 0.5 
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Sprite:frame")
	animation.track_insert_key(track_index, 0.0, offset)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)

	animationPlayer.add_animation("sleep", animation)

func importPartyGraphics():
	print("Starting party graphics")
	
	
	var xldGraphics = XLD.new()
	xldGraphics.load("res://XLDLIBS/PARTGR0.XLD", funcref(XLDSprite, "new"))
	
	var paletteIndex = 5
	for partGraphicsIndex in xldGraphics.sections.size():
		print("Loading Party Graphics ", partGraphicsIndex)
		var xldSprite : XLDSprite = xldGraphics.sections[partGraphicsIndex]
		xldSprite.paletteIndex = paletteIndex
		xldSprite.load()
		
		print("Loaded Party Graphics ", partGraphicsIndex)

		var texture = ImageTexture.new()
		texture.create_from_image(xldSprite.image)

		var iconSize = Vector2(xldSprite.width, xldSprite.height)
				
		var sprite = Sprite.new()
		sprite.centered = false
		sprite.texture = texture
		sprite.hframes = xldSprite.framesCount
		
		print("Frames count: ", xldSprite.framesCount)
		var animationPlayer = AnimationPlayer.new()	
		
		if xldSprite.framesCount >= 16:	
			addWalkAnimation(animationPlayer, "n", 0)
			addWalkAnimation(animationPlayer, "e", 3)
			addWalkAnimation(animationPlayer, "s", 6)
			addWalkAnimation(animationPlayer, "w", 9)
			addSitAnimation(animationPlayer, "n", 12)
			addSitAnimation(animationPlayer, "e", 13)
			addSitAnimation(animationPlayer, "s", 14)
			addSitAnimation(animationPlayer, "s", 15)
			
		if xldSprite.framesCount == 17:	
			addSleepAnimation(animationPlayer, 16)
				
		var root = Node2D.new()
		root.name = "Character %d" % partGraphicsIndex
		root.add_child(sprite)
		sprite.owner = root
		sprite.name = "Sprite"
		root.add_child(animationPlayer)
		animationPlayer.owner = root
		animationPlayer.name = "AnimationPlayer"
		
		var packed_scene = PackedScene.new()
		packed_scene.pack(root)
		
		ResourceSaver.save("res://xldimports/character_%d.tscn" % partGraphicsIndex, packed_scene)
	print("Finished import of party graphics")



func _on_XLD_pressed():
	print("Starting XLDImport")
	
	importTilesets()
	importMaps()
	#importPartyGraphics()
	
	#var mainExe = MainExe.new()
	#mainExe.importGraphics()
	
	importMeshLibrary()
	
	import3DMap(122)
	
	#editorInterface.get_resource_filesystem().scan_resources()

	
	print("Finished XLDImport!")
