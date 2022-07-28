extends KinematicBody2D

export var texture : Texture setget texture_set, texture_get
export var label : String setget label_set, label_get
export var startPos : Vector2 setget startPos_set, startPos_get

func texture_set(texture):
	$Sprite.texture = texture

func texture_get():
	return $Sprite.texture

func label_set(text):
	$Label.text = text

func label_get():
	return $Label.text
	
func startPos_set(position):
	transform.origin = position * 16
	
func startPos_get():
	# not technically correct, as the position might have changed, but :shrug:
	return transform.origin / 16
	
enum {
	IDLE,
	WANDER
}

var state = IDLE

const TOLERANCE = 4.0

onready var target_position = transform.origin

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
