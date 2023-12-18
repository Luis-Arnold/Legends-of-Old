class_name Soldier extends CharacterBody2D

var isLeader: bool
var playerColor: PlayerUtil.playerColor = PlayerUtil.playerColor.WHITE

@export_category('Movement')
var currentSpeed: int = 100
var destination: Vector2 = Vector2()
var formationPosition: Vector2 # Relative position in the formation
var stamina: int = 100

@export_category('Combat')
var health: int
var armor: int
var resistance: float
var attackSpeed: float
var attackDamage: int
signal soldierDamaged
signal soldierDied

@export_category('Selection')
var selected: bool = false
signal soldierSelected
signal soldierDeselected

var currentUnit: Unit

var currentTile: TileData
signal tileChanged

func _ready():
	destination = position
	
	connect('soldierSelected', Callable(self, 'onSoldierSelected'))
	connect('soldierDeselected', Callable(self, 'onSoldierDeselected'))
	connect('tileChanged', Callable(self, 'onTileChanged'))
	# Telling the Selector rectangle that this soldier entered the selection
	%SelectorArea.connect('body_entered', Callable(MapUtil, 'pieceEntered').bind(self))
	%TargetArea.connect('body_entered', Callable(self, 'onEnemyEntered'))

func _input(event):
	if InputUtil.isLeftMousePressed(event):
		if self in CameraUtil.selectedSoldiers:
			if formationPosition != null:
				destination = formationPosition
#			destination = get_global_mouse_position()

func _physics_process(delta):
	moveTowardsTarget(delta)

func _draw():
	pass

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
	else:
		add_to_group("enemies")
		set_collision_layer_value(12, true)
		set_collision_mask_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)
		%TargetArea.set_collision_mask_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)

func changePosition(newPosition: Vector2):
	position = newPosition
	formationPosition = newPosition
	destination = newPosition

func changeRotation(newRotation: int):
	%RotationIndicator.rotation = newRotation

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

func takeDamage(damageTaken):
	emit_signal('soldierDamaged')
	# Damage type resistances
	var damageAfterResistance = damageTaken * resistance
	
	health -= damageAfterResistance
	
	if health < 1:
		emit_signal('soldierDied')

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
		print('ownname: ' + name)
		print('incoming name: ' + body.name)
