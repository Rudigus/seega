extends Node2D

@onready var tabuleiro: Tabuleiro = $Tabuleiro
@onready var chat: Chat = $HUD/Chat
@onready var painel_quem_comeca: PanelContainer = $HUD/PainelQuemComeca
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var jogador_escolhido = null
var meu_turno: bool = false
var jogadas_restantes: int
var etapa_atual: int = -1

func _ready() -> void:
	tabuleiro.position = get_viewport_rect().size / 2 - tabuleiro.tamanho / 2
	tabuleiro.casa_selecionada.connect(tratar_casa_selecionada)
	GerenciadorConexao.mensagem_recebida.connect(tratar_mensagens_recebidas)

func tratar_casa_selecionada(posicao_casa):
	if not meu_turno or jogadas_restantes == 0:
		return
	if not tabuleiro.existe_peca_em(posicao_casa) and posicao_casa != Vector2(2, 2):
		tabuleiro.adicionar_peca(posicao_casa, true)
		GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.COLOCA_PECA, posicao_casa)
		jogadas_restantes -= 1
		if jogadas_restantes == 0:
			finalizar_turno()

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
				print(etapa_atual)
				if etapa_atual == -1:
					# Para garantir que o outro também tenha o jogo iniciado
					GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.QUEM_COMECA,
					1 - jogador_escolhido)
					comecar_jogo()
		GerenciadorConexao.TipoMensagem.COLOCA_PECA:
			tabuleiro.adicionar_peca(mensagem, false)
		GerenciadorConexao.TipoMensagem.FINALIZOU_TURNO:
			iniciar_turno()
		GerenciadorConexao.TipoMensagem.CHAT:
			chat.adicionar_mensagem_oponente(tipo, mensagem)

func comecar_jogo():
	animation_player.stop()
	painel_quem_comeca.hide()
	etapa_atual = 0
	if jogador_escolhido == 0:
		iniciar_turno()

func iniciar_turno():
	meu_turno = true
	if etapa_atual == 0:
		jogadas_restantes = 2
	else:
		jogadas_restantes = 1

func finalizar_turno():
	meu_turno = false
	GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.FINALIZOU_TURNO, null)
