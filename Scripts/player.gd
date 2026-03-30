extends CharacterBody3D

var SPEED: float = 5.0
const MOUSE_SENSITIVITY: float = 0.003

const orginal_stamina: float = 20.0
var stamina: float = orginal_stamina
var sprinting: bool = false

@onready var camera := $PlayerCamera

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("sprint"):
		if sprinting == true:
			sprinting = false
		elif sprinting == false:
			sprinting = true
	
	if sprinting:
		if stamina < 0.0:
			sprinting = false
		stamina -= 0.1
		SPEED = 10.0
	elif !sprinting:
		if stamina < orginal_stamina:
			stamina += 0.05
		SPEED = 5.0
	
	print(stamina)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

# DEBUG CODE
func _init():
	RenderingServer.set_debug_generate_wireframes(true)

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_SEMICOLON):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1) % 5
