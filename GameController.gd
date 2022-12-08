extends Node2D

var score = 0 setget set_score
var best = 0

signal score_changed(score)

#2048里控制器这玩意属实没啥用，最后也没想到有什么需要全局报错的，但……加都加了
func _ready():
	pass

func _process(delta):
	pass
	
func set_score(var value):
	score = value
	emit_signal("score_changed",score)
