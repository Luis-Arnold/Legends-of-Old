extends Control

@export var units: Array = []
@export var unitScenePath: String = "res://Content/Scenes/Unit/Unit3D.tscn"
@export var unitScene: PackedScene

func _ready():
	UiUtil.recruitingUI = self
	
	unitScene = load(unitScenePath)
	var newUnit = unitScene.instantiate().duplicate()
	newUnit._initialize(UnitUtil.unitType.ANY, UnitUtil.soldierType.SOLDIER, 'soldierTypePath', load("res://Content/Resources/Visual/2D/Icons/Soldiers/soldierIcon.png"), false)
	units.append(newUnit)
	
	for unit in units:
		var unitButton: Button = Button.new()
		unitButton.icon = unit.soldierImage
		unitButton.connect('pressed', Callable(UnitUtil, 'setPlacingUnit').bind(unit))
		unitButton.connect('mouse_entered', Callable(UnitUtil, 'mouseEnteredButton'))
		unitButton.connect('mouse_exited', Callable(UnitUtil, 'mouseExitedButton'))
		
		add_child(unitButton)
	
	visible = false
