tool
class_name XLDMap
extends XLD.Section

var width : int
var height : int
var npcCount: int
var flags: int
var underlayTiles : Array
var overlayTiles : Array
var soundIndex : int
var mapType : int
var tilesetId : int
var palette : int
var combatBackgroundIndex : int
var animationFrequency : int
var npcs: Array

const xldPaletteManagerClass = preload("XLDPaletteManager.gd")


func loadContents(file: File):
	print("Loading some XLDMap")
	
	flags = file.get_8()
	npcCount = file.get_8()
	mapType = file.get_8()
	
	# only parse 2D maps
	assert(mapType == 2)
	
	soundIndex = file.get_8()
	width = file.get_8()
	height = file.get_8()
	tilesetId = file.get_8()
	combatBackgroundIndex = file.get_8()
	palette = file.get_8()
	animationFrequency = file.get_8()
	
	
	var npcCountReserved
	if npcCount == 0:
		npcCountReserved = 32
	elif npcCount == 64:
		npcCountReserved = 96
	else:
		npcCountReserved = npcCount
			
	# ignore npc data for now
	for i in npcCountReserved:
		var npc = NPC.new()
		npc.id = file.get_8()
		npc.sound = file.get_8()
		npc.event = file.get_16()
		npc.objectId = file.get_8()
		npc.unknown = file.get_8()
		npc.activity = file.get_8()
		npc.movementType = file.get_8()
		npc.unknown2 = file.get_16()
		npcs.append(npc)
	
	#file.get_buffer((npcCountReserved - npcCount) * 10)
	
	underlayTiles = []
	overlayTiles = []
	
	print("Starting to read tile data at offset", file.get_position())
	
	for y in height:
		var underlayTilesRow = []
		var overlayTilesRow = []
		for x in width:
			var data1 = file.get_8()
			var data2 = file.get_8()
			var data3 = file.get_8()
			# 12 bits for overlay + 12 bits for underlay
			var overlay = ((data1<<4)|((data2&0xF0)>>4)) 
			var underlay = (data3|((data2&0x0F)<<8))
			underlayTilesRow.append(underlay)
			overlayTilesRow.append(overlay)
		underlayTiles.append(underlayTilesRow)
		overlayTiles.append(overlayTilesRow)
		
	var autoeventsCount = file.get_16()
	file.get_buffer(autoeventsCount * 6)
	
	for y in height:
		var positionedEventsCount = file.get_16()
		file.get_buffer(positionedEventsCount * 6)
		
	var eventsCount = file.get_16()
	file.get_buffer(eventsCount * 12)
	
	for npc in npcs:
		if npc.movementType & 3 != 0:
			npc.positions = [Vector2(file.get_8()-1, file.get_8()-1)]
		else:
			npc.positions = []
			for i in 0x480:
				npc.positions.append(Vector2(file.get_8()-1, file.get_8()-1))
			
	print("Loading some XLDMap finished")


class NPC:
	var id
	var sound
	var event
	var objectId
	var unknown
	var activity
	var movementType
	var unknown2
	var positions
