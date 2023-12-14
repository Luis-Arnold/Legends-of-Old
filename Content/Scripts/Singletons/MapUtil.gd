extends Node

var mapGrid: TileMap

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

var gTiles = []

func getTileAtWorldPosition(worldPosition: Vector2):
	var localPosition = mapGrid.to_local(worldPosition)
	var mapPosition = mapGrid.local_to_map(localPosition)
	return mapGrid.get_cell_tile_data(0, mapPosition)

func getTileTerrainAtPosition(worldPosition: Vector2) -> terrainType:
	var tile = getTileAtWorldPosition(worldPosition)
	return matchTerrain(tile.terrain_set, tile.terrain)

func matchTerrain(setID, terrainID) -> terrainType:
	match setID:
		0:
			if terrainID == 0:
				return terrainType.SAND
			else:
				return terrainType.NONE
		_:
			return terrainType.NONE

func getTilePositions() -> Array:
	return mapGrid.get_used_cells(0)
