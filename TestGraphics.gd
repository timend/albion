extends Node2D

var xldSprite

func _ready():
#	var partgr = XLD.new()
#	partgr.load("res://XLDLIBS/PARTGR0.XLD", funcref(XLDSprite, "new"))
#
#	xldSprite = partgr.sections[5]
#
#	var image = Image.new() 
#	image.create(32*17, 48*56,false,Image.FORMAT_RGBA8)
#
#	for i in 56:
#		if i == 11 || i == 16:
#			continue
#
#		xldPaletteManager.paletteIndex = i
#		xldSprite.loaded = false
#		xldSprite.load()
#		image.blit_rect(xldSprite.image, Rect2(0, 0, 32*17, 48), Vector2(0, 48*i))

	var icongfx = XLD.new()
	icongfx.load("res://XLDLIBS/ICONGFX0.XLD", funcref(XLDIconSprite, "new"))

	xldSprite = icongfx.sections[10]
	xldSprite.load()

	var texture = ImageTexture.new()
	texture.create_from_image(xldSprite.image)
	$Sprite.texture = texture	
