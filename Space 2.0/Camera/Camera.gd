extends Camera2D

export(float) var MAX_ZOOM = 0.1
export(float) var MIN_ZOOM = 4

var zoom_amount = 1.0 setget _set_zoom_level

var previous_position = Vector2.ZERO

enum {
	IDLE,
	MOVING
}

var state = IDLE

signal zoom_changed(value)

func _ready():
	var topleft = $topleft.global_position
	var bottomright = $bottomright.global_position
	limit_top = topleft.y
	limit_left = topleft.x
	limit_bottom = bottomright.y
	limit_right = bottomright.x
	$ParallaxBackground/BlackBG.visible = true
	$ParallaxBackground/Sprite.visible = true

func _process(_delta):
	match state:
		IDLE:
			idle_state()
		MOVING:
			move_state()
			
func idle_state():
	if Input.is_action_just_pressed("lmb"):
		previous_position = get_global_mouse_position()
		state = MOVING

func move_state():
	global_position = previous_position - get_local_mouse_position()
	global_position.x = clamp(global_position.x, -8000, 8000)
	global_position.y = clamp(global_position.y, -8000, 8000)
	if Input.is_action_just_released("lmb"):
		state = IDLE
	
func _set_zoom_level(value):
	zoom_amount = clamp(value, MAX_ZOOM, MIN_ZOOM)
	zoom = Vector2(zoom_amount, zoom_amount)
	

func _input(event):
	if event is InputEventMouseButton and state == IDLE:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_set_zoom_level(zoom_amount - 0.1)
			if event.button_index == BUTTON_WHEEL_DOWN:
				_set_zoom_level(zoom_amount + 0.1)
			emit_signal("zoom_changed", zoom_amount)
	
	

