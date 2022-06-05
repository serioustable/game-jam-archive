extends Area2D

var throwing_speed := 600.0
var thrown_rotation_speed := 45

var weapon_type := 0
# 0 = Repeater
# 1 = Split
# 2 = Standard

onready var sprite := $Sprite
onready var audio_player := $AudioStreamPlayer

func _ready() -> void:
	audio_player.stream = preload("res://Sounds/ExtraHitPoint.wav")
	audio_player.play()

func _process(delta: float) -> void:
	rotation += thrown_rotation_speed * delta
	position.y -= throwing_speed * delta

func set_weapon_type(new_type : int) -> void:
	match new_type:
		0: 
			$Sprite.texture = preload("res://Weapons/gun03.png")
		1: 
			$Sprite.texture = preload("res://Weapons/gun09.png")
		2: 
			$Sprite.texture = preload("res://Weapons/gun08.png")


func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.
