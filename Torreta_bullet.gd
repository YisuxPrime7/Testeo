extends CharacterBody2D

var speed = -200

func _physics_process(delta: float) -> void:
	velocity.x = speed
	
	move_and_slide()
	bullet_destroy()
	
func bullet_destroy():
	var choques = get_slide_collision_count()
	
	for i in choques:
		var collision = get_slide_collision(i)
		var object_colide = collision.get_collider()
		
		if object_colide is TileMapLayer:
			queue_free()
