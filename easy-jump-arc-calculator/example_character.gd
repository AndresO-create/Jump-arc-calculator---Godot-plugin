extends CharacterBody2D
@onready var jump_arc_calculator: Node2D = $JumpArcCalculator


var horizontal_velocity 
var jump_velocity
var rising_gravity
var falling_gravity
var time_elapsed : float = 0

func _ready() -> void:
	horizontal_velocity = jump_arc_calculator.horizontal_velocity
	jump_velocity = -jump_arc_calculator.jump_velocity
	rising_gravity = jump_arc_calculator.rising_gravity
	falling_gravity = jump_arc_calculator.falling_gravity

	print(jump_velocity)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and velocity.y < 0:
		velocity.y += rising_gravity * delta
		time_elapsed += delta
	elif not is_on_floor():
		velocity.y += falling_gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * horizontal_velocity
	else:
		velocity.x = move_toward(velocity.x, 0, horizontal_velocity)

	move_and_slide()
