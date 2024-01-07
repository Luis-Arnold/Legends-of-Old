extends Camera3D

@export_category('Zoom')
var zoomSpeed = 0.4
var minZoom = 0.5
var maxZoom = 10.0

func _ready():
	CameraUtil.gameCamera = self

func _process(_delta):
	pass

func _input(event):
	if %Selector.selectDirection:
		pass
	else:
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
#				KEY_Q:
#					rotation.y += cameraSpeed
#				KEY_E:
#					rotation.y -= cameraSpeed
		
		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					pass
				MOUSE_BUTTON_WHEEL_DOWN:
					size = size + zoomSpeed
				MOUSE_BUTTON_WHEEL_UP:
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

func getObjectUnderMouse(mousePosition: Vector2, objectType):
	var result = rayCastMousePosition(mousePosition, 1000, 1)
	if result.size() > 0 and \
		result['collider'].get_class() == objectType:
		return result['collider']

func getCollidingObjectsInBox(boxShape: BoxShape3D, boxTransform: Transform3D, collisionMask: int = 1):
	var spaceState = get_world_3d().direct_space_state
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape = boxShape
	params.transform = boxTransform
	params.collision_mask = collisionMask
	var _results = spaceState.intersect_shape(params)

func getCameraDirection():
	return -global_transform.basis.z.normalized()

func _on_area_3d_body_entered(body):
	match body.get_class():
		'CharacterBody3D':
			body.visible = true
			body.add_to_group('soldiersInView')
#			print('Soldiers in view: ', len(getArrayByGroup('soldiersInView')))
		'RigidBody3D':
			body.visible = true
			body.add_to_group('tilesInView')
			getArrayByGroup('tilesInView')
#			print('Tiles in view: ', len(getArrayByGroup('tilesInView')))

func _on_area_3d_body_exited(body):
	match body.get_class():
		'CharacterBody3D':
			if body.is_in_group('soldiersInView'):
				body.remove_from_group('soldiersInView')
				body.visible = false
#				print('Soldiers in view: ', len(getArrayByGroup('soldiersInView')))
		'RigidBody3D':
			body.remove_from_group('tilesInView')
			body.visible = false
#			print('Tiles in view: ', len(getArrayByGroup('tilesInView')))

func getArrayByGroup(groupName):
	return get_tree().get_nodes_in_group(groupName)
