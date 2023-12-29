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

enum movementState {
	moving,
	halting,
	settled, # Can't attack for a while after having walked
	shocked
}

@export_category('Combat')
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

func _physics_process(_delta):
	if nodesReady:
		if %NavAgent.distance_to_target() > %NavAgent.target_desired_distance:
			if currentMovementState != movementState.moving:
				currentMovementState = movementState.moving
				%SettledIndicator.visible = false
			var nextPosition = %NavAgent.get_next_path_position()
			velocity = (nextPosition - position).normalized() * currentSpeed
			move_and_slide()
		elif currentMovementState == movementState.moving:
			currentMovementState = movementState.halting
			%SettledIndicator.visible = true
		if len(targetsInRange) > 0:
			look_at_target(targetsInRange[0].transform.origin)
	chargeAttack()

func select():
	if not currentUnit.isSelected:
		emit_signal('soldierSelected')
		currentUnit.select()

func deselect():
	if currentUnit.isSelected:
		emit_signal('soldierDeselected')
		currentUnit.deselect()

func look_at_target(targetPosition):
	var direction = (targetPosition - transform.origin).normalized()
	var newRotation = Vector3(0, atan2(direction.x, direction.z), 0)
	rotation = newRotation

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
					%AttackAnimations.frame = 0
					%AttackAnimations.play('default')
					# Make better judgement on target to hit
					targetsInRange[0].takeDamage(attackDamage, UnitUtil.damageType.BASE)
		movementState.halting:
			if not %SettledIndicator.visible:
				%SettledIndicator.visible = true
			if settleCooldown >= 0 and settleCooldown < 100:
				%SettledIndicator.mesh.material.albedo_color = Color(0.275, 0.529, 1, settleCooldown / 100.0)
				settleCooldown += 1
			elif settleCooldown >= 100:
				currentMovementState = movementState.settled
				settleCooldown = 0
			else:
				settleCooldown = 0
		_:
			pass

func takeDamage(damageTaken: int, damageType: UnitUtil.damageType):
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
		currentUnit.onSoldierDied(self)
		emit_signal('soldierDied')

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
	%NavAgent.target_position = position
	nodesReady = true

func setTargetPosition(targetPosition):
	%NavAgent.target_position = targetPosition

func _onNavTargetReached():
	pass

func rotateSoldier(_rotation: float):
	%DirectionIndicator.rotation.z = _rotation

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
			%AttackArea.set_collision_mask_value(3, true)
		PlayerUtil.playerColor.BLACK:
			set_collision_layer_value(3, true)
			set_collision_mask_value(2, true)
			%AttackArea.set_collision_mask_value(2, true)

func _onAttackEntered(body):
	if body is CharacterBody3D:
		if body.playerColor != playerColor:
			targetsInRange.append(body)

func _onAttackExited(body):
	if body is CharacterBody3D:
		if body.playerColor != playerColor:
			targetsInRange.erase(body)
