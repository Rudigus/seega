extends PanelContainer

@onready var socket_servidor = TCPServer.new()
const INTERVALO_VERIFICAR_CONEXAO = 1

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
		GerenciadorConexao.habilitar_recebimento_mensagens(socket)
		get_tree().change_scene_to_file("res://cenas/partida.tscn")

func _on_button_pressed() -> void:
	socket_servidor.stop()
	get_tree().change_scene_to_file("res://cenas/menu_principal.tscn")
