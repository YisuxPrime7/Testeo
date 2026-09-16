extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var arrow_left: RayCast2D = $RayCastLeft
@onready var arrow_right: RayCast2D = $RayCastRight
@onready var hearts_3: Sprite2D = $"CanvasLayer/hearts 3"
@onready var hearts_2: Sprite2D = $"CanvasLayer/hearts 2"
@onready var hearts_1: Sprite2D = $"CanvasLayer/hearts 1"
@onready var barra_vacía: Sprite2D = $"CanvasLayer/Barra vacía"


@onready var bullet = preload("res://Midas_bullet.tscn")

@export var speed:float
@export var jump_velocity: float
@export var gravity: float
@export var dash_velocity: float
@export var wait_time: float
@export var time_cooldown: float
@export var coyote_time: float
@export var input_buffer_time: float
@export var corner_correction_amount: float

var dash_cooldown = false
var coyote_timer = 0.0
var input_buffer_timer = 0.0
var anim = "Idle"
var hearts = 3

func _physics_process(delta: float) -> void:
	
	var direction = Input.get_axis("Left", "Right")
	
	if direction != 0:
		anim = "Run"
		if direction:
			velocity.x = speed * direction
			animation.flip_h=direction<0
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = 0
		anim = "Idle"
	
	if Input.is_action_just_pressed("Jump"):
		input_buffer_timer = input_buffer_time
		
	if is_on_floor():
		coyote_timer = coyote_time
	
	if input_buffer_timer > 0 and (is_on_floor() or coyote_timer >0):
		anim = "Jump"
		velocity.y = jump_velocity
		coyote_timer = 0.0
		input_buffer_timer = 0.0
			
	if not is_on_floor():
		anim = "Fall"
		velocity.y += gravity * delta
		coyote_timer -= delta
		corner_correction()
	input_buffer_timer -= delta
		
		
	if Input.is_action_just_pressed("Dash"):
		anim = "Dasheo"
		is_dashing()

	move_and_slide()
	bullet_shoot()
	update_animation()

	
func corner_correction():
	if is_on_wall():
		return
	if arrow_left.is_colliding() and not arrow_right.is_colliding():
		position.x += corner_correction_amount
	elif arrow_right.is_colliding() and not arrow_left.is_colliding():
		position.x -= corner_correction_amount
	
func bullet_shoot():
	if Input.is_action_just_pressed("Shoot"):
		var Bullet = bullet.instantiate()
		get_parent().add_child(Bullet)
		Bullet.global_position = $Marker2D.global_position
		
func is_dashing():
	if dash_cooldown == false:
		speed = dash_velocity
		await get_tree().create_timer(wait_time).timeout
		dash_cooldown = true
		dashing_cooldown()
		
func dashing_cooldown():
	if dash_cooldown == true:
		speed = 200
		await get_tree().create_timer(time_cooldown).timeout
		dash_cooldown = false
		
func update_animation():
	animation.play(anim)
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy_Bullet"):
		hearts -= 1
		life_damage()
		
func life_damage():
	if hearts == 3:
		$"CanvasLayer/hearts 3".visible = true
		$"CanvasLayer/hearts 2".visible = true
		$"CanvasLayer/hearts 1".visible = true
	if hearts == 2:
		$"CanvasLayer/hearts 3".visible = false
		$"CanvasLayer/hearts 2".visible = true
		$"CanvasLayer/hearts 1".visible = true
	if hearts == 1:
		$"CanvasLayer/hearts 3".visible = false
		$"CanvasLayer/hearts 2".visible = false
		$"CanvasLayer/hearts 1".visible = true
	if hearts == 0:
		$"CanvasLayer/hearts 3".visible = false
		$"CanvasLayer/hearts 2".visible = false
		$"CanvasLayer/hearts 1".visible = false
		print("Te moriste perdedor")
		
		
