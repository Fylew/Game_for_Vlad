extends Area2D


@export var point: Marker2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.position = point.position
		body.get_dmg(1)
