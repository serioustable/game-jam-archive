extends Area2D

var falling_speed := 300

func _process(delta: float) -> void:
	position.y += falling_speed * delta


func _on_EnemyProjectile_body_entered(body: Node) -> void:
	body.enemy_collision()
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
