extends Control

var draggingLeft: bool = false
var releasedLeft: bool = false
var dragLeftStartPosition: Vector2 = Vector2()
var dragLeftEndPosition: Vector2 = Vector2()
var draggingRight: bool = false
var releasedRight: bool = false
var dragRightStartPosition: Vector2 = Vector2()
var dragRightEndPosition: Vector2 = Vector2()
const selectionBoxColor: Color = Color(0, 0.2, 1,0.3)
const selectionBoxLineWidth: int = 3
const dragThreshold: int = 10

var formationCenter: Vector3 = Vector3(0, 0, 0)

@export_category('Debug')

func _ready():
	visible = false

func _process(delta):
	if draggingLeft:
		queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					releasedLeft = false
					draggingLeft = false
	#				var givenTile: TileData = MapUtil.getTileAtWorldPosition(get_global_mouse_position())
				else: # Mouse released
					if draggingLeft and not releasedLeft: # Released after drag
						dragLeftEndPosition = get_global_mouse_position()
						for soldier in %Camera3D.getArrayByGroup('soldiersInView'):
							if isPointInRectangle(%Camera3D.unproject_position(soldier.position), dragLeftStartPosition, dragLeftEndPosition) and \
								soldier not in CameraUtil.selectedSoldiers:
								soldier.highlight()
								CameraUtil.selectedSoldiers.append(soldier)
					else: # Released after click
						var soldier = CameraUtil.gameCamera.getObjectUnderMouse(get_global_mouse_position(), 'CharacterBody3D')
						if is_instance_valid(soldier) and \
							soldier.playerColor == PlayerUtil.ownerPlayer.playerColor:
							print('Clicked Character')
					releasedLeft = true
					
					%Selector.visible = false
			MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					releasedRight = false
					draggingRight = false
				else: # Mouse released
					if draggingRight and not releasedRight: # Released after drag
						var selectedSoldiers = CameraUtil.selectedSoldiers
						var selectedTiles = CameraUtil.selectedTiles
						var totalSoldiers = len(selectedSoldiers)
						var totalTiles = len(selectedTiles)
						
						# Calculate the base number of soldiers per tile and the remainder
						var soldiersPerHexTile = totalSoldiers / totalTiles
						var remainder = totalSoldiers % totalTiles
						
						var soldierIndex = 0
						
						# Distribute soldiers across tiles
						for i in range(totalTiles):
							var numSoldiersToAssign = int(soldiersPerHexTile) + int(remainder > 0)
							remainder -= int(remainder > 0)
							
							for j in range(numSoldiersToAssign):
								if soldierIndex < totalSoldiers:
									selectedSoldiers[soldierIndex].setTargetPosition(selectedTiles[i].position)
									soldierIndex += 1
						
						for tile in CameraUtil.selectedTiles:
							tile.unhighlight()
						CameraUtil.selectedTiles.clear()
#						print('End drag')
					else: # Released after click
						for soldier in CameraUtil.selectedSoldiers:
							soldier.unhighlight()
						CameraUtil.selectedSoldiers.clear()
					releasedRight = true
	
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if (get_global_mouse_position()).distance_to(dragLeftStartPosition) > dragThreshold:
				if releasedLeft: # click
					pass
					#print('Click')
				else: # During drag
					if not draggingLeft:
						draggingLeft = true
						dragLeftStartPosition = get_global_mouse_position()
						%Selector.visible = true
						%Selector.position = dragLeftStartPosition
						#print("Drag started")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if (get_global_mouse_position()).distance_to(dragRightStartPosition) > dragThreshold:
				if releasedRight: # click
					pass
					#print('Click')
				else: # During drag
					if not draggingRight:
						draggingRight = true
						dragRightStartPosition = get_global_mouse_position()
						#print("Drag started")
					var tile = CameraUtil.gameCamera.getObjectUnderMouse(get_global_mouse_position(), 'RigidBody3D')
					if is_instance_valid(tile):
						if tile not in CameraUtil.selectedTiles and CameraUtil.selectedTiles < CameraUtil.selectedSoldiers:
							tile.highlight()
							CameraUtil.selectedTiles.append(tile)

func isPointInRectangle(point, rect_point1, rect_point2):
	var min_x = min(rect_point1.x, rect_point2.x)
	var max_x = max(rect_point1.x, rect_point2.x)
	var min_y = min(rect_point1.y, rect_point2.y)
	var max_y = max(rect_point1.y, rect_point2.y)
	
	return (point.x >= min_x and point.x <= max_x) and (point.y >= min_y and point.y <= max_y)

func _draw():
	if draggingLeft:
		if get_global_mouse_position().x < dragLeftStartPosition.x:
			%Selector.scale.x = -1
		else:
			%Selector.scale.x = 1
		if get_global_mouse_position().y < dragLeftStartPosition.y:
			%Selector.scale.y = -1
		else:
			%Selector.scale.y = 1
		
		%Selector.size = (get_global_mouse_position() - dragLeftStartPosition) * %Selector.scale

func getWorldPositionFromScreen(screen_pos):
	var params = PhysicsRayQueryParameters3D.new()
	params.from = %Camera3D.project_ray_origin(screen_pos)
	params.to = params.from + %Camera3D.project_ray_normal(screen_pos) * 1000
	params.collision_mask = 1
	var space_state = %Camera3D.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(params)
	return result.position if result else params.from

