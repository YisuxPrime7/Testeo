extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D

@onready var bullet = preload("res://Midas_bullet.tscn")

@export var speed:float
@export var jump_velocity: float
@export var gravity: float
@export var coyote_time: float

enum STATE_X {IDLE, RUN}
enum STATE_Y {JUMP}

var current_state_x: STATE_X
var current_state_y: STATE_Y
var coyote_timer = 0.0

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
		animation.play("Fall")
	else:
		current_state_y = STATE_Y.JUMP
		coyote_timer = coyote_time
	
	var direction = Input.get_axis("Left", "Right")
	
	match current_state_x:
		STATE_X.IDLE:
			velocity.x = 0
			animation.play("Idle")
			
			if direction != 0:
				current_state_x = STATE_X.RUN
		
		STATE_X.RUN:
			animation.play("Run")
			if direction < 0 or direction > 0:
				animation.flip_h= direction<0
				velocity.x = speed * direction
			else:
				current_state_x = STATE_X.IDLE
				
	match current_state_y:
		STATE_Y.JUMP:
			if Input.is_action_just_pressed("Jump") and (is_on_floor() or coyote_timer >0):
				velocity.y = jump_velocity
				coyote_timer = 0.0
				animation.play("Jump")

	
	move_and_slide()
	bullet_shoot()
	
func bullet_shoot():
	if Input.is_action_just_pressed("Shoot"):
		var Bullet = bullet.instantiate()
		get_parent().add_child(Bullet)
		Bullet.global_position = $Marker2D.global_position
	
