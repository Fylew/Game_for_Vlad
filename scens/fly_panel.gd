extends AnimatableBody2D

@export var pointA: Marker2D
@export var pointB: Marker2D
@export var speed: float = 100.0
@export var wait_time: float = 0.5
@export var is_moving: bool

var _target:Marker2D
var _waiting:=false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	global_position = pointA.global_position
	_target = pointB


func _physics_process(delta: float) -> void:
	if _waiting or not _target or not is_moving:
		return
	var distance := global_position.distance_to(_target.global_position)
	var step:= speed * delta
	
	if distance <= step:
		global_position = _target.global_position
		_swap_target()
		return
	
	global_position = global_position.move_toward(_target.global_position, step)
	
	
func _swap_target() -> void:
	_waiting = true
	await get_tree().create_timer(wait_time).timeout
	_target = pointA if _target == pointB else pointB
	_waiting = false
