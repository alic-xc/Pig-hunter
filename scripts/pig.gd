class_name Pig
extends Area3D

signal defeated(pig: Pig, reward: int)
signal reached_hunter(pig: Pig, damage: int)

var speed := 5.0
var health := 40.0
var max_health := 40.0
var reward := 5
var contact_damage := 10
var target: Node3D
var variant := "runner"
var _alive := true
var _bob_time := 0.0
var _body: Node3D
var _health_fill: MeshInstance3D

func setup(kind: String, chase_target: Node3D, body_material: Material) -> void:
	variant = kind
	target = chase_target
	match variant:
		"brute":
			speed = 3.3
			health = 95.0
			reward = 14
			contact_damage = 20
		"sprinter":
			speed = 7.4
			health = 25.0
			reward = 8
			contact_damage = 8
		_:
			speed = 5.0
			health = 42.0
			reward = 5
			contact_damage = 10
	max_health = health
	build_visual(body_material)

func build_visual(body_material: Material) -> void:
	_body = Node3D.new()
	add_child(_body)

	var scale_factor := 1.0 if variant == "runner" else (1.38 if variant == "brute" else 0.78)
	var torso := MeshInstance3D.new()
	var torso_mesh := SphereMesh.new()
	torso_mesh.radius = 0.72 * scale_factor
	torso_mesh.height = 1.2 * scale_factor
	torso.mesh = torso_mesh
	torso.material_override = body_material
	torso.rotation_degrees.x = 90.0
	torso.position.y = 0.72 * scale_factor
	_body.add_child(torso)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.52 * scale_factor
	head_mesh.height = 0.85 * scale_factor
	head.mesh = head_mesh
	head.material_override = body_material
	head.position = Vector3(0, 0.82 * scale_factor, -0.72 * scale_factor)
	_body.add_child(head)

	var snout_mat := StandardMaterial3D.new()
	snout_mat.albedo_color = Color("#ffb0aa")
	var snout := MeshInstance3D.new()
	var snout_mesh := CylinderMesh.new()
	snout_mesh.top_radius = 0.29 * scale_factor
	snout_mesh.bottom_radius = 0.34 * scale_factor
	snout_mesh.height = 0.32 * scale_factor
	snout.mesh = snout_mesh
	snout.material_override = snout_mat
	snout.rotation_degrees.x = 90.0
	snout.position = Vector3(0, 0.78 * scale_factor, -1.12 * scale_factor)
	_body.add_child(snout)

	var dark_mat := StandardMaterial3D.new()
	dark_mat.albedo_color = Color("#321d2c")
	for side in [-1.0, 1.0]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.075 * scale_factor
		eye_mesh.height = 0.15 * scale_factor
		eye.mesh = eye_mesh
		eye.material_override = dark_mat
		eye.position = Vector3(0.22 * side * scale_factor, 1.02 * scale_factor, -1.02 * scale_factor)
		_body.add_child(eye)

	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.82 * scale_factor
	collision.shape = shape
	collision.position.y = 0.7 * scale_factor
	add_child(collision)

	var bar_back := MeshInstance3D.new()
	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(1.45 * scale_factor, 0.08, 0.08)
	bar_back.mesh = back_mesh
	var back_mat := StandardMaterial3D.new()
	back_mat.albedo_color = Color("#2c2430")
	bar_back.material_override = back_mat
	bar_back.position = Vector3(0, 1.75 * scale_factor, 0)
	add_child(bar_back)

	_health_fill = MeshInstance3D.new()
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(1.36 * scale_factor, 0.09, 0.1)
	_health_fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color("#f6d255")
	fill_mat.emission_enabled = true
	fill_mat.emission = Color("#6b4614")
	_health_fill.material_override = fill_mat
	_health_fill.position = Vector3(0, 1.76 * scale_factor, -0.01)
	add_child(_health_fill)

func _physics_process(delta: float) -> void:
	if not _alive or not is_instance_valid(target):
		return
	_bob_time += delta * speed
	_body.position.y = sin(_bob_time * 2.1) * 0.08
	_body.rotation.z = sin(_bob_time) * 0.05
	var direction := target.global_position - global_position
	direction.y = 0.0
	if direction.length() < 1.45:
		_alive = false
		reached_hunter.emit(self, contact_damage)
		queue_free()
		return
	global_position += direction.normalized() * speed * delta
	look_at(global_position + direction.normalized(), Vector3.UP)

func take_damage(amount: float) -> void:
	if not _alive:
		return
	health -= amount
	var ratio := clampf(health / max_health, 0.0, 1.0)
	# A truly zero scale produces a singular transform in Godot. Keep the empty
	# bar imperceptibly thin instead, then remove the pig at the end of the tween.
	_health_fill.scale.x = maxf(ratio, 0.001)
	_health_fill.position.x = -(1.0 - ratio) * 0.68
	var punch := create_tween()
	punch.tween_property(_body, "scale", Vector3.ONE * 1.18, 0.05)
	punch.tween_property(_body, "scale", Vector3.ONE, 0.08)
	if health <= 0.0:
		_alive = false
		defeated.emit(self, reward)
		var exit := create_tween()
		exit.set_parallel(true)
		exit.tween_property(self, "scale", Vector3.ONE * 0.01, 0.18)
		exit.tween_property(self, "position:y", position.y + 1.4, 0.18)
		exit.chain().tween_callback(queue_free)
