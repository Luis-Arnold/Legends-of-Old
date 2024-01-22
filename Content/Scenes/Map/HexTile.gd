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
signal buildingDied

@export_category('Resources')
var cost: int = 0
var resourceType: ResourceUtil.resourceType = ResourceUtil.resourceType.NONE

@export_category('Recruitment')
var recruitmentQueue: Array = []
var recruitmentOptions: Array = []
@export var unitButtons: Array = []
@export var unitProgressBars: Array = []

@export_category('Input')
var mouseOver: bool = false

@export_category('Helper variables')
var hexDirections = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

signal select
signal deselect

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
	
	if not isInteractable:
		disconnect("mouse_entered", Callable(self, '_onMouseEntered'))
		disconnect("mouse_exited", Callable(self, '_onMouseExited'))

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_RIGHT:
					if mouseOver and isInteractable and BuildingUtil.buildingSelected != self:
						setUpRecruitingButtons()
						UIUtil.recruitingUI.visible = true
						BuildingUtil.buildingSelected = self
					elif isInteractable and BuildingUtil.buildingSelected == self:
						resetRecruitingUI()
						UIUtil.recruitingUI.visible = false
						BuildingUtil.buildingSelected = null

func _process(_delta):
	if isDying:
		die()

func _physics_process(_delta):
	chargeAttack()
	if isSelectable:
		queueRecruitment()

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

func die():
	CameraUtil.currentMap.tileDied(self)

func queueRecruitment():
	if %RecruitTimer.is_stopped() \
		and len(recruitmentQueue) > 0:
#		UIUtil.recruitingUI.unitProgressBars[0].value = %RecruitTimer.wait_time*10
		%RecruitTimer.start()
	elif not %RecruitTimer.is_stopped() and len(recruitmentQueue) > 0 and len(unitProgressBars) > 0:
		var _progressBar = unitProgressBars[0]
		_progressBar.value = _progressBar.max_value - %RecruitTimer.time_left*10

func recruit():
	var currentUnit = recruitmentQueue.pop_front()
	
	var newUnit: Unit3D = currentUnit.duplicate()
	CameraUtil.currentMap.add_child(newUnit)
	newUnit.initializeSoldiers(10, false, soldierScene)
	for soldier in newUnit.soldiers:
		soldier.position = position
		soldier.get_node('NavAgent').target_position = position
		soldier.add_to_group('soldiersInView')
		soldier.changeColor(playerColor)
	if len(unitProgressBars) > 0:
		unitProgressBars[0].value = 0.0
	UnitUtil.distributeSoldiersAcrossTiles([newUnit], [self])

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

func startRecruitment(_unit: Unit3D):
	if ResourceUtil.resourceUI.gold >= _unit.cost:
		ResourceUtil.resourceUI.changeGold(-_unit.cost)
		recruitmentQueue.append(_unit)
	else:
		pass

func onNodesReady():
	if isSelectable:
		%RecruitTimer.connect('timeout', Callable(self, 'recruit'))
		
		var unitOption = unitScene.instantiate().duplicate()
		unitOption._initialize(UnitUtil.unitType.ANY, \
			UnitUtil.soldierType.SOLDIER, \
			'soldierTypePath', \
			load("res://Content/Resources/Visual/2D/Icons/Soldiers/soldierIcon.png"), \
			false)
		recruitmentOptions.append(unitOption)
	changeColor(PlayerUtil.ownerPlayer.playerColor)

func setUpRecruitingButtons():
#	var unitOption2 = unitScene.instantiate().duplicate()
#	unitOption2._initialize(UnitUtil.unitType.ANY, \
#		UnitUtil.soldierType.SOLDIER, \
#		'soldierTypePath', \
#		load("res://Content/Resources/Visual/2D/Icons/Soldiers/soldierIcon.png"), \
#		false)
#	recruitmentOptions.append(unitOption2)
	
	for unit in recruitmentOptions:
		var unitButton: Button = Button.new()
		UIUtil.recruitingUI.add_child(unitButton)
		unitButton.icon = unit.soldierImage
		unitButton.connect('pressed', Callable(self, 'startRecruitment').bind(unit))
		unitButton.connect('mouse_entered', Callable(UnitUtil, 'mouseEnteredButton'))
		unitButton.connect('mouse_exited', Callable(UnitUtil, 'mouseExitedButton'))
		unitButtons.append(unitButton)
		
		var unitProgressBar: ProgressBar = ProgressBar.new()
		UIUtil.recruitingUI.add_child(unitProgressBar)
		unitProgressBars.append(unitProgressBar)

func resetRecruitingUI():
	for unitButton in unitButtons:
		unitButton.queue_free()
	unitButtons.clear()
	for prgoressBar in unitProgressBars:
		prgoressBar.queue_free()
	unitProgressBars.clear()
