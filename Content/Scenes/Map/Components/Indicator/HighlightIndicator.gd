extends SpotLight3D

@export var tile: RigidBody3D

func _ready():
	var parent = get_parent_node_3d()
	if parent is Node3D:
		tile = parent
		tile.connect('select', Callable(self, 'onTileSelect'))
		tile.connect('deselect', Callable(self, 'onTileDeselect'))
	
	light_energy = 0

func onTileSelect():
	CameraUtil.selectedTiles.append(tile)
	light_energy = 1

func onTileDeselect():
	light_energy = 0
