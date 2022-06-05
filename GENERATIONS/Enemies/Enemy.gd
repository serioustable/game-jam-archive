extends Area2D

enum ENEMY_CLASS { BASIC, LINGER, BOSS} 
export (ENEMY_CLASS) var enemy_class := ENEMY_CLASS.BASIC

export var health := 100
export var drop_speed := 75
export var linger_max_patrol_distance := 20
export var linger_patrol_speed := 5
export var linger_vertical_max := 100
export var linger_vertical_min := 200

var home_x_value := 0.0
var home_y_value := 0.0
var begin_patrolling := false
var patrolling_direction := "left"

var blue_resistance := 0.0
var green_resistance := 0.0
var red_resistance := 0.0

var invulnerable := false
var first_appearance := false
var screen_size

onready var refire_timer := $RefireTimer
onready var baby_spawn_timer := $BabySpawnTimer
onready var tween := $Tween
onready var enemy_projectile := preload("res://Enemies/EnemyProjectile.tscn")
onready var hit_particles := preload("res://Weapons/OnHitParticles.tscn")
onready var res_shield := $ResShield
onready var death_explosion := preload("res://Enemies/EnemyExplosion.tscn")
onready var audio_player := $AudioStreamPlayer

signal dead

func _ready() -> void:
	screen_size = get_viewport_rect().size
	home_x_value = global_position.x
	if enemy_class == ENEMY_CLASS.LINGER:
		first_appearance = true
		home_y_value = rand_range(linger_vertical_min, linger_vertical_max)
		tween.interpolate_property(self,"position", Vector2(global_position.x, global_position.y), Vector2(global_position.x, home_y_value), 2.0, Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.start()
		refire_timer.start()
	var res_intensity := min((blue_resistance + green_resistance + red_resistance) * 3, 1.0) 
	res_shield.modulate = Color(red_resistance, green_resistance, blue_resistance, res_intensity)

func _physics_process(delta: float) -> void:
	position.y += drop_speed * delta
	if enemy_class == ENEMY_CLASS.LINGER and begin_patrolling == true:
		match patrolling_direction:
			"left":
				position.x -= linger_patrol_speed * delta
				if position.x < home_x_value - linger_max_patrol_distance or position.x < 20:
					patrolling_direction = "right"
			"right":
				position.x += linger_patrol_speed * delta
				if position.x > home_x_value + linger_max_patrol_distance or position.x > screen_size.x - 20:
					patrolling_direction = "left"
	

func set_resistances(blue : float, green : float, red : float) -> void:
	blue_resistance = blue
	green_resistance = green
	red_resistance = red

func take_damage(damage_amount : int, damage_color : int, hit_vector : Vector2) -> void:
	if invulnerable == true:
		pass
	var particles = hit_particles.instance()
	particles.set_color(damage_color)
	audio_player.stream = preload("res://Sounds/SingleShot4.wav")
	audio_player.pitch_scale = rand_range(0.75, 1.25)
	var damage_taken
	
	match damage_color:
		0: 
			damage_taken = damage_amount - (damage_amount * blue_resistance)
		1: 
			damage_taken = damage_amount - (damage_amount * green_resistance)
		2: 
			damage_taken = damage_amount - (damage_amount * red_resistance)
			
	var knock_back_vector := hit_vector - global_position
	var knock_back_amount : float = damage_taken / damage_amount
	if enemy_class == ENEMY_CLASS.LINGER:
		knock_back_amount = knock_back_amount / 2
	if first_appearance == false and damage_taken > 0: 
		tween.interpolate_property(self, "global_position", global_position, global_position - (knock_back_vector * knock_back_amount), 0.4 * knock_back_amount, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
	health -= damage_taken
	particles.set_damage_scale(damage_taken)
	if float(damage_taken) < float(damage_amount) / 3:
		audio_player.pitch_scale = 2
	particles.global_position = global_position
	particles.emitting = true
	audio_player.play()
	get_tree().current_scene.add_child(particles)
	if health <= 0:
		die(damage_color)
		invulnerable = true

func die(damage_color : int) -> void:
	$CollisionShape2D.set_deferred("disabled", true)
#	if (randi() % 4) == 0 and damage_color != 3:
#		var weapon_to_drop := preload("res://Weapons/Pickups/PickupGun.tscn").instance()
#		get_tree().current_scene.add_child(weapon_to_drop)
#		weapon_to_drop.global_position = global_position
	var explosion = death_explosion.instance()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	emit_signal("dead", damage_color)
	queue_free()


func _on_Enemy_body_entered(body: Node) -> void:
	body.enemy_collision()
	queue_free()

func _on_Enemy_area_entered(area: Area2D) -> void:
	if area.is_in_group("Thrown_Gun"):
		die(3)
	if area.is_in_group("Projectiles"):
		take_damage(area.damage, area.damage_type, area.global_position)
		area.disable_collision()
		area.queue_free()

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()

func _on_Tween_tween_all_completed() -> void:
	begin_patrolling = true
	first_appearance = false

func _on_RefireTimer_timeout() -> void:
	var new_projectile = enemy_projectile.instance()
	new_projectile.global_position = global_position
	new_projectile.position.y += 10
	get_tree().current_scene.add_child(new_projectile)
	audio_player.stream = preload("res://Sounds/LaserAttackMini.wav")
	audio_player.pitch_scale = rand_range(0.75, 1.25)
	audio_player.play()
