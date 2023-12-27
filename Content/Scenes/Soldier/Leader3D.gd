class_name Leader3D extends Soldier3D

func _ready():
	add_to_group('soldier')
	call_deferred('onNodesReady')
	
	%NavAgent.target_position = position
	scale = Vector3(0.2, 0.2, 0.2)
	%Body.mesh.material.albedo_color = Color.RED

func rotateSoldier(rotation: float):
	%DirectionIndicator.rotation.z = rotation
	%FlagNode.rotation.y = abs(rotation)
