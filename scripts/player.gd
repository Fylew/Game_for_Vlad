extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var HP = 3

var is_hiting = false
@export var coyote_dcuration: float = 0.5
var coyote_timer: float = 0.0



@export_group("Деш")
@export var double_tap_window: float = 0.25
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.15
@export var dash_coldown: float = 0.5
@export var dash_invulnerable: bool = true

var last_left_tap: float = -10.0
var last_right_tap: float = -10.0

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dasg_direction: float = 1.0

var sound = {
	'run' : preload("res://assets/sound/run.wav"),
	'hit': preload("res://assets/sound/hit.wav"),
	'jump':preload("res://assets/sound/jum2p.wav")
	}


func _physics_process(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_dcuration
	
	if is_dashing:
		dash_timer -= delta
		velocity.x = dasg_direction * dash_speed
		velocity.y = 0
		if dash_timer <= 0.0:
			is_dashing = false
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play('jump')
		coyote_timer = 0.0
		sound_go('jump')

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if not is_hiting:
			$AnimatedSprite2D.play("run")

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_hiting:
			$AnimatedSprite2D.play("idle")
	
	var now:= Time.get_ticks_msec() / 1000.0
	if Input.is_action_just_pressed('ui_left'):
		if now - last_left_tap <= double_tap_window:
			_tray_dash(-1.0)
		last_left_tap = now
	if Input.is_action_just_pressed('ui_right'):
		if now - last_right_tap <= double_tap_window:
			_tray_dash(1.0)
		last_right_tap = now
		
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
	move_and_slide()
	

func _tray_dash(dir: float) -> void:
	if is_dashing or dash_cooldown_timer > 0.0:
		return
	dasg_direction = dir
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_coldown
	

func sound_go(name: String):
	$AudioStreamPlayer2D.stream = sound[name]
	$AudioStreamPlayer2D.play()
func get_dmg(damage)-> void:
	is_hiting = true
	HP -= damage
	sound_go('hit')
	$AudioStreamPlayer2D.play()
	await get_tree().create_timer(0.4).timeout
	if HP <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://scens/menu.tscn")
	is_hiting = false

func get_presd_e():
	$AnimationPlayer.play("start_e")

func anim_stop():
	$AnimationPlayer.stop()
