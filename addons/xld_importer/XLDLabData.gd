tool
class_name XLDLabData
extends XLD.Section

var floors: Array
var walls: Array
var objects: Array
var objectInfos: Array
var paletteIndex: int
var wallHeight: float
var fogColor: Color
var fogDepthBegin: float
var fogDepthEnd: float

var xldPaletteManager = XLDPaletteManager.new()

const FLOOR_HEIGHT = 64
const FLOOR_WIDTH = 64

func toSigned16(unsigned16):
	return unsigned16 if unsigned16 & 0x8000 == 0 else -(0x10000 - unsigned16)	
	
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
	
	
func rotateImage90(image: Image) -> Image:
	var rotatedImage = Image.new()
	var width = image.get_width()
	var height = image.get_height()
	rotatedImage.create(height, width, false, Image.FORMAT_RGBA8)
	rotatedImage.lock()
	image.lock()
	
	for x in image.get_width():
		for y in image.get_height():
			rotatedImage.set_pixel(height - 1 - y, x, image.get_pixel(x, y))
	
	rotatedImage.unlock()
	image.unlock()
	
	return rotatedImage
	
func getImageSection(xlds: Array, textureNumber: int):
	var fileIndex = textureNumber / 100
	var sectionIndex = textureNumber - 1 if textureNumber < 100 else textureNumber % 100
	
	return xlds[fileIndex].sections[sectionIndex]
	
func loadContents(file: File):
	print("Loading some XLDLabData")	
	
	var xldFloorImages = []
	var xldWallImages = []
	var xldOverlayImages = []
	var xldObjectImages = []

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
		
	for i in 4:
		var xldObjectImage = XLD.new()
		xldObjectImage.load("res://XLDLIBS/3DOBJEC%d.XLD" % i, funcref(XLDImage, "new"))
		xldObjectImages.append(xldObjectImage)
	
	wallHeight = float(file.get_16()) / 256
	
	# header ignored for now
	file.get_buffer(8)
	
	fogDepthBegin = file.get_16()
	fogColor = Color8(file.get_16(), file.get_16(), file.get_16())
	
	
	file.get_buffer(12)
	fogDepthEnd = file.get_16()
	
	file.get_buffer(6)
	
	var objectCount = file.get_16()

	objects = []
	
	for i in objectCount:
		var objectData = ObjectData.new()
		objectData.autogfxType = file.get_8()
		file.get_8()
		objectData.subObjects = []

		for subObjectIndex in 8:
			var subObjectData = SubObjectData.new()
			var x = toSigned16(file.get_16())
			var z = toSigned16(file.get_16())
			var y = toSigned16(file.get_16())
			subObjectData.offset = Vector3(x, y, z)
			subObjectData.objectInfoIndex = file.get_16()

			if subObjectData.objectInfoIndex > 0:
				objectData.subObjects.append(subObjectData)
		

		objects.append(objectData)
	
	floors = []
	
	var floorCount = file.get_16()
	for i in floorCount:
		var floorData = FloorData.new()
		floorData.flags = file.get_8()
		file.get_buffer(3)
		floorData.frames = file.get_8()
		file.get_8()
		var textureNumber = file.get_16()
		file.get_16()
		
		var floorImage = getImageSection(xldFloorImages, textureNumber)
		floorImage.paletteIndex = paletteIndex
		floorImage.frames = floorData.frames
		floorImage.width = FLOOR_WIDTH
		floorImage.height = FLOOR_HEIGHT
		floorImage.paletteManager = xldPaletteManager
		#floorImage.pixelCoordTransform = Transform2D.FLIP_Y.rotated(PI / 2)
		floorImage.load()

		for image in floorImage.images:
			image.flip_y()
		
		floorData.texture = textureFromImages(floorImage.images)
		
		floors.append(floorData)
	
	var objectInfoCount = file.get_16()
	
