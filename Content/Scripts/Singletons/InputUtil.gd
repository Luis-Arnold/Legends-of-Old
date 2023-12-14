extends Node

func isLeftMousePressed(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT \
			and event.is_pressed()
	else:
		return false

func isLeftMouseReleased(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT \
			and event.is_released()
	else:
		return false

func isSpaceBarPressed(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.keycode == KEY_SPACE \
			and event.is_pressed()
	else:
		return false

func isSpaceBarReleased(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.keycode == KEY_SPACE \
			and event.is_released()
	else:
		return false
