extends CharacterBody3D

var playerColor: PlayerUtil.playerColor
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if event is InputEventKey:
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
	move_and_slide()

func select():
	pass

func deselect():
	pass
