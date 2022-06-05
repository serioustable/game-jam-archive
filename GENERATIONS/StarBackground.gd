extends ParallaxBackground

export var camera_velocity := 100

func _process(delta: float) -> void:
	$ParallaxLayer.motion_offset.y += camera_velocity * delta
