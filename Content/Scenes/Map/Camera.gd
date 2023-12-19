extends Camera3D

@export_category('Zoom')
var zoomSpeed = 0.4
var minZoom = 0.5
var maxZoom = 10.0

func _ready():
	CameraUtil.gameCamera = self

func _process(delta):
	pass

func _input(event):
	if event is InputEventKey:
		var cameraSpeed: float = 0.4
		match event.keycode:
			KEY_W:#, KEY_UP:
				position.x -= cameraSpeed
				position.z -= cameraSpeed
			KEY_A:#, KEY_LEFT:
				position.x -= cameraSpeed
				position.z += cameraSpeed
			KEY_S:#, KEY_DOWN:
				position.x += cameraSpeed
				position.z += cameraSpeed
			KEY_D:#, KEY_RIGHT:
				position.x += cameraSpeed
				position.z -= cameraSpeed
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			size = size + zoomSpeed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			size = size - zoomSpeed
		size = clamp(size, minZoom, maxZoom)
	
	if event is InputEventMouseMotion:
		pass

func rayCastMousePosition(mousePosition: Vector2, rayLength, collisionMask: int):
	var rayStart = project_ray_origin(mousePosition)
	var rayEnd = rayStart + project_ray_normal(mousePosition) * rayLength
	var spaceState = get_world_3d().direct_space_state
	var rayParams = PhysicsRayQueryParameters3D.new()
	rayParams.from = rayStart
	rayParams.to = rayEnd
	rayParams.collision_mask = collisionMask
	return spaceState.intersect_ray(rayParams)

func getUnitUnderMouse(mousePosition: Vector2):
	var result = rayCastMousePosition(mousePosition, 1000, 0)
	if result and result.collider is CharacterBody3D and result.collider.playerColor == PlayerUtil.ownerPlayer.playerColor:
		pass
