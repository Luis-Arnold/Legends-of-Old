class_name Soldier extends CharacterBody2D

@export_category('Core')
var isLeader: bool
var playerColor: PlayerUtil.playerColor = PlayerUtil.playerColor.WHITE
var moral: int
# Experience when killing
var experience: int
# Walking slower and attacking slower
var exhaustion: int

@export_category('Movement')
var currentSpeed: int = 100
var destination: Vector2 = Vector2()
var formationPosition: Vector2 # Relative position in the formation
var stamina: int = 100

@export_category('Combat')
var health: int = 100
var armor: int = 0
var attackReady: bool = false
# Grows with experience
var attackSpeed: float = 1
var attackCooldown: int
var attackDamage: int
var waysOfAttack
# Grows with experience
var accuracy: float
# What you are resistant or not resistant against
var resistanceModifiers: Dictionary
var targetsInRange: Array = []
signal soldierDamaged
signal soldierDied

@export_category('Selection')
var selected: bool = false
signal soldierSelected
signal soldierDeselected

var currentUnit: Unit

var currentTile: TileData
signal tileChanged

@export_category('Debug')
var markings: Array = []

func _ready():
	destination = position
	
	connect('soldierSelected', Callable(self, 'onSoldierSelected'))
	connect('soldierDeselected', Callable(self, 'onSoldierDeselected'))
	connect('tileChanged', Callable(self, 'onTileChanged'))
	# Telling the Selector rectangle that this soldier entered the selection
	%SelectorArea.connect('body_entered', Callable(MapUtil, 'pieceEntered').bind(self))
	%TargetArea.connect('body_entered', Callable(self, 'onEnemyEntered'))
	%TargetArea.connect('body_exited', Callable(self, 'onEnemyExited'))
	
	armor = 50
	resistanceModifiers[UnitUtil.damageType.BASE] = 0.2

func _input(event):
	if InputUtil.isLeftMousePressed(event):
		if self in CameraUtil.selectedSoldiers:
			if formationPosition != null:
				destination = formationPosition
#			destination = get_global_mouse_position()

func _physics_process(delta):
	chargeAttack()
	moveTowardsTarget(delta)
	queue_redraw()

func _draw():
	if len(markings) > 0:
		for marking in markings:
			draw_circle(marking, 15, Color.NAVY_BLUE)

func chargeAttack():
	if not attackReady:
		if attackCooldown >= 0 and attackCooldown < 100:
			attackCooldown += attackSpeed
		elif attackCooldown >= 100:
			print('attack ready')
			attackReady = true
		else:
			attackCooldown = 0
	else:
		if len(targetsInRange) > 0:
			attackCooldown = 0
			attackReady = false
			print('attacked: ' + PlayerUtil.playerColorToString(playerColor))
			# Make better judgement on target to hit
			targetsInRange[0].takeDamage(10, UnitUtil.damageType.BASE)

func moveTowardsTarget(delta):
	var _direction = (destination - position).normalized()
	if position.distance_to(destination) > 8:  # Add a small threshold to prevent jittering
		velocity = _direction * currentSpeed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		position = destination  # Snap to target position

func setCollisionLayers():
	if playerColor == PlayerUtil.playerColor.WHITE:
		add_to_group("friendlies")
		set_collision_layer_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)
		set_collision_mask_value(12, true)
		%TargetArea.set_collision_mask_value(12, true)
		%TargetArea.set_collision_mask_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)
	else:
		add_to_group("enemies")
		set_collision_layer_value(12, true)
		set_collision_mask_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)
		%TargetArea.set_collision_mask_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)
		%TargetArea.set_collision_mask_value(12, true)

func changePosition(newPosition: Vector2):
	position = newPosition
	formationPosition = newPosition
	destination = newPosition

func changeRotation(newRotation: int):
	%RotationIndicator.rotation = newRotation
	%TargetArea.rotation = newRotation

func changeColor(newColor: PlayerUtil.playerColor):
	playerColor = newColor
	match newColor:
		PlayerUtil.playerColor.WHITE:
			%Body.animation = 'green'
		PlayerUtil.playerColor.BLACK:
			%Body.animation = 'red'
		_:
			%Body.animation = 'green'
	if isLeader:
		%Body.frame = 1

func changeType(newType: UnitUtil.unitType):
	pass

func changeUnit(newUnit: Unit):
	disconnect('soldierDamaged', Callable(currentUnit, 'onSoldierDamaged'))
	disconnect('soldierDied', Callable(currentUnit, 'onSoldierDied'))
	currentUnit = newUnit
	connect('soldierDamaged', Callable(newUnit, 'onSoldierDamaged'))
	connect('soldierDied', Callable(newUnit, 'onSoldierDied'))

func takeDamage(damageTaken: int, damageType: UnitUtil.damageType):
	emit_signal('soldierDamaged')
	# Damage type resistances
	var damageAfterResistance: int = int(damageTaken * (1 - resistanceModifiers[damageType]))
	print(velocity)
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
	
	print(damageTaken)

func onTileChanged():
	var currentTerrain = MapUtil.terrainToString(MapUtil.matchTerrainOfTileData(currentTile))
	
	if currentTerrain == 'Sand':
		currentSpeed = 80
	else:
		currentSpeed = 160

func onFormationChanged():
	pass

func onDestinationChanged():
	pass

func onSoldierSelected():
	currentUnit.selectUnit()

func onSoldierDeselected():
	currentUnit.deselectUnit()

func onEnemyEntered(body):
	if body is CharacterBody2D:
		if body.playerColor != playerColor:
			targetsInRange.append(body)

func onEnemyExited(body):
	if body is CharacterBody2D:
		if body.playerColor != playerColor:
			targetsInRange.erase(body)
