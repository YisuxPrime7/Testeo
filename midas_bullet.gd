extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed:float

func _physics_process(delta: float) -> void:
	
	animated_sprite_2d.play("Shoot")
	velocity.x = speed
	
	move_and_slide()
