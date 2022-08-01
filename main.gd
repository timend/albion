extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var blockList
var layers
var tileMeta
var map
var xldBlockList : XLDBlockList

func addLayers(nodePath):
	var layers = []
	layers.append(map.get_node(nodePath + "_0"))
	layers.append(map.get_node(nodePath + "_1"))
	return layers

# Called when the node enters the scene tree for the first time.
func _ready():
	map = preload("res://xldimports/tilemap_0.tscn").instance()
	
	var blockListXld = XLD.new()
	blockListXld.load("res://XLDLIBS/BLKLIST0.XLD", funcref(XLDBlockList, "new"))
	
	xldBlockList = blockListXld.sections[map.tilesetId-1]
	xldBlockList.load()
	
	add_child(map)
	
	var mainCharacter = $MainCharacter	
	remove_child(mainCharacter)
	map.get_node("YSort").add_child(mainCharacter)

	mainCharacter.transform.origin = Vector2(39, 41)*16
	
	layers = {}
	layers[XLDIconData.TILE_LAYER.UNDERLAY] = addLayers("Underlay")
	layers[XLDIconData.TILE_LAYER.DYNAMIC_1] = addLayers("YSort/Inlay")
	layers[XLDIconData.TILE_LAYER.DYNAMIC_2] =  addLayers("YSort/InlayMinus16")
	layers[XLDIconData.TILE_LAYER.DYNAMIC_3] = addLayers("YSort/InlayMinus32")
	layers[XLDIconData.TILE_LAYER.OVERLAY] = addLayers("Overlay")
	
	tileMeta = map.get_node("Underlay_1").tile_set.get_meta("tile_meta")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func showText(textType: int, text: String):
	$CanvasLayer/Control/QuickInfo.text = text
	
func changeTile(layerIndex: int, v: Vector2, persistentChange: bool, tileIndex: int):
	XLDImport.clearCell(v, layers, layerIndex)
	XLDImport.setCell(v, layers, tileIndex, tileMeta, layerIndex)
	
func placeTileObject(v: Vector2, blockListId, layersBitset, persistentChange, overwrite):
	var blockList = xldBlockList.blockLists[blockListId]
	
	print("Applying blocklist ", blockListId, " with dimensions ", blockList.width, " x ", blockList.height, " to ", v)
	for layerIndex in 2:
		if layersBitset & (layerIndex + 1) == 0:
			continue
			
		for x in blockList.width:
			for y in blockList.height:
				var tileIndex = blockList.tileLayers[layerIndex][y][x]
				
				print("Tile ", tileIndex, " at ", Vector2(x, y))
				if !overwrite && tileIndex == 1:
					continue
				changeTile(layerIndex, v + Vector2(x, y), persistentChange, tileIndex)
				
