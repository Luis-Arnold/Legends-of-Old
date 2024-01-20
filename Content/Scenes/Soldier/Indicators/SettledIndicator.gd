class_name SettledIndicator extends MeshInstance3D

@export var soldier: CharacterBody3D
@export var settled: bool = false
@export var settleCooldown: int

func _ready():
	visible = false
	settleCooldown = 0
	mesh = mesh.duplicate(true)
	
	var parent = get_parent_node_3d()
	if parent is CharacterBody3D:
		soldier = parent
		soldier.connect('isMoving', Callable(self, 'onMoving'))
		soldier.connect('isHalting', Callable(self, 'onHalting'))

func onMoving():
	settled = false
	visible = false

func onHalting():
	visible = true

func _physics_process(_delta):
	if visible and not settled:
		if settleCooldown >= 0 and settleCooldown < 100:
			mesh.material.albedo_color = Color(0.275, 0.529, 1, settleCooldown / 100.0)
			settleCooldown += 1
		elif settleCooldown >= 100:
			soldier.currentMovementState = soldier.movementState.settled
			settled = true
			settleCooldown = 0
		else:
			settleCooldown = 0
