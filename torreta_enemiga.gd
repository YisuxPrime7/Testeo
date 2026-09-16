extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D

var bullet = preload("res://Torreta_bullet.tscn")

var vida = 300

func _physics_process(delta: float) -> void:
	animated_sprite_2d.play("Idle")

func _on_timer_timeout() -> void:
	var shoot = bullet.instantiate()
	get_parent().add_child(shoot)
	shoot.global_position=$Marker2D.global_position
	animated_sprite_2d.play("Shoot")
