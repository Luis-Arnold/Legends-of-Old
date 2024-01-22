extends Control

@export var entity: Node3D

var recruitmentOptions: Array = []
var unitButtons: Array = []
var recruitmentQueue: Array = []
var unitProgressBars: Array = []

func _ready():
	var parent: Node3D = get_parent()
	if parent is RigidBody3D:
		entity = parent
		entity.connect('openRecruitmentUI', Callable(self, 'openRecruitmentUI'))
		entity.connect('closeRecruitmentUI', Callable(self, 'closeRecruitmentUI'))
	call_deferred('onNodesReady')

func onNodesReady():
	if entity.isSelectable:
		%RecruitTimer.connect('timeout', Callable(self, 'recruit'))
		
		var unitOption = entity.unitScene.instantiate().duplicate()
		unitOption._initialize(UnitUtil.unitType.ANY, \
			UnitUtil.soldierType.SOLDIER, \
			'soldierTypePath', \
			load("res://Content/Resources/Visual/2D/Icons/Soldiers/soldierIcon.png"), \
			false)
		recruitmentOptions.append(unitOption)

func _physics_process(_delta):
	if entity.isSelectable:
		queueRecruitment()

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
	newUnit.initializeSoldiers(10, false, entity.soldierScene)
	for soldier in newUnit.soldiers:
		soldier.position = entity.position
		soldier.get_node('NavAgent').target_position = entity.position
		soldier.add_to_group('soldiersInView')
		soldier.changeColor(entity.playerColor)
	if len(unitProgressBars) > 0:
		unitProgressBars[0].value = 0.0
	UnitUtil.distributeSoldiersAcrossTiles([newUnit], [entity])

func startRecruitment(_unit: Unit3D):
	if ResourceUtil.resourceUI.gold >= _unit.cost:
		ResourceUtil.resourceUI.changeGold(-_unit.cost)
		recruitmentQueue.append(_unit)
	else:
		pass

func openRecruitmentUI():
	setUpRecruitingButtons()
	UIUtil.recruitingUI.visible = true
	BuildingUtil.buildingSelected = entity

func closeRecruitmentUI():
	resetRecruitingUI()
	UIUtil.recruitingUI.visible = false
	BuildingUtil.buildingSelected = null

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
