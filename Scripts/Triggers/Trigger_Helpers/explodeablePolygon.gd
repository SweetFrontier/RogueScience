extends Polygon2D

class_name explodeablePolygon

signal finished_imploding_signal

@export var shard_type = ShardType.SQUARES
@export var shard_count = 32
@export var invisible = false

@export_group("Triangle Properties")
@export var shard_shrink_rate: float = 0.95  # Adjust this for shard lifetime
@export var min_shard_size: float = 0.1  # Adjust this for the minimum shard size (area)
@export var x_init_velocity: int
@export var y_init_velocity: int
@export var shard_speed: float
@export var rotation_speed: float
@export var shard_gravity: float
var shard_velocity_map = {}
var imploded_shards = []

@export_group("Squares Properties")
@export var x_max_distance: int
@export var x_min_distance: int
@export var y_max_distance: int
@export var y_min_distance: int
@export var time_to_form: float
var shard_goal_pos_map = {}
var elapsed_time: float = 0.0
var imploded = false

enum ShardType {
	TRIANGLES,
	SQUARES
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func explode():
	reset()
	var shards = generate_triangles() if shard_type == ShardType.TRIANGLES else generate_squares()
	for shard in shards:
		shard.position = Vector2(0, 0)
		shard_velocity_map[shard] = Vector2(randi_range(-x_init_velocity,x_init_velocity), randi()%y_init_velocity)
		add_child(shard)
	#make original polygon invisible
	color.a = 0

func implode():
	reset()
	var shards = generate_triangles() if shard_type == ShardType.TRIANGLES else generate_squares()
	for shard in shards:
		shard.position = Vector2(randi_range(x_min_distance, x_max_distance), randi_range(y_min_distance, y_max_distance))
		shard_goal_pos_map[shard] = shard.position
		add_child(shard)
	elapsed_time = 0.0
	imploded = true

func generate_triangles():
	var shards = []
	var points = polygon
	for i in range(shard_count):
		points.append(Vector2(randi()%texture.get_height()+1, randi()%texture.get_width()+1))
		
	var delaunay_points = Geometry2D.triangulate_delaunay(points)
	
	if not delaunay_points:
		print("serious error occurred no delaunay points found")
	
	#loop over each returned triangle
	for index in len(delaunay_points) / 3:
		var shard_pool = PackedVector2Array()
		
		# loop over the three points in our triangle
		for n in range(3):
			shard_pool.append(points[delaunay_points[(index * 3) + n]])
		
		#create a new polygon to give these points to
		var shard = Polygon2D.new()
		shard.polygon = shard_pool
		shard.texture = texture
		shards.append(shard)
	return shards

func generate_squares():
	var shards = []
	# Get the size of the texture.
	var texture_size = texture.get_size()
	var width_divisions = sqrt(shard_count)
	var height_divisions = shard_count/width_divisions
	
	# Calculate the width and height of each rectangle.
	var rectangle_width = texture_size.x / width_divisions
	var rectangle_height = texture_size.y / height_divisions
	
	for w in range(width_divisions):
		for h in range(height_divisions):
			# Calculate the coordinates of the top-left and bottom-right corners of each rectangle.
			var top_left = Vector2(w * rectangle_width, h * rectangle_height)
			var bottom_right = Vector2((w + 1) * rectangle_width, (h + 1) * rectangle_height)
			
			var section_rectangle = PackedVector2Array()
			# Append the points of the rectangle to the result array.
			section_rectangle.append(top_left)
			section_rectangle.append(Vector2(bottom_right.x, top_left.y))
			section_rectangle.append(bottom_right)
			section_rectangle.append(Vector2(top_left.x, bottom_right.y))
			
			var shard = Polygon2D.new()
			shard.polygon = section_rectangle
			shard.texture = texture
			shards.append(shard)
	return shards

func reset():
	for child in get_children():
		child.queue_free()
	shard_velocity_map = {}
	shard_goal_pos_map = {}
	imploded_shards = []
	imploded = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#explode shard movement
	for child in shard_velocity_map.keys():
		child.scale *= shard_shrink_rate
		if(child.scale.x * child.scale.y < min_shard_size):
			shard_velocity_map.erase(child)
			child.queue_free()
		else:
			child.position -= shard_velocity_map[child] * delta * shard_speed
			child.rotation -= shard_velocity_map[child].x * delta * rotation_speed
			#apply gravity to the velocity map so the triangle falls
			shard_velocity_map[child].y -= delta * shard_gravity
	#implode shard movement
	elapsed_time += delta
	if shard_goal_pos_map.is_empty() and imploded:
		color.a = 1
		for child in imploded_shards:
			child.queue_free()
		imploded_shards = []
		imploded = false
		emit_signal("finished_imploding_signal")
	for child in shard_goal_pos_map.keys():
		if(child.position == Vector2(0.0,0.0)):
			shard_goal_pos_map.erase(child)
			imploded_shards.append(child)
			continue
		if invisible:
			child.position = lerp(child.position, Vector2(0,0), clamp(elapsed_time/time_to_form,0,1))
		else:
			child.position = lerp(child.position, Vector2(0,0), clamp(1-sqrt(1-(elapsed_time/time_to_form)*(elapsed_time/time_to_form)),0,1))

