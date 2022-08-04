tool
class_name XLDLabData
extends XLD.Section

var floors: Array
var walls: Array
var paletteIndex: int

const xldPaletteManagerClass = preload("XLDPaletteManager.gd")
var vxldPaletteManager = xldPaletteManagerClass.new()

const FLOOR_HEIGHT = 64
const FLOOR_WIDTH = 64
	
func textureFromImages(images):
	var texture
	if images.size() > 1:
		var animatedTexture = AnimatedTexture.new()
		animatedTexture.frames = images.size()
		animatedTexture.fps = 4
		for frameIndex in images.size():
			var frameTexture = ImageTexture.new()
			frameTexture.create_from_image(images[frameIndex], Texture.FLAG_REPEAT)
			animatedTexture.set_frame_texture(frameIndex, frameTexture)
		texture = animatedTexture
	else:
		texture = ImageTexture.new()
		texture.create_from_image(images[0], Texture.FLAG_REPEAT)
		texture.flags = Texture.FLAG_REPEAT
		
	return texture
	
func loadContents(file: File):
	print("Loading some XLDLabData")	
	
	# header ignored for now
	file.get_buffer(38)
	
	var objectCount = file.get_16()
	file.get_buffer(66 * objectCount)
	
	var floorCount = file.get_16()
	
	var xldFloorImages = []
	var xldWallImages = []
	var xldOverlayImages = []

	for i in 3:
		var xldFloorImage = XLD.new()
		xldFloorImage.load("res://XLDLIBS/3DFLOOR%d.XLD" % i, funcref(XLDImage, "new"))
		xldFloorImages.append(xldFloorImage)
	
	for i in 2:
		var xldWallImage = XLD.new()
		xldWallImage.load("res://XLDLIBS/3DWALLS%d.XLD" % i, funcref(XLDImage, "new"))
		xldWallImages.append(xldWallImage)
		
	for i in 3:
		var xldOverlayImage = XLD.new()
		xldOverlayImage.load("res://XLDLIBS/3DOVERL%d.XLD" % i, funcref(XLDImage, "new"))
		xldOverlayImages.append(xldOverlayImage)
	
	floors = []
	
	for i in floorCount:
		var floorData = FloorData.new()
		floorData.flags = file.get_8()
		file.get_buffer(3)
		floorData.frames = file.get_8()
		file.get_8()
		var textureNumber = file.get_16() - 1 
		file.get_16()
		
		var floorImage = xldFloorImages[textureNumber / 100].sections[textureNumber % 100]
		floorImage.paletteIndex = paletteIndex
		floorImage.frames = floorData.frames
		floorImage.width = FLOOR_WIDTH
		floorImage.height = FLOOR_HEIGHT
		floorImage.paletteManager = vxldPaletteManager
		#floorImage.pixelCoordTransform = Transform2D.FLIP_Y.rotated(PI / 2)
		floorImage.load()

		for image in floorImage.images:
			image.flip_y()
		
		floorData.texture = textureFromImages(floorImage.images)
		
		floors.append(floorData)
	
	var objectInfoCount = file.get_16()
	
	file.get_buffer(16 * objectInfoCount)
	
	var wallCount = file.get_16()
	
	for i in wallCount:
		var wallData = WallData.new()
		wallData.flags = file.get_8()
		var collision = file.get_buffer(3)
		#print("reading texture number for wall %d at position %d from %s" % [i, file.get_position(), file.get_path()])
		var textureNumber = file.get_16() - 1
		#print("texture number: ", textureNumber)
		wallData.frames = file.get_8()
		var autoGfx = file.get_8()
		file.get_16()
		wallData.textureWidth = file.get_16()
		wallData.textureHeight = file.get_16()
		
		var wallImage = xldWallImages[textureNumber / 100].sections[textureNumber % 100]
		wallImage.paletteIndex = paletteIndex
		wallImage.frames = wallData.frames
		wallImage.width = wallData.textureWidth
		wallImage.height = wallData.textureHeight
		wallImage.paletteManager = vxldPaletteManager
		wallImage.load()
		
		
	
#		0	2	texture number	texture number (→ 3DOVERL)
#2	1	animations	#animations
#3	1	write zero	write 0×00 bytes? (0: yes, else: no)
#4	2	y-offset	y-offset on the wall texture
#6	2	x-offset	x-offset on the wall texture
#8	2	texture width	texture width
#10	2	texture height	texture height
		var overlayCount = file.get_16()
		wallData.overlayCount = overlayCount
		for overlayIndex in overlayCount:
			var overlayTextureNumber = file.get_16() - 1
			var overlayFrames = file.get_8()
			var writeZero = file.get_8()
			print("WriteZero: ", writeZero)
			var overlayOffsetX = file.get_16()
			var overlayOffsetY = file.get_16()
			var overlayWidth = file.get_16()
			var overlayHeight = file.get_16()
			
			#assert(overlayOffsetX + overlayWidth < wallData.textureWidth)
			#assert(overlayOffsetY + overlayHeight < wallData.textureHeight)
			assert(overlayFrames == 1)
			
			#assert(wallData.frames == 1, "Overlay on animated wall")
			
			var overlayImage = xldOverlayImages[overlayTextureNumber / 100].sections[overlayTextureNumber % 100]
			overlayImage.paletteIndex = paletteIndex
			overlayImage.frames = overlayFrames
			overlayImage.width = overlayWidth
			overlayImage.height = overlayHeight
			overlayImage.paletteManager = vxldPaletteManager
			overlayImage.load()
			
			for image in wallImage.images:
				var img: Image = image
				img.blend_rect(overlayImage.images[0], Rect2(0, 0, overlayWidth, overlayHeight), Vector2(overlayOffsetX, overlayOffsetY))
			
			
		wallData.texture = textureFromImages(wallImage.images)
		walls.append(wallData)
	
		
	print("Finished loading XLDLabData")


class FloorData:
	var flags: int
	var frames: int
	var texture: Texture

class WallData:
	var flags: int
	var frames: int
	var textureWidth: int
	var textureHeight: int
	var texture: Texture
	var overlayCount: int
	
class XLDImage:
	extends XLD.Section
	
	var paletteIndex: int
	var width: int
	var height: int
	var frames: int
	var pixelCoordTransform : Transform2D = Transform2D.IDENTITY
	var images: Array
	var paletteManager
	
	func loadContents(file: File):	
		assert(length == width * height * frames, 
		"Unexpected length in bytes: %d. Width: %d, Height: %d, Frames Count: %d, index: %d, file: %s" % [length, width, height, frames, index, file.get_path()])

		images = []
		
		for i in frames:
			var image = Image.new()
			image.create(width, height, false, Image.FORMAT_RGBA8)
			image.lock()
			
			
			for x in width:
				for y in height:
					var colorIndex = file.get_8()
					var color = paletteManager.getColor(paletteIndex, colorIndex)
					image.set_pixelv(pixelCoordTransform.xform(Vector2(x, y)), color)
			image.unlock()
			images.append(image)
		
