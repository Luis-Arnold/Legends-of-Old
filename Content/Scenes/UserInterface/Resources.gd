extends Control

var gold: int = 0
var resources: int = 0

signal goldGained
signal goldLost
signal resourcesGained
signal resourcesLost

func _ready():
	ResourceUtil.resourceUI = self
	changeGold(280)
	changeResources(280)

func changeGold(_amount: int):
	if _amount > 0:
		emit_signal("goldGained")
	elif _amount < 0:
		emit_signal("goldLost")
	gold += _amount
	%Gold.text = str(gold)

func changeResources(_amount: int):
	if _amount > 0:
		emit_signal("resourcesGained")
	elif _amount < 0:
		emit_signal("resourcesLost")
	resources += _amount
	%Material.text = str(resources)

func technologiePressed():
	var techTree = load("res://Content/Scenes/UserInterface/Technologie.tscn").instantiate()
	CameraUtil.currentMap.add_child(techTree)
