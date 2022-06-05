extends Area2D

var damage := 50
var damage_type := 0
# 0 = Blue
# 1 = Green
# 2 = Red
var projectile_speed := 1000

onready var sprite := $Sprite

func _process(delta: float) -> void:
	position -= transform.y * projectile_speed * delta

func set_damage_amount(new_damage : int) -> void:
	damage = new_damage

func set_damage_color(new_color : int) -> void:
	damage_type = new_color
	match new_color:
		0: 
			pass
		1: 
			sprite.texture = preload("res://Weapons/laserGreen11.png")
		2: 
			sprite.texture = preload("res://Weapons/laserRed01.png")

func disable_collision() -> void:
	$CollisionShape2D.set_deferred("disabled", true)

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
