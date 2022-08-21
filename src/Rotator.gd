extends Spatial
class_name Rotator

export (Vector3) var rotation_velocity := Vector3.ZERO

func _process(delta):
	get_parent().rotation += deg2radv(rotation_velocity) * delta

func deg2radv(v : Vector3) -> Vector3:
	return Vector3(
		deg2rad(v.x),
		deg2rad(v.y),
		deg2rad(v.z)
	)
