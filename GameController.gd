extends Node2D

var score = 0 setget set_score
var best = 0

signal score_changed(score)

func _ready():
	pass

func _process(delta):
	pass
	
func set_score(var value):
	score = value
	emit_signal("score_changed",score)
