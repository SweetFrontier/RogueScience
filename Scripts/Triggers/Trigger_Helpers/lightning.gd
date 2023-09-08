extends Node2D
class_name lightning
@export var boltsArray: Array[Line2D]

@export var fromPos: Node2D
@export var toPos: Node2D
@export var jaggedness_max = 20
@export var jaggedness_min = 10
@export var jaggedness_scale = 3
@export var bolt_length_factor = 150
@export var num_of_branches = 4
@export var num_of_bisects = 7
@export var bolt_min_width = 0
@export var bolt_max_width = 4
@export var boltColor: Color

func lightning_strike():
	randomize()
	for bolt in boltsArray:
		bolt.width = randf_range(bolt_min_width,bolt_max_width)
		bolt.default_color = boltColor
		for child in bolt.get_children().size():
			bolt.get_child(child).queue_free()
		create_lightning(bolt, toPos.position)

func show_lightning():
	get_child(6).play()
	self.visible = true

func hide_lightning():
	self.visible = false

func create_lightning(bolt : Line2D, target_pos):
	var length = target_pos - position 
	bolt.clear_points()
	bolt.add_point(fromPos.position)
	bolt.add_point(target_pos - position)
	
	var persistance = 1.0
	
	for bisect in num_of_bisects:
		var local_array = bolt.points
		for point in local_array.size() - 1:
			var start = local_array[point]
			var end = local_array[point + 1]
			var mid = (end - start) / 2
			var vec = (end - start).normalized()
			var normal = Vector2(vec.y, -vec.x)
			
			var rand_scale = randf_range(jaggedness_min, jaggedness_max) * random_pos_or_neg()
			var new_point = start  + mid + (rand_scale * jaggedness_scale * (length / bolt_length_factor) * persistance * normal)
			persistance *= 0.8
			bolt.add_point(new_point, (point * 2) + 1)
	
func random_pos_or_neg():
	var s = bool(randi() % 2)
	if s:
		return 1 
	else:
		return -1
