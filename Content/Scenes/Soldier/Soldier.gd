class_name Soldier extends CharacterBody2D

var isLeader: bool
var playerColor: PlayerUtil.playerColor = PlayerUtil.playerColor.WHITE

@export_category('Movement')
var currentSpeed: int = 100
var destination: Vector2 = Vector2()
var formationPosition: Vector2 # Relative position in the formation
var stamina: int = 100
var direction

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
	%CollisionSelector.connect('body_entered', Callable(MapUtil, 'pieceEntered').bind(self))
	
	if playerColor == PlayerUtil.ownerPlayer.playerColor:
		add_to_group("friendlies")
		set_collision_layer_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)
		set_collision_mask_value(12, true)
	else:
		add_to_group("enemies")
		set_collision_layer_value(12, true)
		set_collision_mask_value(PlayerUtil.ownerPlayer.playerCollisionLayer, true)
		

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
	var direction = (destination - position).normalized()
	if position.distance_to(destination) > 8:  # Add a small threshold to prevent jittering
		velocity = direction * currentSpeed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		position = destination  # Snap to target position

func getTileBelow():
	pass

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
