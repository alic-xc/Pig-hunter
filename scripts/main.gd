extends Node3D

const PigScene := preload("res://scripts/pig.gd")

const FIELD_WIDTH := 20.0
const SEGMENT_LENGTH := 18.0
const SEGMENT_COUNT := 5
const PLAYER_SPEED := 8.5
const BASE_WORLD_SPEED := 8.0

var horse: Node3D
var dog: Node3D
var world_segments: Array[Node3D] = []
var pigs: Array[Pig] = []
var rng := RandomNumberGenerator.new()

var score := 0
var coins := 0
var health := 100
var wave := 1
var wave_progress := 0.0
var run_time := 0.0
var fire_cooldown := 0.0
var dog_cooldown := 0.0
var spawn_cooldown := 0.0
var game_over := false

var score_label: Label
var coins_label: Label
var wave_label: Label
var timer_label: Label
var health_bar: ProgressBar
var wave_bar: ProgressBar
var message_label: Label

var mat_grass: StandardMaterial3D
var mat_path: StandardMaterial3D
var mat_path_edge: StandardMaterial3D
var mat_dark: StandardMaterial3D
var mat_leather: StandardMaterial3D
var mat_horse: StandardMaterial3D
var mat_hunter: StandardMaterial3D
var mat_pig: StandardMaterial3D
var mat_dog: StandardMaterial3D
var mat_gold: StandardMaterial3D
var mat_white: StandardMaterial3D

func _ready() -> void:
	rng.randomize()
	create_materials()
	create_environment()
	create_world()
	create_horse_and_hunter()
	create_dog()
	create_ui()
	spawn_cooldown = 0.8

func material(color: Color, roughness := 0.82, emission := Color.BLACK) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	if emission != Color.BLACK:
		result.emission_enabled = true
		result.emission = emission
	return result

func create_materials() -> void:
	mat_grass = material(Color("#567b61"))
	mat_path = material(Color("#c9975d"))
	mat_path_edge = material(Color("#e4c078"))
	mat_dark = material(Color("#25212a"))
	mat_leather = material(Color("#704735"))
	mat_horse = material(Color("#9e6848"))
	mat_hunter = material(Color("#3f6f68"))
	mat_pig = material(Color("#df7f91"))
	mat_dog = material(Color("#d39a4c"))
	mat_gold = material(Color("#f4d94e"), 0.45, Color("#6a4c08"))
	mat_white = material(Color("#f5e8cf"))

func create_environment() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#3b6658")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d8edce")
	env.ambient_light_energy = 0.72
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_color = Color("#fff0c8")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 25.0
	camera.position = Vector3(15.5, 19.0, 16.5)
	camera.look_at_from_position(camera.position, Vector3(0, 0, -1.5), Vector3.UP)
	add_child(camera)

