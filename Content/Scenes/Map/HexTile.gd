class_name HexTile extends RigidBody3D

@export_category('Core')
@export var q: int
@export var r: int
@export var hexMeshName: String
@export var hexMeshScene: PackedScene
@export var hexMesh: Node
@export var neighborHexTiles: Array = []

@export_category('Helper variables')
var hexDirections = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

func _ready():
	pass

func highlight():
	%Highlight.light_energy = 1

func unhighlight():
	%Highlight.light_energy = 0

func getNeighbor(direction: Vector2i) -> HexTile:
	return

func _on_neighbor_tracker_body_entered(body):
	if body is RigidBody3D and body not in neighborHexTiles and body != self:
		neighborHexTiles.append(body)

func _on_neighbor_tracker_body_exited(body):
	if body is RigidBody3D and body in neighborHexTiles:
		neighborHexTiles.erase(body)
