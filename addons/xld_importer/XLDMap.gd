
tool
class_name XLDMap
extends XLD.Section

var width : int
var height : int
var npcCount: int
var flags: int
var tileLayers : Array
var soundIndex : int
var mapType : int
var tilesetId : int
var palette : int
var combatBackgroundIndex : int
var animationFrequency : int
var npcs: Array

var eventTriggers: Array
var events: Array

const xldPaletteManagerClass = preload("XLDPaletteManager.gd")

static func loadTiles(width, height, layers, file):
	layers.append([])
	layers.append([])
	
	for y in height:
		var layer0TilesRow = []
		var layer1TilesRow = []
		for x in width:
			var data1 = file.get_8()
			var data2 = file.get_8()
			var data3 = file.get_8()
			# 12 bits for each of the two layers
			var layer1Tile = ((data1<<4)|((data2&0xF0)>>4)) 
			var layer0Tile = (data3|((data2&0x0F)<<8))
			layer0TilesRow.append(layer0Tile)
			layer1TilesRow.append(layer1Tile)
		layers[0].append(layer0TilesRow)
		layers[1].append(layer1TilesRow)

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
	tileLayers = []
	
	loadTiles(width, height, tileLayers, file)
	
	eventTriggers = []
	
	var autoeventsCount = file.get_16()
	
	file.get_buffer(autoeventsCount * 6)
	
	for y in height:
		var positionedEventsCount = file.get_16()
		
		for i in positionedEventsCount:
			var eventTrigger = EventTrigger.new()
			eventTrigger.position = Vector2(file.get_16()-1, y)
			eventTrigger.trigger = file.get_16()
			eventTrigger.eventId = file.get_16()
			eventTriggers.append(eventTrigger)
		
	events = []
	var eventsCount = file.get_16()
	
	for i in eventsCount:
		var event = Event.new()
		event.type = file.get_8()
		event.byte1 = file.get_8()
		event.byte2 = file.get_8()
		event.byte3 = file.get_8()
		event.byte4 = file.get_8()
		event.byte5 = file.get_8()
		event.word6 = file.get_16()
		event.word8 = file.get_16()
		event.nextId = file.get_16()
		events.append(event)
	
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
	
	
enum EVENT_TRIGGER {
	None = 0,
	Normal = 1,
	Examine = 2,
	Touch = 4,
	Speak = 8,
	UseItem = 16,
	MapInit = 32,
	EveryStep = 64,
	EveryHour = 128,
	EveryDay = 256,
	Default = 512,
	Action = 1024,
	NPC = 2048,
	Take = 4096,
}

class EventTrigger:
	var position: Vector2
	var trigger #: EVENT_TRIGGER (bit mask)
	var eventId: int
		
	
enum EventType {
	Script = 0,
	MapExit = 1,
	Door = 2,
	Chest = 3,
	Text = 4,
	Spinner = 5,
	Trap = 6,
	ChangeUsedItem = 7,
	DataChange = 8,
	ChangeMap = 9,
	Encounter = 10,
	PlaceAction = 11,
	Query = 12,
	Modify = 13,
	Action = 14,
	Signal = 15,
	CloneAutomap = 16,
	Sound = 17,
	StartDialogue = 18,
	CreateTransport = 19,
	Execute = 20,
	RemovePartyMember = 21,
	EndDialogue = 22,
	Wipe = 23,
	PlayAnimation = 24,
	Offset = 25,
	Pause = 26,
	SimpleChest = 27,
	AskSurrender = 28,
	DoScript = 29,
}


class Event:
	var type : int #EventType
	var byte1 : int
	var byte2: int
	var byte3: int
	var byte4: int
	var byte5: int
	var word6: int
	var word8: int
	var nextId : int

static func getTypeName(typeDictionary, typeNumber):
	for typeName in typeDictionary:
		if typeDictionary[typeName] == typeNumber:
			return typeName
	return "unknown %d" % typeNumber

static func getEventTypeName(typeNumber):
	return getTypeName(EventType, typeNumber)

enum QueryType {
	CheckTemporarySwitch = 0x00,
	CheckPartyMemberPresent = 0x05,
	CheckPartyItemInInventory = 0x06,
	CheckUsedItemId = 0x07,
	CheckLastActionSuccessful = 0x09,
	CheckScriptDebugMode = 0x0A,
	CheckNPCActive = 0x0E,
	CheckPartyGold = 0x0F,
	CheckRandomCall = 0x11,
	CheckTriggerAction = 0x14,
	CheckPartyMemberConscious = 0x15,
	CheckPartyLeader = 0x1A,
	CheckTicker = 0x1C,
	CheckCurrentMapId = 0x1D,
	SendQueryToPlayer = 0x1F,
	CompareTriggerType = 0x20,
	CheckEventAlreadyUsed = 0x22,
	CheckDemoVersion = 0x23,
	CheckNumberInput = 0x2B
}

static func getQueryTypeName(typeNumber):
	return getTypeName(QueryType, typeNumber)

static func getTriggerTypeName(typeNumber):
	return getTypeName(EVENT_TRIGGER, typeNumber)
	
enum ChangeMapType {
	ChangeLayer0Tile = 0x00,
	ChangeLayer1Tile = 0x01,
	Change3DWall = 0x02,
	Change3DFloor = 0x03,
	Change3DCeiling = 0x04,
	ChangeNPCMovementType = 0x05,
	ChangeNPCSprite = 0x06,
	ChangeTileEvent = 0x07,
	ChangeTileObjectOverwrite = 0x08,
	ChangeTileObjectNoOverwrite = 0x09
}

static func getChangeMapTypeName(typeNumber):
	return getTypeName(ChangeMapType, typeNumber)