func mesh_box(parent: Node, size: Vector3, position: Vector3, mesh_material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	instance.mesh = box
	instance.material_override = mesh_material
	instance.position = position
	parent.add_child(instance)
	return instance

func mesh_sphere(parent: Node, radius: float, position: Vector3, mesh_material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	instance.mesh = sphere
	instance.material_override = mesh_material
	instance.position = position
	parent.add_child(instance)
	return instance

func mesh_cylinder(parent: Node, radius: float, height: float, position: Vector3, mesh_material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	instance.mesh = cylinder
	instance.material_override = mesh_material
	instance.position = position
	parent.add_child(instance)
	return instance

func create_world() -> void:
	for index in SEGMENT_COUNT:
		var segment := Node3D.new()
		segment.position.z = -SEGMENT_LENGTH * 2.0 + index * SEGMENT_LENGTH
		add_child(segment)
		world_segments.append(segment)
		mesh_box(segment, Vector3(FIELD_WIDTH, 0.25, SEGMENT_LENGTH), Vector3(0, -0.22, 0), mat_grass)
		mesh_box(segment, Vector3(5.2, 0.18, SEGMENT_LENGTH), Vector3(0, -0.05, 0), mat_path)
		mesh_box(segment, Vector3(0.26, 0.15, SEGMENT_LENGTH), Vector3(-2.72, 0.02, 0), mat_path_edge)
		mesh_box(segment, Vector3(0.26, 0.15, SEGMENT_LENGTH), Vector3(2.72, 0.02, 0), mat_path_edge)
		for detail_index in 14:
			var side := -1.0 if detail_index % 2 == 0 else 1.0
			var x := side * rng.randf_range(3.5, 9.5)
			var z := rng.randf_range(-8.5, 8.5)
			var streak := mesh_box(segment, Vector3(rng.randf_range(0.04, 0.09), 0.02, rng.randf_range(0.9, 2.4)), Vector3(x, 0.01, z), mat_white)
			streak.rotation.y = rng.randf_range(-0.08, 0.08)

func create_horse_and_hunter() -> void:
	horse = Node3D.new()
	horse.name = "HorseAndHunter"
	horse.position = Vector3(0, 0, 3.0)
	add_child(horse)

	var body := mesh_sphere(horse, 0.72, Vector3(0, 0.92, 0.15), mat_horse)
	body.scale = Vector3(0.9, 0.85, 1.55)
	var neck := mesh_cylinder(horse, 0.27, 1.1, Vector3(0, 1.35, -0.72), mat_horse)
	neck.rotation_degrees.x = -28.0
	var head := mesh_sphere(horse, 0.35, Vector3(0, 1.77, -1.04), mat_horse)
	head.scale = Vector3(0.8, 0.82, 1.25)
	for x in [-0.38, 0.38]:
		for z in [-0.35, 0.48]:
			mesh_cylinder(horse, 0.095, 1.15, Vector3(x, 0.42, z), mat_dark)
	mesh_box(horse, Vector3(0.9, 0.12, 0.9), Vector3(0, 1.52, 0.2), mat_leather)

	var rider_body := mesh_cylinder(horse, 0.28, 0.92, Vector3(0, 2.08, 0.18), mat_hunter)
	var rider_head := mesh_sphere(horse, 0.27, Vector3(0, 2.72, 0.15), mat_leather)
	mesh_cylinder(horse, 0.32, 0.12, Vector3(0, 2.95, 0.15), mat_dark)
	mesh_box(horse, Vector3(0.12, 0.12, 1.55), Vector3(0.45, 2.25, -0.42), mat_dark).rotation_degrees.x = -12.0
	mesh_cylinder(horse, 0.16, 0.5, Vector3(0.43, 2.23, -1.2), mat_dark).rotation_degrees.x = 90.0
	# Silence unused warnings while keeping named pieces readable in the scene tree.
	body.name = "HorseBody"
	neck.name = "HorseNeck"
	head.name = "HorseHead"
	rider_body.name = "HunterBody"
	rider_head.name = "HunterHead"

func create_dog() -> void:
	dog = Node3D.new()
	dog.name = "CompanionDog"
	dog.position = Vector3(-2.3, 0, 3.8)
	add_child(dog)
	var body := mesh_sphere(dog, 0.35, Vector3(0, 0.48, 0), mat_dog)
	body.scale = Vector3(0.85, 0.75, 1.45)
	mesh_sphere(dog, 0.27, Vector3(0, 0.67, -0.48), mat_dog)
	for x in [-0.2, 0.2]:
		for z in [-0.18, 0.3]:
			mesh_cylinder(dog, 0.055, 0.55, Vector3(x, 0.22, z), mat_dark)
	var tail := mesh_cylinder(dog, 0.055, 0.65, Vector3(0, 0.65, 0.62), mat_dog)
	tail.rotation_degrees.x = 58.0

func ui_label(parent: Node, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#fff4d6"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var top_panel := ColorRect.new()
	top_panel.color = Color("#282530e6")
	top_panel.position = Vector2(390, 20)
	top_panel.size = Vector2(500, 92)
	layer.add_child(top_panel)

	wave_label = ui_label(top_panel, "WAVE 1", 24)
	wave_label.position = Vector2(20, 10)
	timer_label = ui_label(top_panel, "0:00", 24)
	timer_label.position = Vector2(405, 10)
	wave_bar = ProgressBar.new()
	wave_bar.position = Vector2(20, 52)
	wave_bar.size = Vector2(460, 20)
	wave_bar.max_value = 100
	wave_bar.show_percentage = false
	top_panel.add_child(wave_bar)

	var stats := ColorRect.new()
	stats.color = Color("#282530e6")
	stats.position = Vector2(1010, 20)
	stats.size = Vector2(245, 92)
	layer.add_child(stats)
	score_label = ui_label(stats, "SCORE 0", 20)
	score_label.position = Vector2(15, 8)
	coins_label = ui_label(stats, "COINS 0", 20)
	coins_label.position = Vector2(15, 45)

	var health_panel := ColorRect.new()
	health_panel.color = Color("#282530e6")
	health_panel.position = Vector2(25, 20)
	health_panel.size = Vector2(280, 70)
	layer.add_child(health_panel)
	var health_label := ui_label(health_panel, "HORSE", 18)
	health_label.position = Vector2(12, 6)
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(12, 34)
	health_bar.size = Vector2(256, 20)
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	health_panel.add_child(health_bar)

	var help := ui_label(layer, "A / D  or  ← / →   STEER     •     AUTO-FIRE     •     DOG AUTO-ATTACKS", 19)
	help.position = Vector2(30, 670)
	message_label = ui_label(layer, "", 46)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.position = Vector2(315, 280)
	message_label.size = Vector2(650, 170)

func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		return

	run_time += delta
	wave_progress += delta
	fire_cooldown -= delta
	dog_cooldown -= delta
	spawn_cooldown -= delta

	var input_axis := Input.get_axis("move_left", "move_right")
	horse.position.x = move_toward(horse.position.x, clampf(horse.position.x + input_axis * PLAYER_SPEED * delta, -6.5, 6.5), PLAYER_SPEED * delta)
	dog.position.x = lerpf(dog.position.x, horse.position.x - 2.0, delta * 4.0)
	dog.position.z = lerpf(dog.position.z, horse.position.z + 0.75, delta * 3.0)
	dog.rotation.z = sin(run_time * 11.0) * 0.08
	horse.position.y = sin(run_time * 8.0) * 0.055
	horse.rotation.z = lerpf(horse.rotation.z, -input_axis * 0.12, delta * 6.0)

	var world_speed := BASE_WORLD_SPEED + minf(7.0, run_time * 0.045)
	for segment in world_segments:
		segment.position.z += world_speed * delta
		if segment.position.z > SEGMENT_LENGTH * 2.5:
			segment.position.z -= SEGMENT_LENGTH * SEGMENT_COUNT

	if wave_progress >= 24.0:
		wave += 1
		wave_progress = 0.0
		show_banner("WAVE %d" % wave)
	if spawn_cooldown <= 0.0:
		spawn_pig()
		spawn_cooldown = maxf(0.32, 1.35 - wave * 0.08) * rng.randf_range(0.72, 1.2)

	clean_pig_list()
	if fire_cooldown <= 0.0 and not pigs.is_empty():
		var target := nearest_pig(horse.global_position, 22.0)
		if target:
			shoot_target(target, 28.0, Color("#f9e55b"), horse.global_position + Vector3(0.45, 2.25, -1.25))
			fire_cooldown = maxf(0.15, 0.46 - wave * 0.012)
	if dog_cooldown <= 0.0 and not pigs.is_empty():
		var dog_target := nearest_pig(dog.global_position, 7.5)
		if dog_target:
			shoot_target(dog_target, 18.0, Color("#65d7ff"), dog.global_position + Vector3(0, 0.7, -0.4))
			dog_cooldown = 0.82

	update_ui()

func spawn_pig() -> void:
	var pig := PigScene.new() as Pig
	var roll := rng.randf()
	var kind := "runner"
	if wave >= 3 and roll < 0.18:
		kind = "brute"
	elif wave >= 2 and roll < 0.42:
		kind = "sprinter"
	pig.position = Vector3(rng.randf_range(-9.0, 9.0), 0, rng.randf_range(-22.0, -16.0))
	pig.setup(kind, horse, mat_pig)
	pig.defeated.connect(on_pig_defeated)
	pig.reached_hunter.connect(on_pig_reached_hunter)
	add_child(pig)
	pigs.append(pig)

func clean_pig_list() -> void:
	var living: Array[Pig] = []
	for pig in pigs:
		if is_instance_valid(pig) and not pig.is_queued_for_deletion():
			living.append(pig)
	pigs = living

func nearest_pig(origin: Vector3, maximum_range: float) -> Pig:
	var closest: Pig
	var closest_distance := maximum_range
	for pig in pigs:
		if not is_instance_valid(pig):
			continue
		var distance := origin.distance_to(pig.global_position)
		if distance < closest_distance:
			closest = pig
			closest_distance = distance
	return closest

func shoot_target(target: Pig, damage: float, color: Color, origin: Vector3) -> void:
	if not is_instance_valid(target):
		return
	create_tracer(origin, target.global_position + Vector3.UP * 0.8, color)
	target.take_damage(damage)
	spawn_damage_number(target.global_position + Vector3.UP * 1.8, int(damage), color)

func create_tracer(from: Vector3, to: Vector3, color: Color) -> void:
	var tracer := MeshInstance3D.new()
	var mesh := ImmediateMesh.new()
	var tracer_material := StandardMaterial3D.new()
	tracer_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tracer_material.albedo_color = color
	tracer_material.emission_enabled = true
	tracer_material.emission = color
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, tracer_material)
	mesh.surface_add_vertex(from)
	mesh.surface_add_vertex(to)
	mesh.surface_end()
	tracer.mesh = mesh
	add_child(tracer)
	var tween := create_tween()
	tween.tween_interval(0.07)
	tween.tween_callback(tracer.queue_free)

func spawn_damage_number(world_position: Vector3, amount: int, color: Color) -> void:
	var label := Label3D.new()
	label.text = str(amount)
	label.font_size = 42
	label.modulate = color
	label.outline_size = 8
	label.position = world_position
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", world_position.y + 1.5, 0.55)
	tween.tween_property(label, "modulate:a", 0.0, 0.55)
	tween.chain().tween_callback(label.queue_free)

func on_pig_defeated(_pig: Pig, reward: int) -> void:
	score += reward * 10
	coins += reward

func on_pig_reached_hunter(_pig: Pig, damage: int) -> void:
	health = maxi(0, health - damage)
	show_banner("-%d HORSE HEALTH" % damage, 0.65)
	if health <= 0:
		game_over = true
		message_label.text = "RUN OVER\nSCORE %d\nPRESS R OR SPACE TO RIDE AGAIN" % score

func update_ui() -> void:
	score_label.text = "SCORE  %06d" % score
	coins_label.text = "COINS  %04d" % coins
	wave_label.text = "WAVE %d" % wave
	timer_label.text = "%d:%02d" % [int(run_time) / 60, int(run_time) % 60]
	health_bar.value = health
	wave_bar.value = wave_progress / 24.0 * 100.0

func show_banner(text: String, duration := 1.0) -> void:
	message_label.text = text
	message_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(duration)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func():
		if not game_over:
			message_label.text = ""
			message_label.modulate.a = 1.0
	)

