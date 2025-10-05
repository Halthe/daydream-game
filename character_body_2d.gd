extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var void_y_threshold: float = 800.0

const SPEED = 200.0
const JUMP_VELOCITY = -450.0
var last_safe_position: Vector2
func _ready() -> void:
	# Initialize safe position at starting point
	last_safe_position = global_position
	
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get horizontal movement input
	var direction := Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Handle animations
	if not is_on_floor():
		# In the air → choose jump or fall animation
		if velocity.y < 0:
			if animated_sprite_2d.animation != "jump":
				animated_sprite_2d.play("jump")
		else:
			if animated_sprite_2d.animation != "jump":
				animated_sprite_2d.play("jump")
	else:
		# On the ground → idle or walk
		if direction != 0:
			if animated_sprite_2d.animation != "walk":
				animated_sprite_2d.play("walk")
		else:
			if animated_sprite_2d.animation != "idle":
				animated_sprite_2d.play("idle")

	move_and_slide()
	
	if is_on_floor():
		last_safe_position = global_position

	# ✅ Check if player has fallen below the void threshold
	if global_position.y > void_y_threshold:
		respawn_to_last_safe_position()


func respawn_to_last_safe_position() -> void:
	global_position = last_safe_position
	velocity = Vector2.ZERO
