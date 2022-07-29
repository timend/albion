extends KinematicBody2D
tool

export var texture : Texture setget texture_set
export var label : String setget label_set
export var startPos : Vector2 setget startPos_set

func texture_set(value):
	texture = value
	$Sprite.texture = value


func label_set(value):
	label = value
	$Label.text = value

	
func startPos_set(value):
	startPos = value
	position = value * 16
	
	
enum {
	IDLE,
	WANDER
}

var state = IDLE

const TOLERANCE = 4.0

onready var target_position = position

func update_target_position():
	var target_vector
	
	if rand_range(-1, 1) > 0:
		target_vector = Vector2(round(rand_range(-5, 5))*16, 0)
	else: 
		target_vector = Vector2(0, round(rand_range(-5, 5)) * 16)

	if target_vector.x > 0:
		$AnimationPlayer.play("walk_e")
	elif target_vector.x < 0:
		$AnimationPlayer.play("walk_w")
	elif target_vector.y < 0:
		$AnimationPlayer.play("walk_n")
	elif target_vector.y > 0:
		$AnimationPlayer.play("walk_s")
	else:
		$AnimationPlayer.stop()
		
	
	target_position = position + target_vector

func is_at_target_position(): 
	# Stop moving when at target +/- tolerance
	return (target_position - position).length() < TOLERANCE

func _physics_process(delta):
	if Engine.editor_hint:
		return

	match state:
		IDLE:
			state = WANDER
			# Maybe wait for X seconds with a timer before moving on
			update_target_position()

		WANDER:
			var velocity = (target_position - position).normalized() * 16 * 6
		
			
			if is_at_target_position():
				state = IDLE
			else:
				var collision = move_and_collide(velocity*delta)
					
				if collision:
					state = IDLE
