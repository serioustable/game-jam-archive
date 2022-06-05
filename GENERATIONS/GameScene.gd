extends Node2D

var next_gen_blue_res := 0.0
var next_gen_green_res := 0.0
var next_gen_red_res := 0.0

var current_gen_blue_res := 0.0
var current_gen_green_res := 0.0
var current_gen_red_res := 0.0

var enemies_destroyed := 0

export var mobs_per_wave := 10
var current_wave_count := 0
var current_wave := 0
var incoming_damage_type := 0

var is_game_over := false

var screen_size

export (PackedScene) var simple_mob
export (PackedScene) var linger_mob
export (PackedScene) var boss_mob
export (PackedScene) var player_scene
export (PackedScene) var pickup_gun_scene

onready var mob_spawn_timer := $MobSpawnTimer
onready var wave_delay_timer := $WaveDelayTimer
onready var start_timer := $StartTimer
onready var pickup_spawn_timer := $PickupSpawner
onready var player_start_position := $PlayerStartPosition
onready var pickup_start_position := $FirstPickupStartPosition
onready var ready_label := $GetReadyLabel
onready var game_over_label := $GameOver
onready var retry_button := $HUD/RetryButton
onready var quit_button := $HUD/QuitButton
onready var audio_player := $AudioStreamPlayer
onready var bg_player := $BackgroundMusicPlayer
onready var game_over_timer := $GameOverTimer

onready var evolves_timer_label := $HUD/EvolvesIn/EvolvesTimer
onready var destroyed_counter_label := $HUD/Destroyed/DestroyedCount
onready var bres_label := $HUD/BResIcon/BRes
onready var gres_label := $HUD/GResIcon/GRes
onready var rres_label := $HUD/RResIcon/RRes

func _ready() -> void:
	randomize()
	screen_size = get_viewport_rect().size
	game_over_label.hide()
	retry_button.hide()
	quit_button.hide()

func _process(_delta: float) -> void:
	evolves_timer_label.text = str(round(wave_delay_timer.time_left))

func game_over() -> void:
	audio_player.stream = preload("res://Sounds/GreaterHit.wav")
	audio_player.play()
	bg_player.stop()
	is_game_over = true
	mob_spawn_timer.stop()
	wave_delay_timer.stop()
	pickup_spawn_timer.stop()
	game_over_timer.start()

func game_start() -> void:
	audio_player.stream = preload("res://Sounds/FastSpaceShipsBesideMe.wav")
	audio_player.play()
	enemies_destroyed = 0
	mob_spawn_timer.start()
	wave_delay_timer.start()
	pickup_spawn_timer.start()
	update_labels()
	ready_label.hide()
	
	var player = player_scene.instance()
	player.global_position = player_start_position.global_position
	add_child(player)
	player.connect("hit", self, "game_over")
	
	var pickup = pickup_gun_scene.instance()
	pickup.global_position = pickup_start_position.global_position
	add_child(pickup)

func spawn_enemy() -> void:
	var mob
# warning-ignore:narrowing_conversion
	var lingering_mob_spawn : int = min(7 - (current_wave + 1), 4)
	if lingering_mob_spawn < 1:
		lingering_mob_spawn = 1
	if (randi() % lingering_mob_spawn) == 0:
		mob = linger_mob.instance()
	else:
		mob = simple_mob.instance()
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob.set_resistances(current_gen_blue_res, current_gen_green_res, current_gen_red_res)
	mob_spawn_location.offset = randi()
	mob.position = mob_spawn_location.position
	mob.connect("dead", self, "add_generational_resistance")
	add_child(mob)
	
func add_generational_resistance(damage_type : int) -> void:
	enemies_destroyed += 1
	match damage_type:
		0:
			next_gen_blue_res = min(next_gen_blue_res + 0.1, 1.0)
		1:
			next_gen_green_res = min(next_gen_green_res + 0.1, 1.0)
		2:
			next_gen_red_res = min(next_gen_red_res + 0.1, 1.0)
		3:
			next_gen_blue_res = max(next_gen_blue_res - 0.1, 0.0)
			next_gen_green_res = max(next_gen_green_res - 0.1, 0.0)
			next_gen_red_res = max(next_gen_red_res - 0.1, 0.0)
	update_labels()

func update_labels() -> void:
	destroyed_counter_label.text = str(enemies_destroyed)
	
	var blue_percent = next_gen_blue_res * 100
	var blue_percent_string = "%s%%"
	bres_label.text = blue_percent_string % blue_percent
	
	var green_percent = next_gen_green_res * 100
	var green_percent_string = "%s%%"
	gres_label.text = green_percent_string % green_percent
	
	var red_percent = next_gen_red_res * 100
	var red_percent_string = "%s%%"
	rres_label.text = red_percent_string % red_percent

func _on_StartTimer_timeout() -> void:
	game_start()

func _on_MobSpawnTimer_timeout() -> void:
	spawn_enemy()
	current_wave_count += 1
	if current_wave_count == mobs_per_wave:
		mob_spawn_timer.stop()

func _on_WaveDelayTimer_timeout() -> void:
	current_wave_count = 0
	current_wave += 1
	current_gen_blue_res = next_gen_blue_res
	current_gen_green_res = next_gen_green_res
	current_gen_red_res = next_gen_red_res
	mob_spawn_timer.start()


func _on_PickupSpawner_timeout() -> void:
	var pickup = pickup_gun_scene.instance()
	pickup.global_position = pickup_start_position.global_position
	pickup.position.x = rand_range(100, screen_size.x - 100)
	add_child(pickup)


func _on_RetryButton_pressed() -> void:
	if is_game_over == true:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()


func _on_QuitButton_pressed() -> void:
	if is_game_over == true:
		get_tree().quit()


func _on_GameOverTimer_timeout() -> void:
	bg_player.stream = preload("res://Sounds/Music/Space Cadet.ogg")
	bg_player.play()
	game_over_label.show()
	retry_button.show()
	quit_button.show()
