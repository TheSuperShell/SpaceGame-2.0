extends Area2D

var host: Object

func _ready():
	host = get_parent().get_parent()

