extends Node2D

func _ready():
	MapUtil.mapGrid = %MapGrid
	
	# Get grid positions & modify special grids
	MapUtil.mapTileDictionaries = MapUtil.getMapTileDictionaries()
	
	# TODO Add area2d or similar to the tiles and store them in the dictionary
	
	%MapGrid.modulate = Color(1,1,1,0.5)

func _draw():
	if len(MapUtil.mapTileDictionaries) > 0:
		for tile in MapUtil.mapTileDictionaries:
			if MapUtil.terrainToString(MapUtil.matchTerrain(tile['tile'].terrain_set, tile['tile'].terrain)) == 'Sand':
				draw_circle(tile['tilePosition'], 20, Color.GREEN)
			else:
				draw_circle(tile['tilePosition'], 20, Color.RED)
#			if 
