extends MeshInstance3D

@export var soldier: CharacterBody3D

func _ready():
	mesh = mesh.duplicate(true)
	
	var parent = get_parent_node_3d()
	if parent is CharacterBody3D:
		soldier = parent
		soldier.connect('selected', Callable(self, 'onSelected'))
		soldier.connect('deselected', Callable(self, 'onDeselected'))

func onSelected():
	var tween = create_tween()
	tween.tween_property(mesh.material, 'emission', Color.DIM_GRAY, 0.2)

func onDeselected():
	var tween = create_tween()
	tween.tween_property(mesh.material, 'emission', Color.BLACK, 0.2)

func changeColor(playerColor):
	match playerColor:
		PlayerUtil.playerColor.WHITE:
			mesh.material.albedo_color = Color.GREEN
		PlayerUtil.playerColor.BLACK:
			mesh.material.albedo_color = Color.RED
		_:
			mesh.material.albedo_color = Color.BLUE
