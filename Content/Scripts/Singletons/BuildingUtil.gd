extends Node

var isPlacingBuilding: bool = false
var buildingSelected: HexTile = null

func setPlacingBuilding(building: HexTile) -> void:
	buildingSelected = building
	isPlacingBuilding = true
