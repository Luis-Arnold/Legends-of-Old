extends Area3D

@export var neighborHexTiles: Array = []

func _ready():
	connect('body_entered', Callable(self, 'onBodyEntered'))
	connect('body_exited', Callable(self, 'onBodyExited'))

func getNeighbor(_direction: Vector2i) -> HexTile:
	return

func onBodyEntered(body):
	if body is RigidBody3D and body not in neighborHexTiles and body != self:
		neighborHexTiles.append(body)

func onBodyExited(body):
	if body is RigidBody3D and body in neighborHexTiles:
		neighborHexTiles.erase(body)
