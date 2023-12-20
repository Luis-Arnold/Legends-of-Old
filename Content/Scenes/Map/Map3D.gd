extends Node3D

var grassScene = preload("res://Content/Scenes/Map/Terrain/Grass3D.tscn")
var castleScene = preload("res://Content/Scenes/Map/Buildings/Castle3D.tscn")
const hexSpacing = 0.6
const SQRT3 = sqrt(3)

var tiles = []

func _ready():
	var positions = getHexGridPositions(5, 5)
	
	for i in range(len(positions)):
		var tile
		if i % 2 == 1:
			tile = grassScene.instantiate().duplicate()
		else:
			tile = grassScene.instantiate().duplicate()
		add_child(tile)
		tile.position = positions[i]
		tiles.append(tile)
	
	rotateTiles()

func rotateTiles():
	for tile in tiles:
		tile.rotation = Vector3(0.0,deg_to_rad(90.0),0)

func getHexGridPositions(gridWidth, gridHeight):
	var positions = []
	for x in range(gridWidth):
		for y in range(gridHeight):
			var xOffset = x * hexSpacing * 3.0 / 2.0
			var yOffset = y * hexSpacing * SQRT3
			if x % 2 == 1:
				yOffset += hexSpacing * SQRT3 / 2
			positions.append(Vector3(xOffset, 0, yOffset))
	return positions
