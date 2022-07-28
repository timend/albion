extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var map = preload("res://xldimports/tilemap_0.tscn").instance()
	add_child(map)
	
	var mainCharacter = $MainCharacter	
	remove_child(mainCharacter)
	map.get_node("YSort").add_child(mainCharacter)

	mainCharacter.transform.origin = Vector2(8, 8)*16
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
