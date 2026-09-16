extends StaticBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var nose = false

func _ready() -> void:
	animation.play("quieto")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bullet"):
		animation.play("Retroceso")
		animation.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _on_animated_sprite_2d_animation_finished() -> void:
	animation.play("quieto")
