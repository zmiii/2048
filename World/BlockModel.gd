extends Node
#作为背景时块的颜色
onready var bBgColor = Color("cdc1b4") 
#分数对应的背景颜色
var bgColor = {}
#分数字体颜色
var numColor = {}
#分数字体大小
var numSize = {}
#块移动方向
var blockDirection = {
	UP = Vector2(-1,0),
	DOWN = Vector2(1,0),
	LEFT = Vector2(0,-1),
	RIGHT = Vector2(0,1)
}
func _init() -> void:
	bgColor[2] = Color("eee4da")
	bgColor[4] = Color("ede0c8")
	bgColor[8] = Color("f2b179")
	bgColor[16] = Color("f59563")
	bgColor[32] = Color("f67c5f")
	bgColor[64] = Color("f65e3b")
	bgColor[128] = Color("edcf72")
	bgColor[256] = Color("edcc61")
	bgColor[512] = Color("edc850")
	bgColor[1024] = Color("edc53f")
	bgColor[2048] = Color("edc22e")
	bgColor["super"] = Color("3c3a32")
	
	numColor["black"] = Color("776e65")
	numColor["white"] = Color("f9f6f2")
	
	numSize[2] = 80
	numSize[4] = 80
	numSize[8] =  80
	numSize[16] = 80
	numSize[32] = 80
	numSize[64] = 80
	numSize[128] = 64
	numSize[256] = 64
	numSize[512] = 64
	numSize[1024] = 48
	numSize[2048] = 48

