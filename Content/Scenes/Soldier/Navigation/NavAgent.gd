extends NavigationAgent3D

@export var soldier: CharacterBody3D

func _ready():
	var parent = get_parent()
	if parent is CharacterBody3D:
		soldier = parent
		soldier.connect('changedTargetPosition', Callable(self, 'onTargetPositionChanged'))

func _physics_process(_delta):
	if soldier.nodesReady:
		if distance_to_target() > target_desired_distance:
			if soldier.currentMovementState != soldier.movementState.moving:
				soldier.currentMovementState = soldier.movementState.moving
				soldier.emit_signal('isMoving')
			var nextPosition = get_next_path_position()
			var newVelocity = (nextPosition - soldier.position).normalized() * soldier.currentSpeed
			
			set_velocity(newVelocity)
			soldier.velocity = newVelocity
			soldier.move_and_slide()
		elif soldier.currentMovementState == soldier.movementState.moving:
			soldier.currentMovementState = soldier.movementState.halting
			soldier.emit_signal('isHalting')

func onTargetPositionChanged():
	target_position = soldier.targetPosition
