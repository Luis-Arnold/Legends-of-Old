class_name Tower extends HexTile

func _ready():
	hexMeshName = 'tower'
	hexMeshScene = load("res://Content/Resources/Visual/3D/Map/Tiles/buildingTower.glb")
	
	hexMesh = hexMeshScene.instantiate().duplicate()
	add_child(hexMesh)
	%Highlight.light_energy = 0
