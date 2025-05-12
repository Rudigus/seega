extends Node2D

@onready var tabuleiro: Tabuleiro = $Tabuleiro

func _ready() -> void:
	tabuleiro.position = get_viewport_rect().size / 2 - tabuleiro.tamanho / 2
	tabuleiro.casa_selecionada.connect(tratar_casa_selecionada)

func tratar_casa_selecionada(posicao_casa):
	if not tabuleiro.existe_peca_em(posicao_casa):
		tabuleiro.adicionar_peca(posicao_casa, true)
