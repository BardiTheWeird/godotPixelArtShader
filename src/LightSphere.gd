tool
extends OmniLight

export (Color) var color : Color = Color.yellow setget set_color
export (float) var opacity := 0.2 setget set_opacity
export (float) var radius := 0.05 setget set_radius

onready var mesh = $Mesh

func set_color(value : Color):
	color = value
	if not is_inside_tree() and not Engine.editor_hint:
		return
	set_children_properties()
	
func set_opacity(value : float):
	opacity = value
	if not is_inside_tree() and not Engine.editor_hint:
		return
	set_children_properties()

func set_radius(value : float):
	radius = value
	if not is_inside_tree() and not Engine.editor_hint:
		return
	set_children_properties()

func _ready():
	set_children_properties()

func set_children_properties():
	if Engine.editor_hint:
		mesh = $Mesh
		
	light_color = color
	
	var sphere : SphereMesh = mesh.mesh
	sphere.radius = radius
	sphere.height = radius * 2
	
	var mesh_material : SpatialMaterial = mesh.get_active_material(0)
	mesh_material.flags_transparent = true
	mesh_material.emission = color
	mesh_material.albedo_color = color
	mesh_material.albedo_color.a = opacity
