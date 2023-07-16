extends CanvasLayer

signal toggle_time(time_stopped)
signal change_time_warp(time_warp)
signal toggle_action_mode(mode)

var time_stopped = false
var time_warp = 1.0
var slideBarUp = false

var mass = 100
var radius = 10
var random = false

var planet_stats = null
var rightBarUp = false

@onready var timeIndicator = $LowerBar/LowerBarElements/TimeWarp/TimeIndicator/Label
@onready var functionalButtons = $LowerBar/LowerBarElements/OtherButtons
@onready var slideBar = $SlideLowerBar
@onready var animation = $AnimationPlayer

signal planet_parameters_changed(mass, radius, random)

enum {
	IDLE
	CREATE
	DELETE
}
var mode = IDLE

func _ready():
	$PlanetShadowNode/PlanetShadow.visible = false
	for button in $LowerBar/LowerBarElements/TimeWarp.get_children():
		if button is Button:
			button.connect("pressed", Callable(self, "_on_Button_pressed").bind(button))
	for button in functionalButtons.get_children():
		button.connect("pressed", Callable(self, "_on_Button_toggled").bind(button))
		
func _process(_delta):
	if planet_stats:
		$RightPanel/RightBarElements/Mass/SpinBox.value = planet_stats.mass
		$RightPanel/RightBarElements/Radius/SpinBox.value = planet_stats.radius
		if planet_stats.angular_velocity != 0:
			$RightPanel/RightBarElements/AngularVelocity/SpinBox.value = 2 * PI / planet_stats.angular_velocity
		else:
			$RightPanel/RightBarElements/AngularVelocity/SpinBox.value = 0
		$RightPanel/RightBarElements/Velocity/SpinBox.value = planet_stats.velocity.length()
	if mode == CREATE:
		$PlanetShadowNode/PlanetShadow.global_position = $PlanetShadowNode.get_local_mouse_position()

func _on_Button_pressed(button):
	if button.time_warp == "pause":
		time_stopped = not time_stopped
		if time_stopped:
			button.label.text = ">"
		else:
			button.label.text = "||"
		emit_signal("toggle_time", time_stopped)
	if button.time_warp == "up":
		time_warp *= 2
		emit_signal("change_time_warp", time_warp)
		timeIndicator.text = write_time_warp(time_warp)
	elif button.time_warp == "down":
		time_warp /= 2
		emit_signal("change_time_warp", time_warp)
		timeIndicator.text = write_time_warp(time_warp)

func write_time_warp(time):
	var final_string = str(time) + " s / second"
	if time > 60:
		final_string = str(round(time / 60)) + " m / second"
	if time > 3600:
		final_string = str(round(time / 3600)) + " h / second"
	if time > 86400:
		final_string = str(round(time / 86400)) + " d / second"
	return final_string

func _on_Button_toggled(button):
	for but in functionalButtons.get_children():
		if but != button:
			but.button_pressed = false
	if button.action == "create":
		mode = CREATE
		animation.play("SlideBarUp")
		slideBarUp = true
	if button.action == "delete":
		mode = DELETE
		if slideBarUp:
			animation.play("SlideBarDown")
			slideBarUp = false
	if not button.pressed:
		mode = IDLE
		if slideBarUp:
			animation.play("SlideBarDown")
			slideBarUp = false
	emit_signal("toggle_action_mode", mode)

func _on_Mass_value_changed(value):
	mass = value
	emit_signal("planet_parameters_changed", mass, radius, random)

func _on_Radius_value_changed(value):
	radius = value
	emit_signal("planet_parameters_changed", mass, radius, random)

func _on_CheckButton_toggled(button_pressed):
	random = button_pressed
	emit_signal("planet_parameters_changed", mass, radius, random)

func _on_ObjectList_planet_chosen(planet):
	planet_stats = planet
	if planet_stats:
		planet_stats.planet_stats_is_seen = true
	if not rightBarUp:
		animation.play("RightBarUp")
		rightBarUp = true
	if not planet_stats and rightBarUp:
		animation.play("RightBarDown")
		rightBarUp = false

func _on_Exit_pressed():
	rightBarUp = false
	animation.play("RightBarDown")
	planet_stats.planet_stats_is_seen = false
	planet_stats = null

func _on_SpinBox_value_changed(value):
	planet_stats.mass = value
	planet_stats.type.mass = value
	planet_stats.type.check_mass()
