class_name Grass extends HexTile

func _ready():
	hexMeshName = 'grass'
	hexMeshScene = load("res://Content/Resources/Visual/3D/Map/Tiles/grass.glb")
	
	hexMesh = hexMeshScene.instantiate().duplicate()
	add_child(hexMesh)
	%Highlight.light_energy = 0
