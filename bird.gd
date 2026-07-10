extends CharacterBody2D

const GRAVITY = 1500.0
const MAX_VELOCITY = 900.0
const JUMP_VELOCITY = -850.0
var falling: bool = false
var flying: bool = false
const START_POS = Vector2(180,960)

func _ready():
	reset()

func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)
	
	
func _physics_process(delta: float) -> void:
	if flying or falling:
		velocity.y += GRAVITY * delta
		
		if velocity.y >= MAX_VELOCITY:
			velocity.y = MAX_VELOCITY
		
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05)) 
			$AnimatedSprite2D.animation = "upflap"
			$AnimatedSprite2D.play()
		else:	
			set_rotation(PI/2)
		move_and_collide(delta*velocity)
	else:
		$AnimatedSprite2D.stop()

func flap():
	velocity.y = JUMP_VELOCITY


#const SPEED = 300.0
#const JUMP_VELOCITY = -850.0
#var screen_size

#@export var custom_gravity: float = 1500.0
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += custom_gravity * delta
	#
		#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_up"):
		#
		#velocity.y = JUMP_VELOCITY
	#
		#
	#
	#if velocity.y <=0:
		#$AnimatedSprite2D.animation = "upflap"
	#else:	
		#$AnimatedSprite2D.animation = "downflap"
	#
	#$AnimatedSprite2D.play()
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	##var direction := Input.get_axis("ui_left", "ui_right")
	##if direction:
		##velocity.x = direction * SPEED
	##else:
		##velocity.x = move_toward(velocity.x, 0, SPEED)
	#screen_size = get_viewport_rect().size
	#position = position.clamp(Vector2.ZERO, screen_size - screen_size * 0.2)
	#
	#move_and_slide()
	#
