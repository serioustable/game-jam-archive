extends AnimatedSprite

onready var particles := $Particles2D
onready var sprite := $ExplosionSprite

func _ready() -> void:
	particles.emitting = true
	sprite.playing = true
	rotation_degrees = rand_range(-180.0, 180.0)

func _on_Timer_timeout() -> void:
	queue_free()

func _on_ExplosionSprite_animation_finished() -> void:
	sprite.hide()
