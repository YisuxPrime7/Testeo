extends Camera2D

@onready var camera_2d: Camera2D = $"."
@export var distance_move: float


func _physics_process(delta: float) -> void:
	
	var direction = Input.get_axis("Left", "Right")
	var objetivo_offset = direction * distance_move
	$".".offset.x = lerp($".".offset.x, objetivo_offset, 2.5 * delta)
