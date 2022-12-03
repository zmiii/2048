extends Node2D

#预加载block场景（节点集） 用于添加块时随时实例化 instance
onready var block_sence = preload("res://World/Block.tscn")

var map = []

func _ready():
	#设置随机数种子
	randomize()
	#生成背景
	create_block_backgournd()
	#初始化地图
	create_map()
	
func _process(delta):
	input_check()
	
	show_maps()

func input_check():
	if Input.is_action_just_pressed("ui_up"):
		calculate(BlockModel.blockDirection["UP"])
	elif Input.is_action_just_pressed("ui_down"):
		calculate(BlockModel.blockDirection["DOWN"])
	elif Input.is_action_just_pressed("ui_left"):
		calculate(BlockModel.blockDirection["LEFT"])
	elif Input.is_action_just_pressed("ui_right"):
		calculate(BlockModel.blockDirection["RIGHT"])
	
	if Input.is_action_just_pressed("ui_home"):
		$BackGround/Panel/Debug.visible = !$BackGround/Panel/Debug.visible

func calculate(var dire):
	#根据方向确定正序遍历还是反序
	var for_array = []
	if dire == BlockModel.blockDirection["UP"] or dire == BlockModel.blockDirection["LEFT"]:
		for_array = [0,1,2,3]
	elif dire == BlockModel.blockDirection["DOWN"] or dire == BlockModel.blockDirection["RIGHT"]:
		for_array = [3,2,1,0]
	for row in for_array:
		for col in for_array:
			var new_map_point = move(row,col,dire)
			#如果目标块为空或与目标快重叠则进入下一个块
			if new_map_point == null:
				continue
			if new_map_point == Vector2(row,col):
				continue
			var block = find_block(Vector2(row,col))
			if block == null:
				var v = 1
			block_move(block,new_map_point)
	#检测是否胜负
	
	#移动完成后创建一个新块
	create_block(2,rand_block())

func move(var row,var col,var dire:Vector2):
	#如果当前为0则跳过 
	if map[row][col] == 0:
		return null
	#如果下一块超出数组则跳过当前块，即如果当前为边缘块则返回下标
	elif row + dire.x < 0 or col + dire.y < 0:
		return Vector2(row,col)
	elif  row + dire.x >= len(map) or col + dire.y >= len(map[row]):
		return Vector2(row,col)
	#如果下一块为0则移动过去
	elif map[row + dire.x][col + dire.y] == 0:
		map[row + dire.x][col + dire.y] = map[row][col]
		map[row][col] = 0
		var end_point = move(row + dire.x,col + dire.y,dire)
		return end_point
	#如果下一块相同则合并
	elif map[row + dire.x][col + dire.y] == map[row][col]:
		map[row + dire.x][col + dire.y] += map[row][col]
		map[row][col] = 0
		return Vector2(row + dire.x,col + dire.y)
	#如果下一块不同则不移动
	return Vector2(row,col)

#将目标块移动指指定下标对应位置位置
func block_move(var block,var point : Vector2):
	#转换下标为坐标
	var target = map_inpot_to_position(point)
	var target_block = find_block(point)
	#如果没有目标块则移动，否则移动后销毁对象
	if target_block == null:
#		create_tween().tween_property(block,"position",target,0.1)
		block.move(target)
		block.point = point
	else:
		#不知道为什么，SceneTreeTween在ready初始化后没有使用，process中过三个func就无效了，第四个func就报错提示null，看不懂，但大受震撼
#		yield(create_tween().tween_property(block,"position",target,0.1), "finished")
		block.move(target)
		target_block.number = block.number * 2
		target_block.point = point
		block.free()

func create_map():
	#初始化二维数组
	for	_row in range(0,4,1):
		map.append([0,0,0,0])
	#生成两个初始block
	create_block(2,rand_block())
	create_block(2,rand_block())

func restart():
	map.clear()
	for block in $Blocks.get_children():
		block.queue_free()
	create_map()

#根据下标查询块
func find_block(var point:Vector2):
	for block in $Blocks.get_children():
		if block.point == point:
			return block
	return null

#随机生成块坐标
func rand_block():
	return Vector2(randi() % 4,randi() % 4)

#将map下标转换为生成块的坐标
#因为下标与坐标相反，所以需要交替计算
func map_inpot_to_position(var vec:Vector2):
	var pos = Vector2()
	pos.x = vec.y * 128 + 8
	pos.y = vec.x * 128 + 8
	return pos

#生成背景block
func create_block_backgournd():
	var block_position = Vector2(8,8)
	for	_row in range(1,5,1):
		for	_col in range(1,5,1):
			var block = block_sence.instance()
			block.to_background()
			block.position = block_position
			$BgBlock.add_child(block)
			block_position.y += 128
		#生成第二行背景需要重新设定position
		block_position.x += 128
		block_position.y = 8

#根据下标生成块
func create_block(var num,var vec:Vector2):
	while map[vec.x][vec.y] != 0:
		vec = rand_block()
	map[vec.x][vec.y] = num
	var pos = map_inpot_to_position(vec)
	var block = block_sence.instance()
	block.position = pos
	block.point = vec
	block.number = num
	
	$Blocks.add_child(block)


func _on_NewGame_button_down() -> void:
	restart()





#test
func _on_Button_button_down() -> void:
	create_block(2,rand_block())

func show_maps():
	$BackGround/Panel/Debug/MapArray.text = ""
	for row in range(0,4,1):
		for col in range(0,4,1):
			$BackGround/Panel/Debug/MapArray.text += String(map[row][col])
		$BackGround/Panel/Debug/MapArray.text += "\n"
