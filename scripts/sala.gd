extends PanelContainer

@onready var socket_servidor = TCPServer.new()
const INTERVALO_VERIFICAR_CONEXAO = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	socket_servidor.listen(GerenciadorConexao.DEFAULT_PORT)
	var timer = Timer.new()
	timer.wait_time = INTERVALO_VERIFICAR_CONEXAO
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(verificar_conexao)
	add_child(timer)

func verificar_conexao():
	if socket_servidor.is_connection_available():
		var socket = socket_servidor.take_connection()
		GerenciadorConexao.socket = socket
		get_tree().change_scene_to_file("res://cenas/partida.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	socket_servidor.stop()
	get_tree().change_scene_to_file("res://cenas/menu_principal.tscn")
