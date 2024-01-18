extends Node

var mapGrid: TileMap
var mapTileDictionaries: Array = []

enum terrainType {
	SAND,
	MARSH,
	SEA,
	LAKE,
	COAST,
	SWAMP,
	RIVER,
	MOUNTAIN,
	HILL,
	NONE
}

func matchTerrain(setID, terrainID) -> terrainType:
	match setID:
		0:
			match terrainID:
				0:
					return terrainType.SAND
				_:
					return terrainType.NONE
		_:
			return terrainType.NONE

func matchTerrainOfTileData(tileData: TileData) -> terrainType:
	if is_instance_valid(tileData):
		return matchTerrain(tileData.terrain_set, tileData.terrain)
	else:
		return terrainType.NONE

func terrainToString(type: terrainType) -> String:
	match type:
		0:
			return 'Sand'
		_:
			return 'None'
