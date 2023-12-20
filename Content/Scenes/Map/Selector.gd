extends Control

var draggingLeft: bool
var selectionStart: Vector2 = Vector2()
const selectionBoxColor: Color = Color(0, 0.2, 1,0.3)
const selectionBoxLineWidth: int = 3

func _process(delta):
	if draggingLeft:
		queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				var soldier = CameraUtil.gameCamera.getUnitUnderMouse(get_local_mouse_position())
				if is_instance_valid(soldier):
					print('Clicked Character')
