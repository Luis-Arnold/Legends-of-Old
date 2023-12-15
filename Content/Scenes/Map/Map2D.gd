extends Node2D

var tileOffset: Vector2 = Vector2(0, 4) # Tiles were a little janky

func _ready():
	MapUtil.mapGrid = %MapGrid
	
	# Get grid positions & modify special grids
#	MapUtil.mapTileDictionaries = MapUtil.getMapTileDictionaries()
	
	# TODO Add area2d or similar to the tiles and store them in the dictionary
#	for tile in MapUtil.mapTileDictionaries:
#		var area: Area2D = Area2D.new()
#		area.connect('body_entered', Callable(MapUtil, 'pieceEntered'))
#		var collision: CollisionPolygon2D = CollisionPolygon2D.new()
#		var collisionPointArray: Array = [
#			Vector2(-63.28,-34),
#			Vector2(0.3,-66.59),
#			Vector2(64.39,-34.695),
#			Vector2(64.405,30),
#			Vector2(0,61.16),
#			Vector2(-63.29,30)
#		]
#		collisionPointArray = collisionPointArray.map(func(v: Vector2): return v + tile['tilePosition'] + tileOffset)
#		var collisionPoints: PackedVector2Array = PackedVector2Array(collisionPointArray)
#		collision.polygon = collisionPoints
#		collision.scale = Vector2(0.8, 0.8)
#		collision.position = tile['tilePosition']
#		tile['area'] = area
#		tile['collision'] = collision
#		area.add_child(collision)
#		%MapGrid.add_child(area)
		
		
	
	%MapGrid.modulate = Color(1,1,1,0.5)

func _draw():
	if len(MapUtil.mapTileDictionaries) > 0:
		for tile in MapUtil.mapTileDictionaries:
			draw_colored_polygon(tile['collision'].polygon, Color.BLUE)
			if MapUtil.terrainToString(MapUtil.matchTerrain(tile['tile'].terrain_set, tile['tile'].terrain)) == 'Sand':
				draw_circle(tile['tilePosition'], 20, Color.GREEN)
			else:
				draw_circle(tile['tilePosition'], 20, Color.RED)
			
