class_name Soldier extends CharacterBody2D

@export_category('Movement')
var currentSpeed = 100
var targetPosition = Vector2()

@export_category('Selection')
var selected: bool = false

var currentTile: TileData

func _ready():
	targetPosition = position

func _input(event):
	if InputUtil.isLeftMousePressed(event):
		if self in CameraUtil.selectedSoldiers:
			targetPosition = get_global_mouse_position()

func _physics_process(delta):
	moveTowardsTarget(delta)
	
	#print(MapUtil.getTileTerrainAtPosition(global_position))

func _draw():
	pass

func moveTowardsTarget(delta):
	var direction = (targetPosition - position).normalized()
	if position.distance_to(targetPosition) > 1:  # Add a small threshold to prevent jittering
		velocity = direction * currentSpeed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		position = targetPosition  # Snap to target position

func getTileBelow():
	pass
