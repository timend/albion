extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("east"):
		velocity = Vector2(1, 0)
		$AnimationPlayer.play("walk_e")
	elif Input.is_action_pressed("west"):
		velocity = Vector2(-1, 0)
		$AnimationPlayer.play("walk_w")
	elif Input.is_action_pressed("north"):
		velocity = Vector2(0, -1)
		$AnimationPlayer.play("walk_n")
	elif Input.is_action_pressed("south"):
		velocity = Vector2(0, 1)
		$AnimationPlayer.play("walk_s")
	else:
		velocity = Vector2.ZERO
		$AnimationPlayer.stop()
	velocity = velocity * 16 * 6

func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)
