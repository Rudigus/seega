class_name Tabuleiro
extends Node2D

signal casa_selecionada(posicao_casa)

const NUMERO_LINHAS = 5
const NUMERO_COLUNAS = 5
const COR_JOGADOR_LOCAL = Color.RED
const COR_OPONENTE = Color.BLUE

var tamanho: Vector2
var tamanho_casa: Vector2

var bitboard_jogador_local: int = 0
var bitboard_oponente: int = 0

const CenaCasa = preload("res://cenas/casa.tscn")
const CenaPeca = preload("res://cenas/peca.tscn")

func _ready() -> void:
	var casa_temp = CenaCasa.instantiate()
	tamanho_casa = casa_temp.get_tamanho()
	tamanho = Vector2(tamanho_casa.x * NUMERO_COLUNAS, tamanho_casa.y * NUMERO_LINHAS)
	casa_temp.queue_free()
	for i in NUMERO_LINHAS:
		for j in NUMERO_COLUNAS:
			var casa = CenaCasa.instantiate()
			casa.name = "%d,%d" % [i, j]
			casa.position = Vector2(j * casa.get_tamanho().x, i * casa.get_tamanho().y)
			if i == 2 && j == 2:
				casa.modulate = Color.SADDLE_BROWN
			add_child(casa)
			casa.input_event.connect(casa_foi_selecionada.bind(casa.name))

func casa_foi_selecionada(_viewport, _event, _shape, string_posicao):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var array_posicao = string_posicao.split(",")
		var posicao_casa = Vector2(int(array_posicao[1]), int(array_posicao[0]))
		casa_selecionada.emit(posicao_casa)

func adicionar_peca(posicao_casa: Vector2, jogador_local: bool):
	var peca = CenaPeca.instantiate()
	var posicao_x = posicao_casa.x * tamanho_casa.x + tamanho_casa.x / 2
	var posicao_y = posicao_casa.y * tamanho_casa.y + tamanho_casa.y / 2
	peca.position = Vector2(posicao_x, posicao_y)
	var bit_peca = 1 << int(posicao_casa.y * NUMERO_COLUNAS + posicao_casa.x)
	if jogador_local:
		peca.modulate = COR_JOGADOR_LOCAL
		bitboard_jogador_local |= bit_peca
	else:
		peca.modulate = COR_OPONENTE
		bitboard_oponente |= bit_peca
	add_child(peca)

func existe_peca_em(posicao_casa) -> bool:
	var bit_casa = 1 << int(posicao_casa.y * NUMERO_COLUNAS + posicao_casa.x)
	return (bitboard_jogador_local | bitboard_oponente) & bit_casa
