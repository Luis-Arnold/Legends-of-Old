extends Node3D

@export_category('Tiles')
var hexTiles: Dictionary = {}

@export_category('Scenes')
var grassScene: PackedScene = preload("res://Content/Scenes/Map/Terrain/Grass.tscn")
var soldierScene: PackedScene = preload('res://Content/Scenes/Soldier/Soldier3D.tscn')
var archerScene: PackedScene = preload('res://Content/Scenes/Soldier/Archer.tscn')
var spearmanScene: PackedScene = preload('res://Content/Scenes/Soldier/Spearman.tscn')
var unitScene: PackedScene = preload("res://Content/Scenes/Unit/Unit3D.tscn")

@export_category('Helper variables')
const hexSpacing: float = 0.6
const SQRT3: float = sqrt(3)

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
		%SoldierNavigation.add_child(tile)
		tile.position = positions.values()[i]
		hexTiles[positions.keys()[i]] = tile
	
#	%SoldierNavigation.bake_navigation_mesh()
	
	var archerUnit = unitScene.instantiate().duplicate()
	add_child(archerUnit)
	archerUnit.initializeSoldiers(10, archerScene)
	for soldier in archerUnit.soldiers:
		soldier.position += Vector3(0, 0, 2 * 0)
		
	var spearmanUnit = unitScene.instantiate().duplicate()
	add_child(spearmanUnit)
	spearmanUnit.initializeSoldiers(10, spearmanScene)
	for soldier in spearmanUnit.soldiers:
		soldier.position += Vector3(0, 0, 2 * 1)
	
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
