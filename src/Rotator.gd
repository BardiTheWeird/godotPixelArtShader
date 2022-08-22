extends Spatial
class_name Rotator

export (Vector3) var rotation_velocity := Vector3.ZERO

var should_rotate := true

func _process(delta):
	if should_rotate:
		get_parent().rotation += deg2radv(rotation_velocity) * delta
		
func _input(event):
	if event.is_action_pressed("ui_accept"):
		should_rotate = !should_rotate

func deg2radv(v : Vector3) -> Vector3:
	return Vector3(
		deg2rad(v.x),
		deg2rad(v.y),
		deg2rad(v.z)
	)
