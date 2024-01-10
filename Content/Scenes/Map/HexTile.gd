class_name HexTile extends RigidBody3D

var arrowScene = preload("res://Content/Scenes/Projectiles/Arrows/Arrow3D.tscn")
var soldierScene: PackedScene = preload('res://Content/Scenes/Soldier/Soldier3D.tscn')
var unitScene: PackedScene = preload("res://Content/Scenes/Unit/Unit3D.tscn")

@export_category('Core')
@export var tileName: String
@export var tileSpritePath: String
@export var tileMeshPath: String
@export var playerColor: PlayerUtil.playerColor = PlayerUtil.playerColor.WHITE
@export var canRecruit: bool = false

@export var hexMeshName: String
@export var meshPath: String
@export var hexMeshScene: PackedScene
@export var hexMesh: Node

var targetsInRange: Array = []

@export var level: int

@export var attackable: bool = false
@export var isDefended: bool = false
var isVisual: bool = false

@export_category('Positional')
@export var q: int
@export var r: int
var tilePosition: Vector2i
@export var neighborHexTiles: Array = []

var defenseArea: Area3D

@export_category('Combat')
var isDying: bool = false
var health: int = 600
var armor: int
var attackReady: bool = false
# Grows with experience
var attackSpeed: float = 1.0
var attackCooldown: float
var attackDamage: int = 50
# Slashing, bludgening, etc.
var waysOfAttack
# Grows with experience
var accuracy: float
# What you are resistant or not resistant against
var resistanceModifiers: Dictionary = {
	UnitUtil.damageType.BASE: 0.2
}

@export_category('Resources')
var resourceType: ResourceUtil.resourceType = ResourceUtil.resourceType.NONE

signal buildingDamaged
signal buildingDied

@export_category('Input')
var mouseOver: bool = false

@export_category('Helper variables')
var hexDirections = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

func _initialize(_tilePosition: Vector2i, _hexMeshName: String, _tileName: String, _meshPath: String, _tileSpritePath: String, _isVisual: bool = false, _isDefended: bool = false, _canRecruit: bool = false, _resourceType: ResourceUtil.resourceType = ResourceUtil.resourceType.NONE):
	tilePosition = _tilePosition
	hexMeshName = _hexMeshName
	meshPath = _meshPath
	tileName = _tileName
	tileSpritePath = _tileSpritePath
	isVisual = _isVisual
	isDefended = _isDefended
	canRecruit = _canRecruit
	resourceType = _resourceType
	
	if _isVisual:
		hexMeshScene = load(meshPath)
		hexMesh = hexMeshScene.instantiate().duplicate()
		add_child(hexMesh)
		hexMesh.name = 'hexMesh'
		
		match resourceType:
			ResourceUtil.resourceType.NONE:
				%ResourceTimer.disconnect('timeout', Callable(self, '_gainResources'))
				%ResourceTimer.queue_free()
			ResourceUtil.resourceType.GOLD:
				pass
			ResourceUtil.resourceType.RESOURCE:
				pass
			_:
				%ResourceTimer.disconnect('timeout', Callable(self, '_gainResources'))
				%ResourceTimer.queue_free()
	if isDefended:
		%TileCollision.shape.height = 0.4
		%TileCollision.position.y = 0.2
		%DirectionIndicator.visible = true
	if canRecruit:
		pass
	
	if not isDefended and not canRecruit:
		disconnect("mouse_entered", Callable(self, '_onMouseEntered'))
		disconnect("mouse_exited", Callable(self, '_onMouseExited'))
	
	%Highlight.light_energy = 0

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				if mouseOver and canRecruit and not BuildingUtil.isBuildingSelected:
					UiUtil.recruitingUI.visible = true
					BuildingUtil.isBuildingSelected = true
					BuildingUtil.buildingSelected = self
				elif canRecruit and BuildingUtil.isBuildingSelected and BuildingUtil.buildingSelected == self:
					UiUtil.recruitingUI.visible = false
					BuildingUtil.isBuildingSelected = false
					BuildingUtil.buildingSelected = null

func highlight():
	%Highlight.light_energy = 1

func unhighlight():
	%Highlight.light_energy = 0

func getNeighbor(_direction: Vector2i) -> HexTile:
	return

func _on_neighbor_tracker_body_entered(body):
	if body is RigidBody3D and body not in neighborHexTiles and body != self:
		neighborHexTiles.append(body)

func _on_neighbor_tracker_body_exited(body):
	if body is RigidBody3D and body in neighborHexTiles:
		neighborHexTiles.erase(body)

func _onAttackerEntered(body):
	if body is CharacterBody3D:
		if body.playerColor != PlayerUtil.ownerPlayer.playerColor:
			targetsInRange.append(body)

func _onAttackerExited(body):
	if body is CharacterBody3D:
		if body.playerColor != PlayerUtil.ownerPlayer.playerColor:
			targetsInRange.erase(body)

func _physics_process(_delta):
	chargeAttack()

func chargeAttack():
	if not attackReady and isDefended:
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
			shoot(targetsInRange[0])
			# Make better judgement on target to hit
			targetsInRange[0].takeDamage(attackDamage, UnitUtil.damageType.BASE)

func changeColor(newColor: PlayerUtil.playerColor = PlayerUtil.playerColor.WHITE, _defenseArea: Area3D = %DefenseArea):
	playerColor = newColor
	if is_instance_valid(_defenseArea):
		if isDefended:
			match newColor:
				PlayerUtil.playerColor.WHITE:
					set_collision_layer_value(3, true)
					set_collision_layer_value(2, true)
					_defenseArea.set_collision_mask_value(3, true)
				PlayerUtil.playerColor.BLACK:
					set_collision_layer_value(3, true)
					set_collision_layer_value(2, true)
					_defenseArea.set_collision_mask_value(2, true)
			_defenseArea.set_collision_layer_value(1, false)
			_defenseArea.set_collision_mask_value(1, false)
		else:
			_defenseArea.queue_free()

func _onTreeEntered():
	changeColor(PlayerUtil.ownerPlayer.playerColor)

func shoot(_target: Soldier3D):
	%AttackIndicator.play("towerAttackIndicator")

func takeDamage(damageTaken: int, damageType: UnitUtil.damageType):
	emit_signal('buildingDamaged')
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
		die()
		emit_signal('buildingDied')

func die():
	CameraUtil.currentMap.tileDied(self)

func recruit(_unitScene: PackedScene = unitScene, _soldierScene: PackedScene = soldierScene):
	var newUnit: Unit3D = _unitScene.instantiate().duplicate()
	CameraUtil.currentMap.add_child(newUnit)
	newUnit.initializeSoldiers(10, _soldierScene)
	for soldier in newUnit.soldiers:
		soldier.position = position
		soldier.get_node('NavAgent').target_position = position
		soldier.add_to_group('soldiersInView')
		soldier.changeColor(playerColor)
	
	UnitUtil.distributeSoldiersAcrossTiles([newUnit], [self])

func _onMouseEntered():
	mouseOver = true

func _onMouseExited():
	mouseOver = false

func _gainResources():
	match resourceType:
		_:
			ResourceUtil.resourceUI.changeGold(20)
