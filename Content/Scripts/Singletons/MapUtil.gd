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

var gTiles = []

func getMapTileDictionaries():
	var tileDictionaries: Array = []
	for tilePosition in getTilePositions():
		var dict: Dictionary = {}
		dict['tile'] = mapGrid.get_cell_tile_data(0, tilePosition)
		dict['tilePosition'] = mapGrid.map_to_local(tilePosition)
		tileDictionaries.append(dict)
	return tileDictionaries

func getTileAtWorldPosition(worldPosition: Vector2) -> TileData:
	var localPosition = mapGrid.to_local(worldPosition)
	var mapPosition = mapGrid.local_to_map(localPosition)
	return mapGrid.get_cell_tile_data(0, mapPosition)

func getTileTerrainAtPosition(worldPosition: Vector2) -> terrainType:
	var tile = getTileAtWorldPosition(worldPosition)
	return matchTerrain(tile.terrain_set, tile.terrain)

func getTileTerrainStringAtPosition(worldPosition: Vector2) -> String:
	var tile = getTileAtWorldPosition(worldPosition)
	return terrainToString(matchTerrain(tile.terrain_set, tile.terrain))

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

func getTiles() -> Array:
	var tiles: Array = []
	for tilePosition in getTilePositions():
		tiles.append(mapGrid.get_cell_tile_data(0, tilePosition))
	return tiles

func getTilePositions() -> Array:
	return mapGrid.get_used_cells(0)

func getTileTilePositions() -> Array:
	var positions: Array = []
	for tilePosition in getTilePositions():
		positions.append(mapGrid.map_to_local(tilePosition))
	return positions

func pieceEntered(body: Node2D, soldier: Soldier):
	if body is TileMap:
		soldier.currentTile = getTileAtWorldPosition(soldier.position)
		soldier.emit_signal('tileChanged')
