extends Node3D

var grassScene = preload("res://Content/Scenes/Map/Terrain/Grass.tscn")
var soldierScene = preload('res://Content/Scenes/Soldier/Soldier3D.tscn')
const hexSpacing = 0.6
const SQRT3 = sqrt(3)

var hexTiles = {}

func _ready():
	CameraUtil.currentMap = self
	
	var positions = getHexGridPositions(10, 10)
	
	for i in range(len(positions.keys())):
		var tile
		if i % 2 == 1:
			tile = grassScene.instantiate().duplicate()
		else:
			tile = grassScene.instantiate().duplicate()
		tile.get_node('DebugLabel').text = str(positions.keys()[i])
		tile.name = str(positions.keys()[i])
		add_child(tile)
		tile.position = positions.values()[i]
		hexTiles[positions.keys()[i]] = tile
	
	for i in 50:
		var soldier = soldierScene.instantiate().duplicate()
		add_child(soldier)
		soldier.position = Vector3(0.02 * i,0.65, 0.2 * i)
	
	rotateTiles()

func rotateTiles():
	for tile in hexTiles.values():
		tile.rotation = Vector3(0.0,deg_to_rad(90.0),0)

func getHexGridPositions(gridWidth, gridHeight):
	var positions = {}
	for x in range(gridWidth):
		for y in range(gridHeight):
			var xOffset = x * hexSpacing * 3.0 / 2.0
			var yOffset = y * hexSpacing * SQRT3
			if x % 2 == 1:
				yOffset += hexSpacing * SQRT3 / 2
			positions[Vector2i(x, y)] = Vector3(xOffset, 0, yOffset)
	return positions
