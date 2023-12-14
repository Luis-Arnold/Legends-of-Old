extends Camera2D

@export_category('Movement')
var draggingRight = false
var releasedRight = false
var dragStartPosition = Vector2()
var dragOffset = Vector2()

@export_category('Input')
var clickDurationThreshold = 0.18
var dragThreshold = 10
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
var startPos: Vector2
var endPos: Vector2

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				draggingLeft = false
				startTimeMouseLeft = Time.get_ticks_msec() / 1000.0
				startPos = get_global_mouse_position() - position
				%Selector.visible = true
				%Selector.position = startPos
#				var givenTile: TileData = MapUtil.getTileAtWorldPosition(get_global_mouse_position())
			else: # Mouse released
				releasedLeft = true
				%Selector.visible = false
				endPos = get_global_mouse_position() - position
				
				var endTime = Time.get_ticks_msec() / 1000.0
				if draggingLeft:
					selectorCapturing()
				elif endTime - startTimeMouseLeft < clickDurationThreshold:
					CameraUtil.selectedSoldiers = []
					for soldier in CameraUtil.selectedSoldiers:
						soldier.scale = Vector2(1,1)
					print('Click detected')
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				releasedRight = false
				draggingRight = false
				startTimeMouseRight = Time.get_ticks_msec() / 1000.0
			else: # Mouse released
				if draggingRight and not releasedRight:
					pass
				else:
					pass
				releasedRight = true
				var endTime = Time.get_ticks_msec() / 1000.0
				if draggingRight:
					dragStartPosition = get_global_mouse_position()
				elif endTime - startTimeMouseRight < clickDurationThreshold:
					print("Click right")
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2(zoom.x - zoomSpeed, zoom.y - zoomSpeed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2(zoom.x + zoomSpeed, zoom.y + zoomSpeed)
		zoom.x = clamp(zoom.x, minZoom, maxZoom)
		zoom.y = clamp(zoom.y, minZoom, maxZoom)
	
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if (get_global_mouse_position() - position).distance_to(startPos) > dragThreshold:
				if releasedLeft: # back to dragging
					pass
				else: # During drag
					if not draggingLeft:
						draggingLeft = true
						print("Drag started")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if (get_global_mouse_position() - position).distance_to(startPos) > dragThreshold:
				if releasedRight: # back to dragging
					pass
				else: # During drag
					if not draggingRight:
						draggingRight = true
						print("Drag started")
					dragOffset = get_global_mouse_position() - dragStartPosition
					position -= dragOffset * 2.4
					dragStartPosition += dragOffset
					dragOffset = Vector2.ZERO

func _physics_process(_delta):
	queue_redraw()
	if draggingLeft:
		if get_global_mouse_position().x - position.x < startPos.x:
			%Selector.scale.x = -1
		else:
			%Selector.scale.x = 1
		if get_global_mouse_position().y - position.y < startPos.y:
			%Selector.scale.y = -1
		else:
			%Selector.scale.y = 1
		
		%Selector.size = (get_global_mouse_position() - startPos - position) * %Selector.scale
	
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
	query.transform = Transform2D(0, ((endPos + startPos) / 2) + position)
	var selected = space.intersect_shape(query)
	for dict in selected:
		if dict['collider'] is CharacterBody2D:
			CameraUtil.selectedSoldiers.append(dict['collider'])
			dict['collider'].scale = Vector2(1.5, 1.5)
