extends Node2D

@onready var tabuleiro: Tabuleiro = $Tabuleiro
@onready var chat: Chat = $HUD/Chat
@onready var painel_quem_comeca: PanelContainer = $HUD/PainelQuemComeca
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var jogador_escolhido = null

func _ready() -> void:
	tabuleiro.position = get_viewport_rect().size / 2 - tabuleiro.tamanho / 2
	tabuleiro.casa_selecionada.connect(tratar_casa_selecionada)
	GerenciadorConexao.mensagem_recebida.connect(tratar_mensagens_recebidas)

func tratar_casa_selecionada(posicao_casa):
	if not tabuleiro.existe_peca_em(posicao_casa):
		tabuleiro.adicionar_peca(posicao_casa, true)

func _on_botao_eu_pressed() -> void:
	jogador_escolhido = 0
	GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.QUEM_COMECA, 1)

func _on_botao_oponente_pressed() -> void:
	jogador_escolhido = 1
	GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.QUEM_COMECA, 0)

func tratar_mensagens_recebidas(tipo: GerenciadorConexao.TipoMensagem, mensagem):
	match tipo:
		GerenciadorConexao.TipoMensagem.QUEM_COMECA:
			if jogador_escolhido == mensagem:
				GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.QUEM_COMECA,
				1 - jogador_escolhido)
				comecar_jogo()
		GerenciadorConexao.TipoMensagem.CHAT:
			chat.adicionar_mensagem_oponente(tipo, mensagem)

func comecar_jogo():
	animation_player.stop()
	painel_quem_comeca.hide()
	
