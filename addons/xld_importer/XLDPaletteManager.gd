tool
extends Reference
class_name XLDPaletteManager

var baseColors: Array
var palettes: XLD
var paletteIndex = 0

func _init():
	palettes = XLD.new()
	palettes.load("res://XLDLIBS/Palette0.XLD", funcref(XLDPalette, "new"))
	
	var file = File.new()
	file.open("res://XLDLIBS/Palette.000", File.READ)
	baseColors = loadPalette(file, 64)
	file.close()
	

func getColor(paletteIndex: int, colorIndex: int) -> Color:
	if colorIndex == 0:
		# transparent
		return Color(0, 0, 0, 0)
	elif colorIndex >= 192:
		return baseColors[colorIndex - 192]
	else:
		var palette = palettes.sections[paletteIndex]
		palette.load()
		return palette.colors[colorIndex]

func loadPalette(file: File, colorCount: int) -> Array:
	var colors = []
	for colorIndex in colorCount:
		var red = file.get_8()
		var green = file.get_8()
		var blue = file.get_8()
		var color = Color(red / 256.0, green / 256.0, blue / 256.0)
		colors.append(color)
	return colors

class XLDPalette:
	extends XLD.Section
	var colors: Array

	func loadPalette(file: File, colorCount: int) -> Array:
		var colors = []
		for colorIndex in colorCount:
			var red = file.get_8()
			var green = file.get_8()
			var blue = file.get_8()
			var color = Color(red / 256.0, green / 256.0, blue / 256.0)
			colors.append(color)
		return colors
	
	func loadContents(file: File):
		assert(length == 192*3)
		colors = loadPalette(file, 192)