#	file.get_buffer(objectInfoCount * 16)
	
	objectInfos = []
	
	for i in objectInfoCount:
		var objectInfo = ObjectInfo.new()
		objectInfo.flags = file.get_8()
		objectInfo.collisionData = file.get_buffer(3)
		
		var textureNumber = file.get_16()
		objectInfo.textureNumber = textureNumber

		objectInfo.frames = file.get_8()
		objectInfo.unknown = file.get_8()

		objectInfo.height = file.get_16()
		objectInfo.width = file.get_16()

		var objectImage = getImageSection(xldObjectImages, textureNumber)
		objectImage.paletteIndex = paletteIndex
		objectImage.frames = objectInfo.frames
		objectImage.height = objectInfo.height
		objectImage.width = objectInfo.width

		objectImage.paletteManager = xldPaletteManager
		objectImage.load()

		var rotatedImages = []
		for image in objectImage.images:
			rotatedImages.append(rotateImage90(image))

		objectInfo.texture = textureFromImages(rotatedImages)
		objectInfo.mapXSize = file.get_16()
		objectInfo.mapYSize = file.get_16()

		objectInfos.append(objectInfo)
		
#	for i in objects.size():
#		var subObject = objectInfos[objects[i].subObjects[0].objectInfoIndex - 1]
#		print("Object %d first subobject: textureNumber %d, width %d, height %d, frames %d, flags %d, collision %s" 
#		% [i, subObject.textureNumber, subObject.width, subObject.height, subObject.frames, subObject.flags, subObject.collisionData])

	var wallCount = file.get_16()
	
	for i in wallCount:
		var wallData = WallData.new()
		wallData.flags = file.get_8()
		var collision = file.get_buffer(3)
		#print("reading texture number for wall %d at position %d from %s" % [i, file.get_position(), file.get_path()])
		var textureNumber = file.get_16()
		#print("texture number: ", textureNumber)
		wallData.frames = file.get_8()
		var autoGfx = file.get_8()
		file.get_16()
		wallData.textureWidth = file.get_16()
		wallData.textureHeight = file.get_16()
		
		var wallImage = getImageSection(xldWallImages, textureNumber)
		wallImage.paletteIndex = paletteIndex
		wallImage.frames = wallData.frames
		wallImage.width = wallData.textureWidth
		wallImage.height = wallData.textureHeight
		wallImage.paletteManager = xldPaletteManager
		wallImage.load()
		
	
		var overlayCount = file.get_16()
		wallData.overlayCount = overlayCount
		for overlayIndex in overlayCount:
			var overlayTextureNumber = file.get_16() 
			var overlayFrames = file.get_8()
			var writeZero = file.get_8()
#			print("WriteZero: ", writeZero)
			var overlayOffsetX = toSigned16(file.get_16())
			var overlayOffsetY = toSigned16(file.get_16())
			var overlayWidth = file.get_16()
			var overlayHeight = file.get_16()
			
			#assert(overlayOffsetX + overlayWidth < wallData.textureWidth)
			#assert(overlayOffsetY + overlayHeight < wallData.textureHeight)
			assert(overlayFrames == 1)
			
			#assert(wallData.frames == 1, "Overlay on animated wall")
			
			var overlayImage = getImageSection(xldOverlayImages, overlayTextureNumber)
			overlayImage.paletteIndex = paletteIndex
			overlayImage.frames = overlayFrames
			overlayImage.width = overlayWidth
			overlayImage.height = overlayHeight
			overlayImage.paletteManager = xldPaletteManager
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
	
class ObjectData:
	var autogfxType: int
	var subObjects: Array
	
class SubObjectData:
	var offset: Vector3
	var objectInfoIndex: int
	
class ObjectInfo:
	var texture: Texture
	var width
	var height
	var textureNumber
	var unknown
	var mapXSize: int
	var mapYSize: int
	var collisionData
	var flags
	var frames
	
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
#		assert(length == width * height * frames, 
#		"Unexpected length in bytes: %d. Width: %d, Height: %d, Frames Count: %d, index: %d, file: %s" % [length, width, height, frames, index, file.get_path()])

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
		
