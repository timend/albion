extends Reference
tool
class_name MainExe

var graphicsDict

class MainGraphics:
	var name: String
	var offset: int
	var width: int
	var height: int
	

func addGraphics(name: String, offset: int, width: int, height: int):
	var graphics = MainGraphics.new()
	graphics.name = name
	graphics.offset = offset
	graphics.width = width
	graphics.height = height
	graphicsDict[name] = graphics

func loadMainGraphics():
	graphicsDict = {}
	addGraphics("CURSOR",  0xFBE58, 14, 14)
	addGraphics("CURSOR_3D_UP",  0xFBF1C, 16, 16)
	addGraphics("CURSOR_3D_DOWN",  0xFC01C, 16, 16)
	addGraphics("CURSOR_3D_LEFT",  0xFC11C, 16, 16)
	addGraphics("CURSOR_3D_RIGHT",  0xFC21C, 16, 16)
	addGraphics("CURSOR_3D_TURN_LEFT_90",  0xFC31C, 16, 16)
	addGraphics("CURSOR_3D_TURN_RIGHT_90",  0xFC41C, 16, 16)
	addGraphics("CURSOR_3D_TURN_LEFT_180",  0xFC51C, 16, 16)
	addGraphics("CURSOR_3D_TURN_RIGHT_180",  0xFC61C, 16, 16)
	addGraphics("CURSOR_2D_UP",  0xFC71C, 16, 16)
	addGraphics("CURSOR_2D_DOWN",  0xFC81C, 16, 16)
	addGraphics("CURSOR_2D_LEFT",  0xFC91C, 16, 16)
	addGraphics("CURSOR_2D_RIGHT",  0xFCA1C, 16, 16)
	addGraphics("CURSOR_2D_UP_LEFT",  0xFCB1C, 16, 16)
	addGraphics("CURSOR_2D_UP_RIGHT",  0xFCC1C, 16, 16)
	addGraphics("CURSOR_2D_DOWN_RIGHT",  0xFCD1C, 16, 16)
	addGraphics("CURSOR_2D_DOWN_LEFT",  0xFCE1C, 16, 16)
	addGraphics("CURSOR_SELECTED",  0xFCF1C, 14, 13)
	addGraphics("CURSOR_CD_LOAD",  0xFCFD0, 24, 14)
	addGraphics("CURSOR_WAIT",  0xFD120, 16, 19)
	addGraphics("CURSOR_MOUSE_CLICK",  0xFD250, 18, 25)
	addGraphics("CURSOR_SMALL",  0xFD412, 8, 8)
	addGraphics("CURSOR_CROSS_SELECTED",  0xFD452, 20, 19)
	addGraphics("CURSOR_CROSS_UNSELECTED",  0xFD5CE, 22, 21)
	addGraphics("CURSOR_MEMORY_LOAD",  0xFD79C, 28, 21)
	addGraphics("CURSOR_UP_LEFT",  0xFD9EA, 16, 16)
	addGraphics("CURSOR_UP_RIGHT",  0xFDAEC, 16, 14)
	# TODO: unknown data from 0xFDBCC - 0xFDD10 (2*162px?)
	addGraphics("UI_BACKGROUND",  0xFDD10, 32, 64)
	addGraphics("UI_BACKGROUND_STRIPED",  0xFE510, 16, 12)
	addGraphics("UI_BACKGROUND_LINES",  0xFE5D0, 16, 12)
	addGraphics("UI_WINDOW_TOP_LEFT",  0xFE690, 16, 16)
	addGraphics("UI_WINDOW_TOP_RIGHT",  0xFE790, 16, 16)
	addGraphics("UI_WINDOW_BOTTOM_LEFT",  0xFE890, 16, 16)
	addGraphics("UI_WINDOW_BOTTOM_RIGHT",  0xFE990, 16, 16)
	addGraphics("UI_EXIT_BUTTON_1",  0xFEA90, 56, 16)
	addGraphics("UI_EXIT_BUTTON_2",  0xFEE10, 56, 16)
	addGraphics("UI_EXIT_BUTTON_3",  0xFF190, 56, 16)
	addGraphics("UI_OFFENSIVE_VALUE",  0xFF510, 8, 8)
	addGraphics("UI_DEFENSIVE_VALUE",  0xFF550, 6, 8)
	addGraphics("UI_GOLD",  0xFF580, 12, 10)
	addGraphics("UI_FOOD",  0xFF5F8, 20, 10)
	addGraphics("UI_NA",  0xFF6C0, 16, 16)
	addGraphics("UI_BROKEN",  0xFF7C0, 16, 16)
	addGraphics("UI_SPELL_ADVANCE",  0xFF8C0, 50, 8)
	addGraphics("COMBAT_MOVE",  0xFFA50, 16, 16)
	addGraphics("COMBAT_ATTACK_MELEE",  0xFFB50, 16, 16)
	addGraphics("COMBAT_ATTACK_RANGE",  0xFFC50, 16, 16)
	addGraphics("COMBAT_RETREAT",  0xFFD50, 16, 16)
	addGraphics("COMBAT_MAGIC",  0xFFE50, 16, 16)
	addGraphics("COMBAT_MAGIC_ITEM",  0xFFF50, 16, 16)
	addGraphics("MONSTER_EYE_OFF",  0x100050, 32, 27)
	addGraphics("MONSTER_EYE_ON",  0x1003B0, 32, 27)
	addGraphics("CLOCK",  0x100710, 32, 25)
	addGraphics("CLOCK_NUM_0",  0x100A30, 6, 7)
	addGraphics("CLOCK_NUM_1",  0x100A5A, 6, 7)
	addGraphics("CLOCK_NUM_2",  0x100A84, 6, 7)
	addGraphics("CLOCK_NUM_3",  0x100AAE, 6, 7)
	addGraphics("CLOCK_NUM_4",  0x100AD8, 6, 7)
	addGraphics("CLOCK_NUM_5",  0x100B02, 6, 7)
	addGraphics("CLOCK_NUM_6",  0x100B2C, 6, 7)
	addGraphics("CLOCK_NUM_7",  0x100B56, 6, 7)
	addGraphics("CLOCK_NUM_8",  0x100B80, 6, 7)
	addGraphics("CLOCK_NUM_9",  0x100BAA, 6, 7)
	addGraphics("COMPASS_DE",  0x100BD4, 30, 29)
	addGraphics("COMPASS_EN",  0x100F3A, 30, 29)
	addGraphics("COMPASS_FR",  0x1012A0, 30, 29)
	addGraphics("COMPASS_DOT_0",  0x101606, 6, 6)
	addGraphics("COMPASS_DOT_1",  0x10162A, 6, 6)
	addGraphics("COMPASS_DOT_2",  0x10164E, 6, 6)
	addGraphics("COMPASS_DOT_3",  0x101672, 6, 6)
	addGraphics("COMPASS_DOT_4",  0x101696, 6, 6)
	addGraphics("COMPASS_DOT_5",  0x1016BA, 6, 6)
	addGraphics("COMPASS_DOT_6",  0x1016DE, 6, 6)
	addGraphics("COMPASS_DOT_7",  0x101702, 6, 6)
	addGraphics("SELECT",  0x101726, 18, 18)
	addGraphics("LOCK",  0x10186A, 22, 22)
	addGraphics("PRODUCER",  0x101A4E, 34, 48)
	addGraphics("CHAR_EFFECT_1",  0x1020AE, 32, 32)
	addGraphics("CHAR_EFFECT_2",  0x1024AE, 32, 32)
	addGraphics("CHAR_EFFECT_3",  0x1028AD, 14, 13)
	addGraphics("ARROW_TURN_LEFT_90",  0x102963, 16, 16)
	addGraphics("ARROW_TURN_RIGHT_90",  0x102A63, 16, 16)
	addGraphics("ARROW_TURN_LEFT_180",  0x102B63, 16, 16)
	addGraphics("ARROW_TURN_RIGHT_180",  0x102C63, 16, 16)
	addGraphics("ARROW_LOOK_UP",  0x102D63, 16, 16)
	addGraphics("ARROW_LOOK_DOWN",  0x102E63, 16, 16)
	
func importGraphics():
	loadMainGraphics()
	var xldPaletteManager = XLDPaletteManager.new()
	
	var mainExe : File = File.new()
	mainExe.open("res://XLDLIBS/Main.exe", File.READ)
	
	for key in graphicsDict.keys():
		var graphics = graphicsDict[key]
		mainExe.seek(graphics.offset)
		
		var paletteIndex = 0
		
		var image = Image.new()
		image.create(graphics.width, graphics.height, false, Image.FORMAT_RGBA8, 0)
		image.lock()
		
		for y in graphics.height:
			for x in graphics.width:
				var colorIndex = mainExe.get_8()
				var color = xldPaletteManager.getColor(paletteIndex, colorIndex)
				image.set_pixel(x, y, color)
				
		image.save_png("res://xldimports/graphics_%s.png" % key.to_lower())
		
		
		
