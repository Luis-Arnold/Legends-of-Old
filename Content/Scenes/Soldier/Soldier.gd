class_name Soldier extends CharacterBody2D

var isLeader: bool

@export_category('Movement')
var currentSpeed: int = 100
var destination: Vector2 = Vector2()
var formationPosition: Vector2 # Relative position in the formation

@export_category('Selection')
var selected: bool = false

var currentUnit: Unit

var currentTile: TileData
signal tileChanged

func _ready():
	destination = position
	
	connect('tileChanged', Callable(self, 'onTileChanged'))
	%Area.connect('body_entered', Callable(MapUtil, 'pieceEntered').bind(self))

func _input(event):
	if InputUtil.isLeftMousePressed(event):
		if self in CameraUtil.selectedSoldiers:
			destination = get_global_mouse_position()

func _physics_process(delta):
	moveTowardsTarget(delta)
	
	#print(MapUtil.getTileTerrainAtPosition(global_position))

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
	print(currentTerrain)
	if currentTerrain == 'Sand':
		currentSpeed = 80
	else:
		currentSpeed = 160

func onFormationChanged():
	pass

func onDestinationChanged():
	pass
