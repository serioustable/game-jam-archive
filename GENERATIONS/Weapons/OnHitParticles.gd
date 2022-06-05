extends Particles2D

onready var timer := $Timer

func set_color( new_color : int) -> void:
	match new_color:
		0: 
			texture = preload("res://Weapons/laserBlue08.png")
		1: 
			texture = preload("res://Weapons/laserGreen14.png")
		2: 
			texture = preload("res://Weapons/laserRed08.png")

func set_damage_scale( damage_dealt : int) -> void:
	var new_scale : float = (float(damage_dealt) / 50.0)
	scale = Vector2(new_scale, new_scale)


func _on_Timer_timeout() -> void:
	queue_free()
