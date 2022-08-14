tool
class_name XLDSprite
extends XLD.Section

var width: int
var height: int
var paletteIndex: int
var framesCount: int
var image: Image

func loadContents(file: File):
	width = file.get_16()
	height = file.get_16()
	# unknown (always 0)
	file.get_8()
	framesCount = file.get_8()
	
	var xldPaletteManager = XLDPaletteManager.new()
	
	assert(length == 6 + width * height * framesCount, "Unexpected length in bytes: %d. Width: %d, Height: %d, Frames Count: %d" % [length, width, height, framesCount])

	image = Image.new()
	image.create(width * framesCount, height, false, Image.FORMAT_RGBA8)
	image.lock()
	
	for frameIndex in framesCount:
		for y in height:
			for x in width:
				var colorIndex = file.get_8()
				var color = xldPaletteManager.getColor(paletteIndex, colorIndex)
				image.set_pixel(frameIndex * width + x, y, color)
	image.unlock()
