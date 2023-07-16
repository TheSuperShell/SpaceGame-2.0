extends Control

@onready var buttons = $MenuColor/Menu/Buttons

func _ready():
	for button in buttons.get_children():
		button.connect("pressed", Callable(self, "_on_Button_pressed").bind(button.command))

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pause_toggle()

func pause_toggle():
	var pause_state = not get_tree().paused
	get_tree().paused = not get_tree().paused
	visible = pause_state
	
func _on_Button_pressed(command):
	if command == "resume":
		pause_toggle()
	if command == "exit":
		get_tree().quit()
