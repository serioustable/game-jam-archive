extends Sprite

var pickup_rotation_speed := 2
var weapon_type := 0
# 0 = Repeater
# 1 = Split
# 2 = Standard
var weapon_color := 0
# 0 = Blue
# 1 = Green
# 2 = Red

onready var gun_sprite := $Sprite
onready var base_sprite := $TurretBaseSmall
onready var label := $Label
onready var audio_player := $AudioStreamPlayer

func _ready() -> void:
	randomize()
	weapon_type = randi() % 3
	weapon_color = randi() % 3
	set_weapon_sprite(weapon_type)
	audio_player.stream = preload("res://Sounds/MonsterEnergyReload.wav")
	audio_player.play()

func _process(delta: float) -> void:
	gun_sprite.rotation += pickup_rotation_speed * delta
	

func set_weapon_sprite(type : int) -> void:
	match type:
		0:
			gun_sprite.texture = preload("res://Weapons/gun03.png")
		1: 
			gun_sprite.texture = preload("res://Weapons/gun09.png")
		2: 
			gun_sprite.texture = preload("res://Weapons/gun08.png")
	match weapon_color:
		0: 
			base_sprite.modulate = Color(0, 0, 1, 0.4)
			label.text = "B"
			label.add_color_override("font_color", Color.dodgerblue)
		1: 
			base_sprite.modulate = Color(0, 1, 0, 0.4)
			label.text = "G"
			label.add_color_override("font_color", Color.forestgreen)
		2: 
			base_sprite.modulate = Color(1, 0, 0, 0.4)
			label.text = "R"
			label.add_color_override("font_color", Color.firebrick)

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if body.is_weapon_equipped == false:
			body.add_weapon(weapon_type, weapon_color)
			hide()
			$Area2D/CollisionShape2D.set_deferred("disabled", true)
			queue_free()
