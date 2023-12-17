extends Camera2D

@export_category('Movement')
var draggingRight = false
var releasedRight = false
var dragRightStartPosition = Vector2()
var dragOffset = Vector2()

@export_category('Input')
var dragThreshold = 40
var startTimeMouseLeft: float = 0.0
var startTimeMouseRight: float = 0.0

@export_category('Zoom')
var zoomSpeed = 0.1
var minZoom = 0.5
var maxZoom = 2.0

@export_category('Selector')
var draggingLeft = false
var releasedLeft = false
@onready var selector: ColorRect = $Selector
var dragLeftStartPosition: Vector2
var dragLeftEndPosition: Vector2

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				releasedLeft = false
				draggingLeft = false
#				var givenTile: TileData = MapUtil.getTileAtWorldPosition(get_global_mouse_position())
			else: # Mouse released
				if draggingLeft and not releasedLeft: # Released after drag
					dragLeftEndPosition = get_global_mouse_position() - position
					selectorCapturing()
				else: # Released after click
					pass
				releasedLeft = true
				
				%Selector.visible = false
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				releasedRight = false
				draggingRight = false
			else: # Mouse released
				if draggingRight and not releasedRight: # Released after drag
					print("rad")
				else: # Released after click
					if CameraUtil.globalSelected:
						
						print('Apply formation')
					for soldier in CameraUtil.selectedSoldiers:
						soldier.scale = Vector2(1,1)
					CameraUtil.selectedSoldiers.clear()
					UnitUtil.selectedUnits.clear()
					CameraUtil.globalSelected = false
					#print("rac")
				releasedRight = true
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2(zoom.x - zoomSpeed, zoom.y - zoomSpeed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2(zoom.x + zoomSpeed, zoom.y + zoomSpeed)
		zoom.x = clamp(zoom.x, minZoom, maxZoom)
		zoom.y = clamp(zoom.y, minZoom, maxZoom)
	
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if (get_global_mouse_position() - position).distance_to(dragLeftStartPosition) > dragThreshold:
				if releasedLeft: # click
					pass
					#print('Click')
				else: # During drag
					if not draggingLeft:
						draggingLeft = true
						dragLeftStartPosition = get_global_mouse_position() - position
						%Selector.visible = true
						%Selector.position = dragLeftStartPosition
						#print("Drag started")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if (get_global_mouse_position() - position).distance_to(dragRightStartPosition) > dragThreshold:
				if CameraUtil.globalSelected:# Drag formation
					# during formation
					for unit in UnitUtil.selectedUnits:
						unit.soldierAssignments = UnitUtil.getFormationPositions(unit.leader, unit.soldiers, unit.relativeFormationPositions, get_global_mouse_position())
						unit.setAbsoluteFormationPositions(unit.relativeFormationPositions, get_global_mouse_position())
						for soldier in unit.soldierAssignments.keys():
							soldier.formationPosition = unit.soldierAssignments[soldier]
						unit.leader.formationPosition = unit.soldierAssignments[unit.leader]
						unit.queue_redraw()
					print('Dragging formation')
					pass
				else:
					if not draggingRight:
						draggingRight = true
						dragRightStartPosition = get_global_mouse_position()
						print("Drag started")
					dragOffset = get_global_mouse_position() - dragRightStartPosition
					position -= dragOffset * 2.4
					dragRightStartPosition += dragOffset
					dragOffset = Vector2.ZERO
					

func _physics_process(_delta):
	queue_redraw()
	if draggingLeft:
		if get_global_mouse_position().x - position.x < dragLeftStartPosition.x:
			%Selector.scale.x = -1
		else:
			%Selector.scale.x = 1
		if get_global_mouse_position().y - position.y < dragLeftStartPosition.y:
			%Selector.scale.y = -1
		else:
			%Selector.scale.y = 1
		
		%Selector.size = (get_global_mouse_position() - dragLeftStartPosition - position) * %Selector.scale
	
#	if draggingRight:
#		dragOffset = get_global_mouse_position() - dragStartPosition
#		position -= dragOffset * 2.4
#		dragStartPosition += dragOffset
#		dragOffset = Vector2.ZERO

func _draw():
	if len(MapUtil.gTiles) > 0:
		for tile in MapUtil.gTiles:
			draw_circle(tile - position, 16, Color.RED)

func _process(delta):
	queue_redraw()

func getSoldier(body: CharacterBody2D):
	CameraUtil.selectedSoldiers.append(body)
	body.scale = Vector2(10, 10)

func selectorCapturing():
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = RectangleShape2D.new()
	shape.size = %Selector.size
	query.set_shape(shape)
	query.transform = Transform2D(0, ((dragLeftEndPosition + dragLeftStartPosition) / 2) + position)
	var selected = space.intersect_shape(query)
	CameraUtil.globalSelected = selected.filter(func(o): return o is Soldier).size() < 1
	for dict in selected:
		if dict['collider'] is CharacterBody2D:
			var soldier: Soldier = dict['collider']
			soldier.emit_signal('soldierSelected')
			if soldier not in CameraUtil.selectedSoldiers:
				CameraUtil.selectedSoldiers.append(soldier)
			if soldier.currentUnit not in UnitUtil.selectedUnits:
				UnitUtil.selectedUnits.append(soldier.currentUnit)
			soldier.scale = Vector2(1.2, 1.2)
