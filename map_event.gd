extends Area2D
export var triggerTypes : int
export var eventId : int

signal examine
signal touch
signal take

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_input_event(viewport, event, shape_idx):
	
	var shape :CollisionShape2D = shape_owner_get_owner(shape_idx)
	
	var tilePosition = (shape.position - Vector2(8, 8)) / 16
	
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT && !Input.is_key_pressed(KEY_META):
			print('touch button clicked for event ', eventId, ' at position ', tilePosition)
			emit_signal("touch", XLDMap.EVENT_TRIGGER.Touch, tilePosition)
		if event.button_index == BUTTON_LEFT && Input.is_key_pressed(KEY_META):
			print('take button clicked for event ', eventId, ' at position ', tilePosition)
			emit_signal("take", XLDMap.EVENT_TRIGGER.Touch, tilePosition)
		elif event.button_index == BUTTON_RIGHT:
			print('examine button clicked for event ', eventId, ' at position ', tilePosition)
			emit_signal("examine", XLDMap.EVENT_TRIGGER.Examine, tilePosition)	
