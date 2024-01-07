extends Node

var isPlacingBuilding: bool = false
var isMouseOverButton: bool = false
var buildingButtonSelected: HexTile = null
var buildingSelected: HexTile = null
var isBuildingSelected: bool = false

var soldierScene: PackedScene = preload('res://Content/Scenes/Soldier/Soldier3D.tscn')
var unitScene: PackedScene = preload("res://Content/Scenes/Unit/Unit3D.tscn")

func setPlacingBuilding(_building: HexTile) -> void:
	buildingButtonSelected = _building
	isPlacingBuilding = true

func mouseEnteredButton():
	isMouseOverButton = true

func mouseExitedButton():
	isMouseOverButton = false

func selectBuilding(_buildingSelected: HexTile):
	buildingSelected = _buildingSelected

func recruit(_unitScene: PackedScene = unitScene, _soldierScene: PackedScene = soldierScene):
	var newUnit: Unit3D = _unitScene.instantiate().duplicate()
	CameraUtil.currentMap.add_child(newUnit)
	newUnit.initializeSoldiers(10, _soldierScene)
	for soldier in newUnit.soldiers:
		soldier.position = buildingSelected.position
		soldier.get_node('NavAgent').target_position = buildingSelected.position
		soldier.add_to_group('soldiersInView')
		soldier.changeColor(buildingSelected.playerColor)
	
	UnitUtil.distributeSoldiersAcrossTiles([newUnit], [buildingSelected])
