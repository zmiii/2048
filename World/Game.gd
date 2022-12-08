extends Node2D

#预加载block场景（节点集） 用于添加块时随时实例化 instance
onready var block_sence = preload("res://World/Block.tscn")

var map = []

#游戏是否已经结束
var game_over = false
#是否有块移动过
var has_move_block = false

func _ready():
	#设置随机数种子
	randomize()
	#生成背景
	create_block_backgournd()
	#初始化地图
	create_map()
	
func _process(delta):
	if !game_over:
		input_check()
	
	if $BackGround/Panel/Debug.visible:
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
	#重置移动指示器
	has_move_block = false
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
			block_move(block,new_map_point)
			has_move_block = true
	#如果没有块移动跳过剩余计算且不生成块
	if !has_move_block:
		return
	#检测是否胜负
	#如果返回false则不可以继续游玩
	if !map_check():
		return
	#可以继续游玩则重置块合并状态
	for block in $Blocks.get_children():
		block.has_merge = false
	#移动完成后创建一个新块
	create_block(2,rand_block())

func move(var row,var col,var dire:Vector2):
	#如果当前为0则跳过 
	if map[row][col] == 0:
		return null
	#如果下一块超出数组则返回下标
	elif row + dire.x < 0 or col + dire.y < 0 or row + dire.x >= len(map) or col + dire.y >= len(map[row]):
		return Vector2(row,col)
	#如果下一块为0则移动过去
	elif map[row + dire.x][col + dire.y] == 0:
		map[row + dire.x][col + dire.y] = map[row][col]
		map[row][col] = 0
		var end_point = move(row + dire.x,col + dire.y,dire)
		return end_point
	#如果下一块相同则合并\并且本次移动没有合并过
	elif map[row + dire.x][col + dire.y] == map[row][col]:
		#由于需要更改bolck状态，所以分离判断条件
		var block = find_block(Vector2(row + dire.x,col + dire.y))
		if !block.has_merge:
			map[row + dire.x][col + dire.y] += map[row][col]
			map[row][col] = 0
			block.has_merge = true
			#合并获得积分
			$GameController.score = String(map[row + dire.x][col + dire.y] + int($GameController.score))
			return Vector2(row + dire.x,col + dire.y)
	#如果下一块不同或者已经合并过则不移动
	return Vector2(row,col)

#将目标块移动指指定下标对应位置位置
func block_move(var block,var point : Vector2):
	if block == null:
		print(block)
	#转换下标为坐标
	var target = map_inpot_to_position(point)
	var target_block = find_block(point)
	#如果没有目标块则移动，否则移动后销毁对象
	if target_block == null:
#		yield(block.move(target),"completed")
		block.move(target)
		block.point = point
	else:
		#不知道为什么，SceneTreeTween在ready初始化后没有使用，process中过三个func就无效了，第四个func就报错提示null，看不懂，但大受震撼
		#查了一下，SceneTreeTween会自动释放，所以，为什么每次都用create_tween还是偶发性报错，离谱
		block.move(target)
		target_block.number = block.number * 2
		target_block.point = point
		block.free()

#检查地图是否还能继续游玩
func map_check():
	#空余块计数器
	var zero_count = 0
	#优先检查一次是胜利或者还能继续
	for row in range(0,4,1):
		for col in range(0,4,1):
			if map[row][col] == 2048:
				$GameOver.visible = true
				game_over = true
				return false
			elif map[row][col] == 0:
				zero_count += 1
	if zero_count > 0:
		return zero_count
	
	#满屏且没有胜利，则检查是否失败，未失败则继续游戏且不生成块
	for row in range(0,4,1):
		for col in range(0,4,1):
			if !map_contrast(row,col):
				$GameOver.visible = true
				game_over = true
				return false
			else:
				return true

#地图节点对比查看四个方向是否有相邻且相同的块
func map_contrast(var row,var col):
	for dire in BlockModel.blockDirection.values():
		#如果下一块超出数组则检查下一个方向
		if row + dire.x < 0 or col + dire.y < 0 or row + dire.x >= len(map) or col + dire.y >= len(map[row]):
			continue
		elif map[row + dire.x][col + dire.y] == map[row][col]:
			#如果相邻方块有相同则游戏继续
			return true
	return false

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
	$GameController.score = "0"
	game_over = false
	$GameOver.visible = false

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
	pos.x = vec.y * 128 + 8 + 60
	pos.y = vec.x * 128 + 8 + 60
	return pos

#生成背景block
func create_block_backgournd():
	var block_position = Vector2(68,68)
	for	_row in range(1,5,1):
		for	_col in range(1,5,1):
			var block = block_sence.instance()
			block.to_background()
			block.position = block_position
			$BgBlock.add_child(block)
			block_position.y += 128
		#生成第二行背景需要重新设定position
		block_position.x += 128
		block_position.y = 68

#根据下标生成块！需注意确保地图仍有空余
func create_block(var num,var vec:Vector2):
	while map[vec.x][vec.y] != 0:
		vec = rand_block()
	map[vec.x][vec.y] = num
	var pos = map_inpot_to_position(vec)
	var block = block_sence.instance()
	$Blocks.add_child(block)
	block.position = pos
	block.point = vec
	block.number = num

func _on_NewGame_button_down() -> void:
	restart()


func _on_GameController_score_changed(score) -> void:
	$BackGround/Score/Content.text = score



#test
#显示地图数组
func show_maps():
	$BackGround/Panel/Debug/MapArray.text = ""
	for row in range(0,4,1):
		for col in range(0,4,1):
			$BackGround/Panel/Debug/MapArray.text += String(map[row][col]) + "  "
		$BackGround/Panel/Debug/MapArray.text += "\n"
		
#创建一个块
func _on_Button_button_down() -> void:
	for row in range(0,4,1):
		for col in range(0,4,1):
			if map[row][col] == 0:
				create_block(2,rand_block())
				return
#创建测试地图和块
func _on_CreateTestMapButton_button_down() -> void:
	var numbers = [2,4,8,16,32,64,128,256]
	
	var count = 0
	for row in range(0,4,1):
		for col in range(0,4,1):
			if map[row][col] == 0:
				count += 1
	while count > 0:
		create_block(numbers[randi() % 7],rand_block())
		count -= 1
		
#创建即将胜利的地图
func _on_CreateWinMapButton_button_down() -> void:
	create_block(1024,Vector2(0,0))
	create_block(1024,Vector2(0,1))
	for i in [0,1]:
		create_block(256,rand_block())
	for i in [0,1]:
		create_block(1024,rand_block())

#创建即将满足失败条件的地图
func _on_CreateLoseMapButton_button_down() -> void:
	#初始化
	map.clear()
	#初始化二维数组
	for	_row in range(0,4,1):
		map.append([0,0,0,0])
	for block in $Blocks.get_children():
		block.queue_free()
	$GameController.score = "0"
	game_over = false
	$GameOver.visible = false
	#保证有两个可以合成
	var num = 2
	for row in range(0,4,1):
		for col in range(0,4,1):
			create_block(num,Vector2(row,col))
			if num == 1024:
				num = 2
			num = num * 2

	map[0][0] = 4
	var block = find_block(Vector2(0,0))
	block.number = 4

func _on_ShowDialogButton_button_down() -> void:
	$GameOver.visible = !$GameOver.visible

