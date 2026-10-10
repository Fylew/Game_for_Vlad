extends CharacterBody2D

enum State {PATROL, SURPRISE, CHARGE, SUTUNED, MELEE, SUMMON, DEAD}
var current_state = State.PATROL

@export_group("Настройки")
@export var max_hp: int = 15
@export var patrol_speed: float = 100.0
@export var charge_speed: float = 600.0
@export var jump_velocity: float = -200.0

@export_group("Графика")
@export var ghost_scene: PackedScene
@export var left_point: Marker2D
@export var right_point: Marker2D

var hp: int = max_hp
var facing: int = 1

@onready var anim = $AnimatedSprite2D
@onready var wall_check = $RayCast2D
@onready var vision_zone = $VisionZone
@onready var melle_zone = $MelleZone


func _ready() -> void:
	hp = max_hp

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match  current_state:
		State.PATROL:
			_process_patrol()
		State.SURPRISE, State.SUTUNED, State.DEAD, State.MELEE, State.SUMMON:
			velocity.x = move_toward(velocity.x, 0, patrol_speed)
		State.CHARGE:
			_process_charge()

	move_and_slide()

func _process_patrol() -> void:
	
	for body in melle_zone.get_overlapping_bodies():
		if body.is_in_group("player"):
			_start_melee()
			return
	
	for body in vision_zone.get_overlapping_bodies():
		if body.is_in_group("player"):
			if randf() >0.3:
				_start_summon()
			else:
				_start_surprise(body)
			return
	
	velocity.x = patrol_speed * facing
	anim.play("Idle")
	anim.flip_h = (facing < 0 )
	
	if left_point and right_point:
		var right_bound = max(left_point.global_position.x, right_point.global_position.x)
		var left_bound = min(left_point.global_position.x, right_point.global_position.x)
		
		if facing == 1 and global_position.x >= right_bound:
			_flip()
		elif facing == -1 and global_position.x <= left_bound:
			_flip()


func _process_charge() -> void:
	velocity.x = charge_speed * facing
	anim.play("run")
	anim.flip_h = (facing < 0)
	
	if wall_check.is_colliding():
		_stun_boss()

func _start_surprise(player: Node2D) -> void:
	current_state = State.SURPRISE
	velocity.y = jump_velocity
	velocity.x = 0
	await get_tree().create_timer(0.5).timeout
	
	if current_state == State.SURPRISE:
		if is_instance_valid(player):
			var dir_to_payer = sign(player.global_position.x - global_position.x)
			if dir_to_payer != 0 and dir_to_payer != facing:
				_flip()
		current_state = State.CHARGE

func _start_melee() -> void:
	current_state = State.MELEE
	anim.play("attack_1")
	await get_tree().create_timer(0.4).timeout
	
	if current_state == State.MELEE:
		for body in melle_zone.get_overlapping_bodies():
			if body.is_in_group('player'):
				body.get_dmg(1)
	await get_tree().create_timer(0.4).timeout
	if current_state == State.MELEE:
		current_state = State.PATROL

func _start_summon() -> void:
	current_state = State.SUMMON
	anim.play("attack_2")
	await get_tree().create_timer(0.4).timeout
	
	if current_state == State.SUMMON and ghost_scene:
		for i in range(16):
			var ghost = ghost_scene.instantiate()
			ghost.global_position = global_position
			var angle = deg_to_rad(i * 25)
			ghost.
