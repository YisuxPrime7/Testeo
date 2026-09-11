extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hud = get_node("/root/Nivel/CanvasLayer")
@onready var door_blue = get_node("/root/Nivel/StaticBody2D")
@onready var hudg = get_node("/root/Nivel/UI_verde")
@onready var door_green = get_node("/root/Nivel/StaticBody2D2")
@onready var hudr = get_node("/root/Nivel/UI_roja")
@onready var door_red = get_node("/root/Nivel/Red_door")
@export var speed:float

signal player_die

enum STATE {IDLE, RUNNING, DIE, NONE}

var current_state:STATE = STATE.IDLE
var last_direction = "Down"
var blue_key = 0
var green_key = 0
var red_key = 0

func add_blue_key():
	blue_key +=1
	hud.set_blue_key(blue_key)
	door_blue.open_door("key")
	
func add_green_key():
	green_key += 1
	hudg.set_green_key(green_key)
	door_green.open_door("key")
	
func add_red_key():
	red_key += 1
	hudr.set_red_key(red_key)
	door_red.open_door("key")
	
func _physics_process(delta: float) -> void:
	
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	
	match current_state:
		STATE.IDLE:
			if velocity == Vector2.ZERO:
				animated_sprite_2d.play("Idle_" + last_direction)
			else:
				current_state = STATE.RUNNING
				
		STATE.RUNNING:
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x < 0:
					animated_sprite_2d.play("Run_Left")
					last_direction = "Left"
				else:
					animated_sprite_2d.play("Run_Right")
					last_direction = "Right"
					
			elif abs(velocity.y) > abs(velocity.x):
				if velocity.y < 0:
					animated_sprite_2d.play("Run_Up")
					last_direction = "Up"
				else:
					animated_sprite_2d.play("Run_Down")
					last_direction = "Down"
					
			else:
				current_state = STATE.IDLE
				
		STATE.DIE:
			velocity = Vector2.ZERO
			animated_sprite_2d.animation_finished.connect(on_animated_sprite_2d_animation_finished)
			animated_sprite_2d.play("Explosión")
			
			
	velocity = speed * direction 
	move_and_slide()

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Laser"):
		current_state = STATE.DIE
		
func on_animated_sprite_2d_animation_finished():
	queue_free()
	player_die.emit()
