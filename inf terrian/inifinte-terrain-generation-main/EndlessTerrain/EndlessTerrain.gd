extends Node3D

@export var chunkSize: int = 100
@export var terrain_height: float = 20.0
@export var view_distance: float = 500.0
@export var viewer: CharacterBody3D
@export var chunk_mesh_scene: PackedScene
@export var render_debug: bool = false

var viewer_position: Vector2 = Vector2()
var terrain_chunks: Dictionary = {}
var chunks_visible: int = 0
var last_visible_chunks: Array = []

@export var noise: FastNoiseLite

func _ready():
	# Set the total chunks to be visible
	noise.seed = randi()
	chunks_visible = int(round(view_distance / chunkSize))
	if render_debug:
		set_wireframe()
	update_visible_chunks()

func set_wireframe():
	RenderingServer.set_debug_generate_wireframes(true)
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME

func _process(delta: float) -> void:
	if viewer != null:
		viewer_position.x = viewer.global_position.x
		viewer_position.y = viewer.global_position.z
		update_visible_chunks()
	else:
		print("Viewer is null, skipping code")

func update_visible_chunks() -> void:
	# Hide chunks that are out of view
	# for chunk in last_visible_chunks:
	#    chunk.set_chunk_visible(false)
	# last_visible_chunks.clear()

	# Get grid position
	var current_x: int = int(round(viewer_position.x / chunkSize))
	var current_y: int = int(round(viewer_position.y / chunkSize))

	# Get all the chunks within visibility range
	for y_offset in range(-chunks_visible, chunks_visible):
		for x_offset in range(-chunks_visible, chunks_visible):
			# Create a new chunk coordinate
			var view_chunk_coord: Vector2 = Vector2(current_x - x_offset, current_y - y_offset)
			
			# Check if chunk already exists
			if terrain_chunks.has(view_chunk_coord):
				var chunk: TerrainChunk = terrain_chunks[view_chunk_coord]
				chunk.update_chunk(viewer_position, view_distance)
				if chunk.update_lod(viewer_position):
					chunk.generate_terrain(noise, view_chunk_coord, chunkSize, true)
			else:
				# If chunk doesn't exist, create chunk
				var chunk: TerrainChunk = chunk_mesh_scene.instantiate()
				add_child(chunk)
				chunk.Terrain_Max_Height = terrain_height
				var pos: Vector2 = view_chunk_coord * chunkSize
				var world_position: Vector3 = Vector3(pos.x, 0, pos.y)
				chunk.global_position = world_position
				chunk.generate_terrain(noise, view_chunk_coord, chunkSize, false)
				terrain_chunks[view_chunk_coord] = chunk

	# Check if we should remove chunks from the scene
	for chunk in get_children(): 
		# Make sure the chunk is an instance of the TerrainChunk type
		if chunk is TerrainChunk and chunk.should_remove(viewer_position, view_distance):
			chunk.queue_free()
			if terrain_chunks.has(chunk.grid_coord):
				terrain_chunks.erase(chunk.grid_coord)

func get_active_threads() -> int:
	# This version isn't using threading, so return 0
	return 0
