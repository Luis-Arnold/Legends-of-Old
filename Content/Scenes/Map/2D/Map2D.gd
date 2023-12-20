extends Node2D

const unitScene = preload('res://Content/Scenes/Unit/Unit2D/Unit.tscn')

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
	whiteUnit.leader.changePosition(whiteUnit.leader.position + Vector2(0, 400))
	whiteUnit.leader.name = 'White leader'
	whiteUnit.leader.targetsInRange.clear()
	
	var blackUnit = unitScene.instantiate().duplicate()
	add_child(blackUnit)
	blackUnit.changeColor(PlayerUtil.playerColor.BLACK)
	blackUnits.append(blackUnit)
	blackUnit.leader.setCollisionLayers()
	for soldier in blackUnit.soldiers:
		soldier.setCollisionLayers()
	blackUnit.leader.name = 'Black leader'
	blackUnit.leader.targetsInRange.clear()

func _draw():
	pass
