extends Node2D

const unitScene = preload('res://Content/Scenes/Unit/Unit.tscn')

var whiteUnits: Array = []
var blackUnits: Array = []

func _ready():
	MapUtil.mapGrid = %MapGrid
	
	MapUtil.mapTileDictionaries = MapUtil.getMapTileDictionaries()
	
	var whiteUnit = unitScene.instantiate().duplicate()
	add_child(whiteUnit)
	whiteUnit.changeColor(PlayerUtil.playerColor.WHITE)
	whiteUnits.append(whiteUnit)
	whiteUnit.leader.setCollisionLayers()
	for soldier in whiteUnit.soldiers:
		soldier.changePosition(soldier.position + Vector2(0, 150))
		soldier.setCollisionLayers()
	
	var blackUnit = unitScene.instantiate().duplicate()
	add_child(blackUnit)
	blackUnit.changeColor(PlayerUtil.playerColor.BLACK)
	blackUnits.append(blackUnit)
	blackUnit.leader.setCollisionLayers()
	for soldier in blackUnit.soldiers:
		soldier.setCollisionLayers()

func _draw():
	pass
