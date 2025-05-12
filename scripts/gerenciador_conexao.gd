extends Node

signal mensagem_recebida(tipo: TipoMensagem, mensagem: String)

enum TipoMensagem {
	QUEM_INICIA,
	COLOCA_PECA,
	MOVE_PECA,
	CHAT
}

const DEFAULT_PORT = 3457
var socket: StreamPeerTCP

func habilitar_recebimento_mensagens(s: StreamPeerTCP):
	socket = s
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.timeout.connect(receber_mensagens)
	timer.start()

func enviar_mensagem(tipo: TipoMensagem, mensagem: String):
	socket.put_u8(tipo)
	socket.put_string(mensagem)

func receber_mensagens():
	if socket.get_available_bytes() > 0:
		var tipo = socket.get_u8()
		var mensagem = socket.get_string()
		mensagem_recebida.emit(tipo, mensagem)
