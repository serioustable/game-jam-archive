extends KinematicBody2D

const SPEED := 600.0
const DRAG_FACTOR := 0.15

var velocity := Vector2.ZERO
var direction := Vector2.ZERO

var screen_size := Vector2.ZERO
var is_weapon_equipped := false

var weapon

onready var weapon_hardpoint := $WeaponHardpoint
onready var ship_sprite := $ShipSprite
onready var label := $Label
onready var tween := $Tween
onready var death_explosion := preload("res://Enemies/EnemyExplosion.tscn")

signal hit

func _ready() -> void:
	screen_size = get_viewport_rect().size
	var sprite_ending_position = ship_sprite.position
	ship_sprite.position.y += 300
	tween.interpolate_property(ship_sprite, "position", ship_sprite.position, Vector2(sprite_ending_position.x, sprite_ending_position.y), 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("throw_weapon") and is_weapon_equipped == true:
		throw_weapon()

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var desired_velocity := SPEED * direction
	var steering_velocity := desired_velocity - velocity
	velocity += steering_velocity * DRAG_FACTOR
	velocity = move_and_slide(velocity)
	
	position.x = clamp(position.x, 0 + 20, screen_size.x - 20)
	position.y = clamp(position.y, 0 + 20, screen_size.y - 20)

func set_ship_color(new_color_ID : int) -> void:
	match new_color_ID:
		0:
			ship_sprite.texture = preload("res://Player/playerShip1_blue.png")
			label.text = "BLU"
			label.add_color_override("font_color", Color.dodgerblue)
		1: 
			ship_sprite.texture = preload("res://Player/playerShip1_green.png")
			label.text = "GRN"
			label.add_color_override("font_color", Color.forestgreen)
		2: 
			ship_sprite.texture = preload("res://Player/playerShip1_red.png")
			label.text = "RED"
			label.add_color_override("font_color", Color.firebrick)
		3: 
			ship_sprite.texture = preload("res://Player/playerShip1_orange.png")
			label.text = ""

func add_weapon(weapon_type : int, weapon_color : int) -> void:
	if is_weapon_equipped == false:
		weapon = preload("res://Weapons/Equipped/EquippedGun.tscn").instance()
		weapon_hardpoint.add_child(weapon)
		weapon.set_weapon_type(weapon_type)
		weapon.set_weapon_color(weapon_color)
		set_ship_color(weapon_color)
		is_weapon_equipped = true
	else:
		pass

func throw_weapon() -> void:
	if is_weapon_equipped == false:
		pass
	is_weapon_equipped = false
	var thrown_weapon = preload("res://Weapons/Thrown/ThrownGun.tscn").instance()
	get_tree().current_scene.add_child(thrown_weapon)
	thrown_weapon.set_weapon_type(weapon.weapon_type)
	thrown_weapon.global_position = global_position
	thrown_weapon.global_position.y -= 20
	weapon.queue_free()
	set_ship_color(3)

func enemy_collision() -> void:
	emit_signal("hit")
	var explosion = death_explosion.instance()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	queue_free()
