extends Area2D

@export var level: PackedScene

var flag = false


func _process(delta: float) -> void:
	if flag and Input.is_action_just_pressed('e'):
		get_tree().change_scene_to_packed(level)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		body.get_presd_e()
		flag = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		body.anim_stop()
		flag = false
