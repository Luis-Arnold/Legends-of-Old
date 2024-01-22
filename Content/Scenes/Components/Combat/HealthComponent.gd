class_name HealthComponent extends Node3D

@export var entity: Node3D
# Make sure animations have played
@export var deathAnimation: AnimatedSprite3D

@export var health: int = 100
@export var armor: int = 10

# What you are resistant or not resistant against
@export var resistanceModifiers: Dictionary = {
	UnitUtil.damageType.BASE: 0.2
}

func _ready():
	var parent = get_parent_node_3d()
	if parent is Node3D:
		entity = parent
		entity.connect('takingDamage', Callable(self, 'onTakingDamage'))

func _process(_delta):
	if entity.isDying:
		if is_instance_valid(deathAnimation):
			if not %DamageAnimation.is_playing():
				entity.emit_signal('dying', entity)
		else:
			entity.emit_signal('dying', entity)

func onTakingDamage(damage, damageType):
	# Damage type resistances
	var damageAfterResistance: int = int(damage * (1 - resistanceModifiers[damageType]))
	# Add speed modifier
	
	var damageAfterArmor: int
	if armor > 0:
		damageAfterArmor = damageAfterResistance % armor
	else:
		damageAfterArmor = damageAfterResistance
	
	armor -= damageAfterResistance - damageAfterArmor
	health -= damageAfterArmor
	
	if health < 1:
		entity.isDying = true
