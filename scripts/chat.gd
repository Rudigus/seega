class_name Chat
extends PanelContainer

@onready var mensagens: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/Mensagens
@onready var campo_chat: LineEdit = $VBoxContainer/PanelContainer/CampoChat
@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer

func _on_campo_chat_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_submit") and campo_chat.text != "":
		var nova_mensagem = Label.new()
		nova_mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD
		nova_mensagem.text = "Você: %s" % campo_chat.text
		mensagens.add_child(nova_mensagem)

# Conserta bug de não poder continuar digitando após apertar enter
func _on_campo_chat_text_submitted(new_text: String) -> void:
	campo_chat.release_focus()
	campo_chat.grab_focus.call_deferred()
	get_tree().create_timer(.01).timeout.connect(
		func () -> void:
			scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	)
	GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.CHAT, new_text)
	campo_chat.text = ""

func adicionar_mensagem_oponente(_tipo, mensagem):
	var nova_mensagem = Label.new()
	nova_mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD
	nova_mensagem.text = "Oponente: %s" % mensagem
	mensagens.add_child(nova_mensagem)
