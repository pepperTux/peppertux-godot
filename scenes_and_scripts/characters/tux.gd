extends CharacterBody2D

# Most of this code is from an older Godot PepperTux version.
# I think quite a bit of the code are from tutorials. The ones I found that will be used or have been used are below.

# I found these in the old Godot PepperTux code, by the way.
# https://www.youtube.com/watch?v=aQazVHDztsg
# https://www.youtube.com/playlist?list=PLMb6Yv6-w-RWngEjn_YeMzVwgyXBZ73Bf
# https://www.youtube.com/watch?v=M3BKy83wJ-g

# Movement
var speed = 320
var acceleration = 0.1
var deceleration = 0.08
var min_jump_height = 512
var max_jump_height = 576
var decelerate_on_jump_release = 0.5

# Skidding (Doesn't work right now)
var skid_time = 0.2
var skidding = false
var previous_direction = 1

# Cutscene
var in_cutscene = false

# Invincibility Frames
var invincibility_frames = 1

# Animation
var facing_direction = 1

func _ready() -> void:
	add_to_group("Tux")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor() and in_cutscene == false:
		$SmallJump.play()
		var current_speed = velocity.x
		if current_speed == 320 or current_speed == -320:
			velocity.y = -max_jump_height
		else:
			velocity.y = -min_jump_height
	
	# Handle Variable Jump Height
	if Input.is_action_just_released("player_jump") and velocity.y < 0 and in_cutscene == false:
		velocity.y *= decelerate_on_jump_release

	# Handle going left or right
	var direction := Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)

	# Handle Animations
	if not is_on_floor():
		$SmallTux.play("jump")
	elif velocity.x > 0 and not is_on_wall() or velocity.x < 0:
		if not skidding:
			$SmallTux.play("walk")
	else:
		$SmallTux.play("stand")
	
	if is_on_wall() and is_on_floor():
		$SmallTux.play("stand")
	
	if not direction == 0 and in_cutscene == false:
		$SmallTux.flip_h = direction < 0
	
	# Handle facing_direction changes
	if direction == -1:
		facing_direction = -1
	elif direction == 1:
		facing_direction = 1

	move_and_slide()
