extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var chase = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var player = get_tree().get_first_node_in_group('player')
	
	var direction = (player.position - self.position).normalized()
	if chase:
		velocity.x = direction.x * SPEED
		$AnimatedSprite2D.play('run')
	else:
		$AnimatedSprite2D.play("idle")
		
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
		$damage.scale.x = -1
		
	elif direction.x > 0:
		$AnimatedSprite2D.flip_h = false
		$damage.scale.x = 1
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		chase = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		chase = false


func _on_damage_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		body.get_dmg(999)
