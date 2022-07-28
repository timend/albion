tool
class_name XLDIconData
extends XLD.Section

var tiles: Array

func loadContents(file: File):
	print("Loading some XLDIconData")	
	var tileCount = length / 8	

	for tileIndex in tileCount:
		var tileData = TileData.new()
		tileData.type = file.get_8()
		tileData.collision = file.get_8()
		tileData.info = file.get_16()
		tileData.iconIndex = file.get_16()
		tileData.iconCount = file.get_8()
		tileData.unknown = file.get_8()
		tiles.append(tileData)
		
	print("Finished loading XLDIconData")

enum TILE_LAYER {
	UNKNOWN,
	UNDERLAY,	# always underlay
	DYNAMIC_1,	# underlay if player y > tile y, overlay if player y <= tile y
	DYNAMIC_2,	# same as TILE_LAYER::DYNAMIC_1, but tile y + 1
	DYNAMIC_3,	# same as TILE_LAYER::DYNAMIC_1, but tile y + 2
	OVERLAY		# always overlay
}

class TileData:
	var type: int
	var collision: int
	var info: int
	var iconIndex: int
	var iconCount: int
	var unknown: int
	
	func getLayerType(): # -> TILE_LAYER
		#TODO: find out what 0x8 is used for
		var ch = type >> 4
		if ch == 0: return TILE_LAYER.UNDERLAY
		if ch & 2 && ch & 4:  return TILE_LAYER.DYNAMIC_3
		if ch & 2: return TILE_LAYER.DYNAMIC_1
		if ch & 4: return TILE_LAYER.DYNAMIC_2
		return TILE_LAYER.UNKNOWN
