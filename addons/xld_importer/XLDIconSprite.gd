tool
class_name XLDIconSprite
extends XLD.Section

var width = 16
var height = 16
var iconsPerLine = 64
var iconCount: int
var image: Image
var paletteIndex: int

const xldPaletteManagerClass = preload("XLDPaletteManager.gd")


func loadContents(file: File):
	print("Loading some XLDIconSprites")
	var vxldPaletteManager = xldPaletteManagerClass.new()
	
	iconCount = length / width / height	
	
	image = Image.new()
	image.create(iconsPerLine * width, (iconCount / iconsPerLine + 1) * height, false, Image.FORMAT_RGBA8)
	image.lock()
	
	for iconIndex in iconCount:
		for y in height:
			for x in width:
				var colorIndex = file.get_8()
				var color = vxldPaletteManager.getColor(paletteIndex, colorIndex)
				var offset = getIconOffset(iconIndex)
				image.set_pixel(offset.x + x, offset.y + y, color)
	image.unlock()
	
func getIconOffset(iconIndex: int) -> Vector2:
	return Vector2((iconIndex % iconsPerLine) * width, (iconIndex / iconsPerLine ) * height)
