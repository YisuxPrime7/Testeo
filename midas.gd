extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var arrow_left: RayCast2D = $RayCastLeft
@onready var arrow_right: RayCast2D = $RayCastRight
@onready var hearts_3: Sprite2D = $"CanvasLayer/hearts 3"
@onready var hearts_2: Sprite2D = $"CanvasLayer/hearts 2"
@onready var hearts_1: Sprite2D = $"CanvasLayer/hearts 1"
@onready var barra_vacía: Sprite2D = $"CanvasLayer/Barra vacía"
@onready var timer_invencibilidad=$Timerinvencibilidad

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

var direccion_disparo:Vector2=Vector2.RIGHT
var dash_cooldown = false
var coyote_timer = 0.0
var input_buffer_timer = 0.0
var anim = "Idle"
var hearts = 3

var move = true
var arrojar=true
var gancho
var disparar=true
var enganche
var empuje=50
var retroceso=false
var invencibilidad=false

func _physics_process(delta: float) -> void:
	if retroceso:
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("Jump"):
		input_buffer_timer = input_buffer_time
		anim = "Jump"
	
	if is_on_floor():
		coyote_timer = coyote_time
	
	#Esto permite que el jugador pueda saltar cuando esta apunto de tocar el suelo
	if input_buffer_timer > 0 and (is_on_floor() or coyote_timer >0):
		velocity.y = jump_velocity
		coyote_timer = 0.0
		input_buffer_timer = 0.0
			
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer -= delta
		corner_correction()
		input_buffer_timer -= delta
		
	if Input.is_action_just_pressed("Dash") && move:
		is_dashing()
		
	var direction
	
	if arrojar:
		direction = Input.get_axis("Left", "Right")
		
	if direction && direction != 0:
		anim = "Run"
		velocity.x = speed * direction
		animation.flip_h=direction<0
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		anim = "Idle"
		
	move_and_slide()
	
	direccion_bala()
			
	if move:
		bullet_shoot()
		
	update_animation()

func corner_correction():
	#Esto corrige la posición actual del jugador en función de la flecha que colisione, izquierda o derecha
	if is_on_wall():
		return
	if arrow_left.is_colliding() and not arrow_right.is_colliding():
		position.x += corner_correction_amount
	elif arrow_right.is_colliding() and not arrow_left.is_colliding():
		position.x -= corner_correction_amount
	
func bullet_shoot():
	if Input.is_action_just_pressed("Shoot") && disparar:
		var Bullet = bullet.instantiate()
		get_tree().current_scene.add_child(Bullet)
		Bullet.global_position = $Marker2D.global_position
		disparar=false
		$Timer2.start()
		
func is_dashing():
	#Cuando se inicia la función el dash_cooldown se desactiva (Porque el dash esta en ejecución)
	#Cambia la velocidad y activa un timer
	#Cuando el timer termine el dash cooldown se activa y llama a la función dash_cooldown
	if dash_cooldown == false:
		speed = dash_velocity
		await get_tree().create_timer(wait_time).timeout
		dash_cooldown = true
		dashing_cooldown()
		anim = "Dasheo"
		
func dashing_cooldown():
	#Aquí la velocidad vuelve a la normalidad y activa un timer
	#Cuando el timer termine el dash cooldown se desactiva permitiendo dashear de nuevo
	#Estas variables se pueden modificar arriba en las variables @export
	if dash_cooldown == true:
		speed = 200
		await get_tree().create_timer(time_cooldown).timeout
		dash_cooldown = false
		
func update_animation():
	animation.play(anim)

	
func player_curation():
	#Esta función hace que el player pueda curarse mediante corazones de vida
	hearts += 1
	life_damage()
	
func player_damage():
	#Esta función sirve para que el player reciba daño de enemigos y trampas
	hearts -= 1
	life_damage()
		
func life_damage():
	#Estas dos líneas evita que la vida se vaya acumulando
	#Esto debido a que el número de corazones que se tenga se acumula, teniendo mas vida de la que aparenta
	if hearts > 3:
		hearts -= 1
		
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
		
func direccion_bala():
	var direccion_input=Input.get_axis("Left","Right")
	
	if direccion_input!=0:
		if direccion_input<0:
			marker_2d.position.x=abs(marker_2d.position.x)*-1
			direccion_disparo=Vector2.LEFT
			
		if direccion_input>0:
			marker_2d.position.x=abs(marker_2d.position.x)
			direccion_disparo=Vector2.RIGHT

func _on_timer_timeout() -> void:
	arrojar=true
	
func _on_timer_2_timeout() -> void:
	disparar=true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if retroceso || invencibilidad:
		return
	if body.is_in_group("enemy"):
		var direction=(global_position-body.global_position).normalized()
		velocity=direction*empuje
		retroceso=true
		player_damage()
		
		if body.has_signal("golpear"):
			body.golpear.emit()
		
		await get_tree().create_timer(0.2).timeout.connect(func(): retroceso=false)
		
		invencibilidad=true
		timer_invencibilidad.start()
		parpadear()

func _on_timerinvencibilidad_timeout() -> void:
	invencibilidad=false
	animation.visible=true
	
func parpadear():
	while invencibilidad:
		animation.visible=!animation.visible
		await get_tree().create_timer(0.1).timeout


func _on_hitbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("Enemy_Bullet"):
		player_damage()
	if area.is_in_group("HitBox"):
		player_damage()
