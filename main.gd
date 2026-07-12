extends Node

@onready var day_bg : Sprite2D = $BackgroundDay
@onready var night_bg : Sprite2D = $BackgroundNight

@export var tower_scene: PackedScene

var game_running: bool
var game_over: bool
var score
var scroll
const SCROLL_SPEED = 8
var screen_size: Vector2i
var ground_height: int
var towers: Array
var is_night: bool = false
var last_toggled_score : int = -1
const TOWER_DELAY: int = 150
const TOWER_RANGE: int = 320


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game() 
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	screen_size = get_window().size

func new_game():
	#get_tree().call_group("towers_group", "queue_free")
	for tower in get_tree().get_nodes_in_group("towers"):
		tower.queue_free()
	
	$Message.text = 'Press "Space" to Play'
	game_running = false
	game_over = false
	score = 0
	update_score(score)
	scroll = 0
	
	is_night = false
	last_toggled_score = -1
	day_bg.modulate.a = 1.0
	night_bg.modulate.a = 0.0
	
	towers.clear()
	
	$Bird.reset()


func _input(Event):
	if game_over == false:
		if Input.is_action_pressed("jump"):
			if game_running == false:
				start_game()
			else:
				if $Bird.flying:
					$Bird.flap()
					$Flap.play()
					check_top()
	else:
		if Input.is_action_just_pressed("jump"):
			new_game()

func start_game():
	$Start.play()
	$Message.hide()
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$TowerTimer.start()
	
func _process(delta: float) -> void:
	if game_running:
		scroll += SCROLL_SPEED
		
		if scroll >= screen_size.x:
			scroll = 0
		
		$Ground.position.x = -scroll
		
		for tower in towers:
			tower.position.x -= SCROLL_SPEED


func _on_tower_timer_timeout() -> void:
	generate_towers()

func generate_towers():
	var tower = tower_scene.instantiate()
	tower.position.x = screen_size.x + TOWER_DELAY
	tower.position.y = (screen_size.y - ground_height * 2) / 2 + randi_range(-TOWER_RANGE, TOWER_RANGE)
	tower.scored.connect(scored)
	tower.hit.connect(bird_hit)
	add_child(tower)
	towers.append(tower)
	
func scored():
	score += 1
	if score % 7 == 0 and last_toggled_score != score:
		last_toggled_score = score
		toggle_background()
	$Point.play()
	update_score(score)

func toggle_background():
	is_night = !is_night
	
	var fade_in_target: Sprite2D = night_bg if is_night else day_bg
	var fade_out_target: Sprite2D = day_bg if is_night else night_bg
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(fade_in_target, "modulate:a", 1.0, 0.8)
	tween.tween_property(fade_out_target, "modulate:a", 0.0, 0.8)

func bird_hit():
	$Bird.falling = true
	$Hit.play()
	stop_game()


func check_top():
	if $Bird.position.y < 0:
		$Hit.play()
		$Bird.falling = true
		stop_game()
		
func stop_game():
	$TowerTimer.stop()
	$Bird.flying = false
	game_running = false
	game_over = true
	
	$Message.text = 'Press "Space" to Restart'
	
	$RestartTimer.start()
	await $RestartTimer.timeout
	
	$Message.show()
	
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_ground_hit() -> void:
	$Bird.falling = false
	$Die.play()
	
	stop_game()
