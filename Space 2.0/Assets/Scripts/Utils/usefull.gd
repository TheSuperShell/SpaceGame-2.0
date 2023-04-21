extends Node

var map_size = [-8000, 8000, -8000, 8000]
var gas_mass_limit = 300000
var star_mass_limit = 10000000
var bh_star_limit = 200000000
var G = 0.005

func liniar(x1, y1, x2, y2, x):
	var a = (y2 - y1) / (x2 - x1)
	var b = y1 - a * x1
	return a * x + b
