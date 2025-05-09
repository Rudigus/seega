extends PanelContainer

@onready var menu = $MarginContainer/CenterContainer/Menu
@onready var modal_entrada_sala = $MarginContainer/CenterContainer/ModalEntradaSala
@onready var campo_endereco = $MarginContainer/CenterContainer/ModalEntradaSala/MarginContainer/VBoxContainer/CampoEndereco

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_botao_criar_sala_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/sala.tscn")

func _on_botao_entrar_sala_pressed() -> void:
	menu.visible = false
	modal_entrada_sala.visible = true

func _on_botao_conectar_pressed() -> void:
	var socket = StreamPeerTCP.new()
	GerenciadorConexao.socket = socket
	var error = socket.connect_to_host(campo_endereco.text, GerenciadorConexao.DEFAULT_PORT)
	if error == OK:
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
