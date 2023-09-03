extends Polygon2D

class_name explodeablePolygon

@export var shard_count = 32
@export var shard_shrink_rate: float = 0.95  # Adjust this for shard lifetime
@export var min_shard_size: float = 0.1  # Adjust this for the minimum shard size (area)
@export var x_init_velocity: int
@export var y_init_velocity: int
@export var shard_speed: float
@export var rotation_speed: float
@export var shard_gravity: float
var shard_velocity_map = {}

@export var x_max_distance: int
@export var x_min_distance: int
@export var y_max_distance: int
@export var y_min_distance: int
@export var time_to_form: float
var shard_goal_pos_map = {}
var elapsed_time: float = 0.0
var imploded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func explode():
	#this will let us add more points to our polygon later on
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
		shard.position = Vector2(x_max_distance, y_max_distance)
		shard_velocity_map[shard] = Vector2(randi_range(-x_init_velocity,x_init_velocity), randi()%y_init_velocity)
		add_child(shard)
		
	#make original polygon invisible
	color.a = 0
		
func implode():
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
		shard.position = Vector2(randi_range(x_min_distance, x_max_distance), randi_range(y_min_distance, y_max_distance))
		shard_goal_pos_map[shard] = shard.position
		add_child(shard)
		
	#make original polygon invisible
	#color.a = 0
	elapsed_time = 0.0
	imploded = true
	
func reset():
	for child in get_children():
		child.queue_free()
	shard_velocity_map = {}
	shard_goal_pos_map = {}

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
		for child in get_children():
			child.queue_free()
		imploded = false
	for child in shard_goal_pos_map.keys():
		if(child.position == Vector2(0.0,0.0)):
			shard_goal_pos_map.erase(child)
		child.position = lerp(child.position, Vector2(0,0), clamp(elapsed_time/time_to_form,0,1))
