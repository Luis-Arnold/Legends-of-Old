extends AnimatedSprite3D

@export var soldier: CharacterBody3D

func _ready():
	var parent = get_parent_node_3d()
	if parent is CharacterBody3D:
		soldier = parent
		soldier.connect('takingDamage', Callable(self, 'onDamaged'))

func onDamaged(_damage: int, _damageType: UnitUtil.damageType):
	play('default')
