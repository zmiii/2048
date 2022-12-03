extends Node2D

#数值
var number = 0 setget number_set
#坐标
var point = Vector2(0,0)

func _ready():
	pass

func _physics_process(delta):
	pass

func number_set(value):
	number = value
	$Number.text = String(number)
	#根据number调整字体、前景色、背景色
	#背景块统一使用一个stylebox，数据块需要单独设置stylebox
	#按理说可以使用唯一化，保证每一个stylebox都是独立的，节省这段代码，节约性能
	#但很显然我对唯一化的理解和使用有问题，而且，这游戏既不需要多高的性能，这么写也不一定消耗多少性能
	$Background.remove_stylebox_override("panel")
	var styleboxflat = StyleBoxFlat.new()
	styleboxflat.bg_color = BlockModel.bgColor[number]
	$Background.add_stylebox_override("panel",styleboxflat)
	
	$Number.get_font("font").size = BlockModel.numSize[number]
	if number > 4:
		var fc = $Number.get_color("font_color")
		var fcs = $Number.get_color("font_color_shadow")
		fc = BlockModel.numColor["white"]
		fcs = BlockModel.numColor["white"]
		
	show()

func move(var target:Vector2):
	$Tween.interpolate_property(self, "position",
		self.position, target, 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

#更改分数和新建时从小变大的效果
func show():
	$Tween.interpolate_property(self, "scale",
		self.scale, Vector2(1.3,1.3), 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	yield($Tween,"tween_completed")
	$Tween.interpolate_property(self, "scale",
		self.scale, Vector2(1,1), 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func calculate():
	pass

func text_clear():
	$Number.text = ""

func text_free():
	$Number.queue_free()


#当前块转换做背景
func to_background():
	text_free()
	$Background.get_stylebox("panel","").bg_color = BlockModel.bBgColor
