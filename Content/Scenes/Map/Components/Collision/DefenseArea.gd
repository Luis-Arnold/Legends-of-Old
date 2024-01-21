extends Area3D

@export var entity: Node3D

func _ready():
	%DefenseCollision.shape = %DefenseCollision.shape.duplicate()
	
	var parent = get_parent_node_3d()
	if parent is Node3D:
		entity = parent

func _onAttackerEntered(body):
	if body is CharacterBody3D:
		if body.playerColor != PlayerUtil.ownerPlayer.playerColor:
			entity.targetsInRange.append(body)

func _onAttackerExited(body):
	if body is CharacterBody3D:
		if body.playerColor != PlayerUtil.ownerPlayer.playerColor:
			entity.targetsInRange.erase(body)

