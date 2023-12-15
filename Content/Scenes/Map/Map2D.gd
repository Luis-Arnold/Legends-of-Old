extends Node2D

func _ready():
	MapUtil.mapGrid = %MapGrid
	
	# Get grid positions & modify special grids
	MapUtil.mapTileDictionaries = MapUtil.getMapTileDictionaries()

func _draw():
	pass
