extends Control

var isVisible: bool = false
var mPos: Vector2 = Vector2()
var selectionStart: Vector2 = Vector2()
const selectionBoxColor: Color = Color(0, 0.2, 1,0.3)
const selectionBoxLineWidth: int = 3

func _draw():
	if isVisible and selectionStart != mPos:
		draw_line(selectionStart, Vector2(mPos.x, selectionStart.y), selectionBoxColor, selectionBoxLineWidth)
		draw_line(selectionStart, Vector2(selectionStart.x, mPos.y), selectionBoxColor, selectionBoxLineWidth)
		draw_line(mPos, Vector2(mPos.x, selectionStart.y), selectionBoxColor, selectionBoxLineWidth)
		draw_line(mPos, Vector2(selectionStart. x, mPos.y), selectionBoxColor, selectionBoxLineWidth)

func _process(delta):
	if isVisible:
		queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				var objectsClicked: Dictionary = CameraUtil.gameCamera.rayCastMousePosition(get_local_mouse_position(), 1000, 1)
				if objectsClicked.size() > 0:
					if objectsClicked['collider'] is CharacterBody3D:
						print('Clicked Character')
