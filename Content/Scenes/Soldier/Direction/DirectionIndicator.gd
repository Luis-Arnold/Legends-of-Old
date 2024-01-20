class_name DirectionIndicator extends Sprite3D

@export var soldier: CharacterBody3D
var direction: float
var rotationSpeed: int = 1

var stoppedRotating: bool = true

const twoPI = 2.0 * PI

func _physics_process(_delta):
	if not stoppedRotating:
		var currentRotation = fmod(rotation.z + twoPI, twoPI)
		var targetDirection = fmod(direction + twoPI, twoPI)
		
		var diff = fmod(targetDirection - currentRotation + twoPI, twoPI)
		if diff > PI:
			diff -= twoPI
		
		if abs(diff) > 0.01:  # Use a small threshold to avoid constant oscillation
			rotation.z += rotationSpeed * _delta * sign(diff)
#		else:
#			stoppedRotating = true

func changeDirection(newDirection: float):
	stoppedRotating = false
	direction = newDirection
