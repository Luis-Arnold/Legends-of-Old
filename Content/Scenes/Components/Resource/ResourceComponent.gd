extends Node3D

@export var entity: Node3D

var gold: int = 0
var resources: int = 0

func _ready():
	var parent = get_parent_node_3d()
	if parent is Node3D:
		entity = parent
	
	setResources()
	
	%ResourceTimer.connect('timeout', Callable(self, '_gainResources'))
#	match entity.buildingType:
#		BuildingUtil.buildingType.FARM, BuildingUtil.buildingType.VILLAGE:
#		_:
#			%ResourceTimer.queue_free()

func setResources():
	if entity.gameClass:
		match entity.gameClass:
			GameUtil.gameClass.HEXTILE:
				match entity.buildingType:
					BuildingUtil.buildingType.VILLAGE:
						gold = 6
						resources = 1
					BuildingUtil.buildingType.FARM:
						gold = 1
						resources = 4
					_:
						queue_free()
			GameUtil.gameClass.UNIT3D:
				gold = 3
				resources = 3
			_:
				queue_free()

func _gainResources():
	ResourceUtil.resourceUI.changeGold(gold)
	ResourceUtil.resourceUI.changeResources(resources)
