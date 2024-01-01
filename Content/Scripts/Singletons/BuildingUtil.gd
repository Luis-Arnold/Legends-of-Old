extends Node

var isPlacingBuilding: bool = false
var buildingSelected: HexTile = null
var isMouseOverButton: bool = false

func setPlacingBuilding(building: HexTile) -> void:
	buildingSelected = building
	isPlacingBuilding = true

func mouseEnteredButton():
	isMouseOverButton = true

func mouseExitedButton():
	isMouseOverButton = false
