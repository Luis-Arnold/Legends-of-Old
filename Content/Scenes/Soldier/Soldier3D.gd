extends CharacterBody3D

var playerColor: PlayerUtil.playerColor
const SPEED = 1.0

var nodesReady: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal comingIntoView

func _ready():
	add_to_group('soldier')
	call_deferred('onNodesReady')
	
	%NavAgent.target_position = position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				velocity.x -= %NavAgent.get_next_path_position().x
				velocity.z -= %NavAgent.get_next_path_position().z
	if event is InputEventKey:
		if self in CameraUtil.selectedSoldiers:
			var cameraSpeed: float = 0.2
			match event.keycode:
				KEY_UP:
					velocity.x -= cameraSpeed
					velocity.z -= cameraSpeed
				KEY_LEFT:
					velocity.x -= cameraSpeed
					velocity.z += cameraSpeed
				KEY_DOWN:
					velocity.x += cameraSpeed
					velocity.z += cameraSpeed
				KEY_RIGHT:
					velocity.x += cameraSpeed
					velocity.z -= cameraSpeed

func _physics_process(delta):
	if nodesReady:
		if %NavAgent.distance_to_target() > %NavAgent.target_desired_distance:
			var nextPosition = %NavAgent.get_next_path_position()
			velocity = (nextPosition - position).normalized() * SPEED
			move_and_slide()

func select():
	pass

func deselect():
	pass

func getScreenPosition(camera: Camera3D) -> Vector2:
	return camera.unproject_position(position * camera.size)

func highlight():
	var tween = create_tween()
	tween.tween_property(%Body.mesh.material, 'albedo_color', Color.PALE_GREEN, 0.2)

func unhighlight():
	var tween = create_tween()
	tween.tween_property(%Body.mesh.material, 'albedo_color', Color.WHITE, 0.2)

func onNodesReady():
	%Body.mesh = CapsuleMesh.new()
	%Body.mesh.material = StandardMaterial3D.new()
	%Body.mesh.material.albedo_color = Color.WHITE
	nodesReady = true

func setTargetPosition(targetPosition):
	%NavAgent.target_position = targetPosition

func _on_nav_agent_target_reached():
	pass
