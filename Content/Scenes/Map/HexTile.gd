class_name HexTile extends RigidBody3D

var arrowScene = preload("res://Content/Scenes/Projectiles/Arrows/Arrow3D.tscn")
var soldierScene: PackedScene = preload('res://Content/Scenes/Soldier/Soldier3D.tscn')
@export var unitScenePath: String = "res://Content/Scenes/Unit/Unit3D.tscn"
var unitScene: PackedScene = preload("res://Content/Scenes/Unit/Unit3D.tscn")

@export_category('Core')
@export var tileName: String
@export var tileSpritePath: String
@export var tileMeshPath: String
@export var playerColor: PlayerUtil.playerColor = PlayerUtil.playerColor.WHITE
var buildingType
var isSelectable: bool = true
var isInteractable: bool = true

@export var hexMeshName: String
@export var meshPath: String
@export var hexMeshScene: PackedScene
@export var hexMesh: Node

@export var level: int

@export var attackable: bool = false
@export var isDefended: bool = false
var isDestructable: bool = false
var isVisual: bool = false

@export_category('Positional')
@export var q: int
@export var r: int
var tilePosition: Vector2i

var defenseArea: Area3D

@export_category('Combat')
var isDying: bool = false
var attackReady: bool = false
# Grows with experience
var attackSpeed: float = 1.0
var attackCooldown: float
var attackDamage: int = 50
# Slashing, bludgening, etc.
var waysOfAttack
# Grows with experience
var accuracy: float

@export var targetsInRange: Array = []

signal takingDamage
signal dying

@export_category('Resources')
var cost: int = 0
var resourceType: ResourceUtil.resourceType = ResourceUtil.resourceType.NONE

@export_category('Input')
var mouseOver: bool = false

@export_category('Helper variables')
var hexDirections = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

signal select
signal deselect

signal openRecruitmentUI
signal closeRecruitmentUI

func _ready():
	call_deferred('onNodesReady')

func _initialize(_cost: int, _isSelectable: bool, _isInteractable: bool, _tilePosition: Vector2i, _buildingType: BuildingUtil.buildingType, _meshPath: String, _tileSpritePath: String, _isVisual: bool = false, _isDefended: bool = false, _isDestructable: bool = false, _resourceType: ResourceUtil.resourceType = ResourceUtil.resourceType.NONE):
	cost = _cost
	tilePosition = _tilePosition
	hexMeshName = BuildingUtil.builduingTypeToString(_buildingType)
	meshPath = _meshPath
	tileName = BuildingUtil.builduingTypeToString(_buildingType)
	tileSpritePath = _tileSpritePath
	isVisual = _isVisual
	isDefended = _isDefended
	isDestructable = _isDestructable
	resourceType = _resourceType
	buildingType = _buildingType
	isSelectable = _isSelectable
	isInteractable = _isInteractable
	
	if _isVisual:
		hexMeshScene = load(meshPath)
		hexMesh = hexMeshScene.instantiate().duplicate()
		add_child(hexMesh)
		hexMesh.name = 'hexMesh'
		
		match buildingType:
			BuildingUtil.buildingType.FARM, BuildingUtil.buildingType.VILLAGE:
				pass
			_:
				%ResourceTimer.disconnect('timeout', Callable(self, '_gainResources'))
				%ResourceTimer.queue_free()
	if isDefended:
		%DirectionIndicator.visible = true
		
	if isDestructable:
		# These enable primitive collision with buildings
		%TileCollision.shape.height = 0.4
		%TileCollision.position.y = 0.2
		if CameraUtil.currentMap:
			connect('dying', Callable(CameraUtil.currentMap, 'onTileDied'))
	
	if not isInteractable:
		disconnect("mouse_entered", Callable(self, '_onMouseEntered'))
		disconnect("mouse_exited", Callable(self, '_onMouseExited'))

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_RIGHT:
					if mouseOver and isInteractable and BuildingUtil.buildingSelected != self:
						emit_signal('openRecruitmentUI')
					elif isInteractable and BuildingUtil.buildingSelected == self:
						emit_signal('closeRecruitmentUI')

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
			targetsInRange[0].emit_signal('takingDamage', attackDamage, UnitUtil.damageType.BASE)

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

func shoot(_target: Soldier3D):
	%AttackAnimation.play("towerAttack")

func _onMouseEntered():
	mouseOver = true

func _onMouseExited():
	mouseOver = false

func _gainResources():
	match buildingType:
		BuildingUtil.buildingType.VILLAGE:
			ResourceUtil.resourceUI.changeGold(6)
			ResourceUtil.resourceUI.changeResources(1)
		BuildingUtil.buildingType.FARM:
			ResourceUtil.resourceUI.changeGold(1)
			ResourceUtil.resourceUI.changeResources(4)
		_:
			pass

func onNodesReady():
	changeColor(PlayerUtil.ownerPlayer.playerColor)
