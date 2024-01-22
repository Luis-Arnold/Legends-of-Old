class_name Soldier3D extends CharacterBody3D

@export_category('Core')
var soldierClass: UnitUtil.soldierType = UnitUtil.soldierType.SPEARMAN
var playerColor: PlayerUtil.playerColor = PlayerUtil.playerColor.WHITE
var moral: int = 100
# Experience when killing
var experience: int = 0
# Walking slower and attacking slower
var exhaustion: int
# Can attack when running into enemies
var charge: bool = false

@export_category('Movement')
var currentSpeed: float = 0.5
var targetPosition: Vector3
var formationPosition: Vector2 # Relative position in the formation
var stamina: int = 100
var currentMovementState: movementState = movementState.settled
var settleCooldown: = 0
var direction: float

signal isMoving
signal isHalting
signal isSettled

signal changedTargetPosition

enum movementState {
	moving,
	halting,
	settled, # Can't attack for a while after having walked
	shocked # Has been attacked with a lot of force
}

@export_category('Combat')
var attackReady: bool = false
# Grows with experience
var attackSpeed: float = 1.0
var attackCooldown: float
var attackDamage: int = 50
var waysOfAttack
# Grows with experience
var accuracy: float

var melee: bool = false
var ranged: bool = false
var firingRange: int = 0

var targetsInRange: Array = []
signal takingDamage
var isDying: bool = false
signal dying

@export_category('Selection')
signal selected
signal deselected

var currentUnit: Unit3D

var currentTile: TileData
signal tileChanged

@export_category('Helper variables')
var nodesReady: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal comingIntoView

func _ready():
	add_to_group('soldier')
	call_deferred('onNodesReady')

func _initialize():
	pass

func _physics_process(_delta):
	if not isDying:
		chargeAttack()

func select():
	if currentUnit not in UnitUtil.selectedUnits:
		currentUnit.select()
	emit_signal('selected')

func deselect():
	if currentUnit in UnitUtil.selectedUnits:
		currentUnit.deselect()
	emit_signal('deselected')

# Fix looking at enemies
func lookAtTarget(_targetPosition: Vector3):
	pass
#	var angle = atan2(_targetPosition.y - position.y, _targetPosition.x - position.x)
#	angle = angle - PI
#	%DirectionIndicator.changeDirection(angle)
#	var _direction = targetPosition.direction_to(position).z
	
	
#	if playerColor == PlayerUtil.playerColor.WHITE:
#		print("WHITE: " + str(targetPosition.direction_to(position).z))
#	else:
#		print("BLACK: " + str(targetPosition.direction_to(position).z))
#	_direction = _direction + deg_to_rad(90)
#	%DirectionIndicator.rotation.z = abs(_direction)

func getScreenPosition(camera: Camera3D) -> Vector2:
	return camera.unproject_position(position * camera.size)

func chargeAttack():
	match currentMovementState:
		movementState.settled:
			if not attackReady:
				if attackCooldown >= 0 and attackCooldown < 100:
					attackCooldown += attackSpeed
				elif attackCooldown >= 100:
					attackReady = true
				else:
					attackCooldown = 0
			else:
				if len(targetsInRange) > 0:
					attackCooldown = 0
					attackReady = false
					%AttackAnimation.frame = 0
					if not ranged:
						%AttackAnimation.play('default')
					else:
						%AttackAnimation.play('towerAttack')
					# Make better judgement on target to hit
					targetsInRange[0].emit_signal('takingDamage', attackDamage, UnitUtil.damageType.BASE)
		_:
			pass

func onNodesReady():
	nodesReady = true
	setTargetPosition(position)
	%Body.changeColor(playerColor)

func setTargetPosition(newTargetPosition):
	targetPosition = newTargetPosition
	emit_signal('changedTargetPosition')

func _onNavTargetReached():
	pass

func rotateSoldier(_rotation: float):
	%DirectionIndicator.changeDirection(_rotation)

func changeColor(newColor: PlayerUtil.playerColor):
	playerColor = newColor
	match newColor:
		PlayerUtil.playerColor.WHITE:
			set_collision_layer_value(2, true)
			set_collision_mask_value(3, true)
			%MeleeAttackArea.set_collision_mask_value(3, true)
			%RangedAttackArea.set_collision_mask_value(3, true)
		PlayerUtil.playerColor.BLACK:
			set_collision_layer_value(3, true)
			set_collision_mask_value(2, true)
			%MeleeAttackArea.set_collision_mask_value(2, true)
			%RangedAttackArea.set_collision_mask_value(2, true)

func _onAttackEntered(body):
	if body is CharacterBody3D and body.playerColor != playerColor:
		targetsInRange.append(body)
	elif body is RigidBody3D and body.isDefended and body.playerColor != playerColor:
		targetsInRange.append(body)

func _onAttackExited(body):
	if body is CharacterBody3D:
		if body.playerColor != playerColor:
			targetsInRange.erase(body)
	elif body is RigidBody3D and body.isDefended:
		targetsInRange.erase(body)

func _on_nav_agent_velocity_computed(safeVelocity):
	velocity = velocity.move_toward(safeVelocity, .25)
	move_and_slide()

func setRanged():
	%RangedAttackArea.monitoring = true
	%RangedAttackArea.connect("body_entered", Callable(self, '_onAttackEntered'))
	%RangedAttackArea.connect("body_exited", Callable(self, '_onAttackExited'))
	%MeleeAttackArea.monitoring = false
	%MeleeAttackArea.visible = false

func setMelee():
	%RangedAttackArea.monitoring = false
	%RangedAttackArea.visible = false
	%MeleeAttackArea.monitoring = true
	%MeleeAttackArea.connect("body_entered", Callable(self, '_onAttackEntered'))
	%MeleeAttackArea.connect("body_exited", Callable(self, '_onAttackExited'))
