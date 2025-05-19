extends Node2D

@onready var tabuleiro: Tabuleiro = $Tabuleiro
@onready var chat: Chat = $HUD/Chat
@onready var painel_quem_comeca: PanelContainer = $HUD/PainelQuemComeca
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rotulo_etapa: Label = $HUD/RotuloEtapa
@onready var rotulo_jogador: Label = $HUD/RotuloJogador
@onready var mensagem_final: Label = $HUD/PainelFinal/MarginContainer/VBoxContainer/MensagemFinal
@onready var painel_final: PanelContainer = $HUD/PainelFinal

const STRING_SEU_TURNO = "Seu Turno"
const STRING_TURNO_OPONENTE = "Turno do Oponente"
const STRING_VENCEDOR = "Parabéns, você venceu!!!"
const STRING_PERDEDOR = "Que pena, não foi dessa vez!"

var jogador_escolhido = null
var meu_turno: bool = false
var jogadas_restantes: int
var etapa_atual: int = -1
var posicao_peca_selecionada = null

func _ready() -> void:
	tabuleiro.position = get_viewport_rect().size / 2 - tabuleiro.tamanho / 2
	tabuleiro.casa_selecionada.connect(tratar_casa_selecionada)
	GerenciadorConexao.mensagem_recebida.connect(tratar_mensagens_recebidas)

func tratar_casa_selecionada(posicao_casa):
	if not meu_turno or jogadas_restantes == 0:
		return
	if etapa_atual == 0:
		if not tabuleiro.existe_peca_em(posicao_casa) and posicao_casa != tabuleiro.POSICAO_PECA_MEIO:
			tabuleiro.adicionar_peca(posicao_casa, true)
			GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.COLOCA_PECA, posicao_casa)
			jogadas_restantes -= 1
			if jogadas_restantes == 0:
				finalizar_turno()
	else:
		if tabuleiro.existe_peca_jogador_local_em(posicao_casa):
			posicao_peca_selecionada = posicao_casa
		elif tabuleiro.existe_peca_em(posicao_casa):
			posicao_peca_selecionada = null
		if tabuleiro.pode_mover_peca(posicao_peca_selecionada, posicao_casa):
			tabuleiro.mover_peca(posicao_peca_selecionada, posicao_casa, true)
			GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.MOVE_PECA, \
			[posicao_peca_selecionada, posicao_casa])
			posicao_peca_selecionada = null
			var posicao_peca_capturavel = tabuleiro.peca_capturavel_por(posicao_casa)
			if posicao_peca_capturavel != null:
				tabuleiro.capturar_peca(posicao_peca_capturavel, true)
				GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.CAPTURA_PECA, 
				posicao_peca_capturavel)
				if tabuleiro.quantidade_pecas(false) == 1:
					var vencedor = 0
					GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.FINALIZA_PARTIDA, 1)
					finalizar_partida(vencedor)
			else:
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
				if etapa_atual == -1:
					# Para garantir que o outro também tenha o jogo iniciado
					GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.QUEM_COMECA,
					1 - jogador_escolhido)
					comecar_jogo()
		GerenciadorConexao.TipoMensagem.COLOCA_PECA:
			tabuleiro.adicionar_peca(mensagem, false)
		GerenciadorConexao.TipoMensagem.MOVE_PECA:
			tabuleiro.mover_peca(mensagem[0], mensagem[1], false)
		GerenciadorConexao.TipoMensagem.CAPTURA_PECA:
			tabuleiro.capturar_peca(mensagem, false)
		GerenciadorConexao.TipoMensagem.FINALIZA_TURNO:
			iniciar_turno()
		GerenciadorConexao.TipoMensagem.PROXIMA_ETAPA:
			iniciar_proxima_etapa()
		GerenciadorConexao.TipoMensagem.FINALIZA_PARTIDA:
			finalizar_partida(mensagem)
		GerenciadorConexao.TipoMensagem.CHAT:
			chat.adicionar_mensagem_oponente(tipo, mensagem)

func comecar_jogo():
	animation_player.stop()
	painel_quem_comeca.hide()
	etapa_atual = 0
	rotulo_etapa.show()
	rotulo_jogador.show()
	if jogador_escolhido == 0:
		iniciar_turno()

func iniciar_turno():
	meu_turno = true
	rotulo_jogador.text = STRING_SEU_TURNO
	if etapa_atual == 0:
		jogadas_restantes = 2
	else:
		jogadas_restantes = 1

func finalizar_turno():
	meu_turno = false
	if etapa_atual == 0 && tabuleiro.quantidade_pecas(true) == 12 && \
	tabuleiro.quantidade_pecas(false) == 12:
		GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.PROXIMA_ETAPA, null)
		iniciar_proxima_etapa()
		iniciar_turno()
	else:
		get_tree().create_timer(0.5).timeout.connect(func(): rotulo_jogador.text = STRING_TURNO_OPONENTE)
		GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.FINALIZA_TURNO, null)

func iniciar_proxima_etapa():
	etapa_atual = 1
	rotulo_etapa.text = "Etapa 2"

func _on_botao_desistir_pressed() -> void:
	var vencedor = 1
	GerenciadorConexao.enviar_mensagem(GerenciadorConexao.TipoMensagem.FINALIZA_PARTIDA, 0)
	finalizar_partida(vencedor)

func finalizar_partida(vencedor: int):
	painel_final.show()
	if vencedor == 0:
		mensagem_final.text = STRING_VENCEDOR
	else:
		mensagem_final.text = STRING_PERDEDOR

func _on_voltar_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu_principal.tscn")
