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
var destination: Vector2 = Vector2()
var formationPosition: Vector2 # Relative position in the formation
var stamina: int = 100
var currentMovementState: movementState = movementState.settled
var settleCooldown: = 0
var direction: float

signal isMoving
signal isHalting
signal isSettled

enum movementState {
	moving,
	halting,
	settled, # Can't attack for a while after having walked
	shocked # Has been attacked with a lot of force
}

@export_category('Combat')
var isDying: bool = false
var health: int = 100
var armor: int
var attackReady: bool = false
# Grows with experience
var attackSpeed: float = 1.0
var attackCooldown: float
var attackDamage: int = 50
var waysOfAttack
# Grows with experience
var accuracy: float
# What you are resistant or not resistant against
var resistanceModifiers: Dictionary = {
	UnitUtil.damageType.BASE: 0.2
}

var melee: bool = false
var ranged: bool = false
var firingRange: int = 0

var targetsInRange: Array = []
signal soldierDamaged
signal soldierDied

@export_category('Selection')
var selected: bool = false
signal soldierSelected
signal soldierDeselected

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
	
	connect('soldierSelected', Callable(self, 'onSelected'))
	connect('soldierDeselected', Callable(self, 'onDeselected'))

func _initialize():
	pass

func _physics_process(_delta):
	if isDying:
		if not %DamageAnimation.is_playing():
			die()
	else:
		if nodesReady:
			if %NavAgent.distance_to_target() > %NavAgent.target_desired_distance:
				if currentMovementState != movementState.moving:
					currentMovementState = movementState.moving
					emit_signal('isMoving')
				var nextPosition = %NavAgent.get_next_path_position()
				var newVelocity = (nextPosition - position).normalized() * currentSpeed
				
				%NavAgent.set_velocity(newVelocity)
				velocity = newVelocity
				move_and_slide()
			elif currentMovementState == movementState.moving:
				currentMovementState = movementState.halting
				emit_signal('isHalting')
#			if len(targetsInRange) > 0:
#				lookAtTarget(targetsInRange[0].transform.origin)
		chargeAttack()

func select():
	if not currentUnit.isSelected:
		emit_signal('soldierSelected')
		currentUnit.select()

func deselect():
	if currentUnit.isSelected:
		emit_signal('soldierDeselected')
		currentUnit.deselect()

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
					targetsInRange[0].takeDamage(attackDamage, UnitUtil.damageType.BASE)
		_:
			pass

func takeDamage(damageTaken: int, damageType: UnitUtil.damageType):
	%DamageAnimation.play('default')
	emit_signal('soldierDamaged')
	# Damage type resistances
	var damageAfterResistance: int = int(damageTaken * (1 - resistanceModifiers[damageType]))
	# Add speed modifier
	
	var damageAfterArmor: int
	if armor > 0:
		damageAfterArmor = damageAfterResistance % armor
	else:
		damageAfterArmor = damageAfterResistance
	
	armor -= damageAfterResistance - damageAfterArmor
	health -= damageAfterArmor
	
	if health < 1:
		isDying = true

func highlight():
	var tween = create_tween()
	tween.tween_property(%Body.mesh.material, 'emission', Color.DIM_GRAY, 0.2)

func unhighlight():
	var tween = create_tween()
	tween.tween_property(%Body.mesh.material, 'emission', Color.BLACK, 0.2)

func onNodesReady():
	%Body.mesh = CapsuleMesh.new()
	%Body.mesh.material = StandardMaterial3D.new()
	%Body.mesh.material.emission_enabled = true
	%Body.mesh.material.emission = Color.BLACK
	%NavAgent.target_position = position
	nodesReady = true
	match playerColor:
		PlayerUtil.playerColor.WHITE:
			%Body.mesh.material.albedo_color = Color.GREEN
		PlayerUtil.playerColor.BLACK:
			%Body.mesh.material.albedo_color = Color.RED
		_:
			%Body.mesh.material.albedo_color = Color.BLUE

func setTargetPosition(targetPosition):
	%NavAgent.target_position = targetPosition

func _onNavTargetReached():
	pass

func rotateSoldier(_rotation: float):
	%DirectionIndicator.changeDirection(_rotation)

func onSelected():
	pass

func onDeselected():
	pass

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

func die():
	currentUnit.onSoldierDied(self)
	emit_signal('soldierDied')

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
