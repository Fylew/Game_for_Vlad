extends RigidBody2D


var has_triggered: bool = false

func _ready() -> void:
	freeze = true

func _on_dmg_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		body.get_dmg(1)


func _on_triger_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		set_deferred("freeze", false)
		if not has_triggered:
			$AudioStreamPlayer2D.play()
			has_triggered = true



func _on_body_entered(body: Node) -> void:
	await  get_tree().create_timer(2.0).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
