extends Sprite

var weapon_type := 0
# 0 = Repeater
# 1 = Split
# 2 = Standard
var weapon_color := 0
# 0 = Blue
# 1 = Green
# 2 = Red

onready var refire_timer := $RefireTimer
onready var audio_player := $AudioStreamPlayer

func _ready() -> void:
	audio_player.stream = preload("res://Sounds/ElectricAttack.wav")
	audio_player.play()

func set_weapon_type(new_type : int) -> void:
	weapon_type = new_type
	match new_type:
		0: 
			refire_timer.wait_time = 0.3
			texture = preload("res://Weapons/gun03.png")
		1: 
			refire_timer.wait_time = 1
			texture = preload("res://Weapons/gun09.png")
		2: 
			refire_timer.wait_time = 0.6
			texture = preload("res://Weapons/gun08.png")
	refire_timer.start()

func set_weapon_color(new_color : int) -> void:
	weapon_color = new_color

func _on_RefireTimer_timeout() -> void:
	var bullet := preload("res://Weapons/Projectile.tscn").instance()
	get_tree().current_scene.add_child(bullet)
	bullet.set_damage_color(weapon_color)
	bullet.global_position = global_position
	match weapon_type:
		0:
			audio_player.stream = preload("res://Sounds/MiniLaserAttack4.wav")
			audio_player.play()
		1: 
			audio_player.stream = preload("res://Sounds/SpaceGunFire2.wav")
			audio_player.play()
			for _number in range(2):
				var extra_bullet := preload("res://Weapons/Projectile.tscn").instance()
				get_tree().current_scene.add_child(extra_bullet)
				extra_bullet.set_damage_color(weapon_color)
				extra_bullet.global_position = global_position
				extra_bullet.rotation_degrees = rand_range(-8.0, 8.0)
		2: 
			bullet.set_damage_amount(70)
			audio_player.stream = preload("res://Sounds/DirectLaserAttack.wav")
			audio_player.play()
