extends PanelContainer

@onready var menu = $MarginContainer/CenterContainer/Menu
@onready var modal_entrada_sala = $MarginContainer/CenterContainer/ModalEntradaSala
@onready var campo_endereco = $MarginContainer/CenterContainer/ModalEntradaSala/MarginContainer/VBoxContainer/CampoEndereco

func _on_botao_criar_sala_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/sala.tscn")

func _on_botao_entrar_sala_pressed() -> void:
	menu.visible = false
	modal_entrada_sala.visible = true

func _on_botao_conectar_pressed() -> void:
	var socket = StreamPeerTCP.new()
	var error = socket.connect_to_host(campo_endereco.text, GerenciadorConexao.DEFAULT_PORT)
	var state = socket.get_status()
	while state == StreamPeerTCP.STATUS_CONNECTING:
		state = socket.get_status()
		socket.poll()
	if error == OK:
		GerenciadorConexao.habilitar_recebimento_mensagens(socket)
		get_tree().change_scene_to_file("res://cenas/partida.tscn")
	else:
		print("Erro de conexão. Descrição: %s" % error_string(error))
		var dialog = AcceptDialog.new()
		dialog.title = "Erro de conexão"
		dialog.dialog_text = "Não foi possível se conectar"
		add_child(dialog)
		dialog.popup_centered()

func _on_botao_cancelar_pressed() -> void:
	modal_entrada_sala.visible = false
	menu.visible = true
