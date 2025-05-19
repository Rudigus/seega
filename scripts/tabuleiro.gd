class_name Tabuleiro
extends Node2D

signal casa_selecionada(posicao_casa)

const NUMERO_LINHAS = 5
const NUMERO_COLUNAS = 5
const COR_JOGADOR_LOCAL = Color.BLUE
const COR_OPONENTE = Color.RED
const POSICAO_PECA_MEIO = Vector2(2, 2)

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
	peca.name = "p%d,%d" % [int(posicao_casa.x), int(posicao_casa.y)]
	add_child(peca)
	peca.owner = self

func mover_peca(posicao_antiga: Vector2, posicao_nova: Vector2, jogador_local: bool):
	var peca = find_child("p%d,%d" % [int(posicao_antiga.x), int(posicao_antiga.y)])
	peca.name = "p%d,%d" % [int(posicao_nova.x), int(posicao_nova.y)]
	var posicao_x = posicao_nova.x * tamanho_casa.x + tamanho_casa.x / 2
	var posicao_y = posicao_nova.y * tamanho_casa.y + tamanho_casa.y / 2
	peca.position = Vector2(posicao_x, posicao_y)
	var bit_novo = 1 << int(posicao_nova.y * NUMERO_COLUNAS + posicao_nova.x)
	var bit_antigo = 1 << int(posicao_antiga.y * NUMERO_COLUNAS + posicao_antiga.x)
	if jogador_local:
		bitboard_jogador_local ^= bit_antigo
		bitboard_jogador_local |= bit_novo
	else:
		bitboard_oponente ^= bit_antigo
		bitboard_oponente |= bit_novo

func existe_peca_em(posicao_casa) -> bool:
	var bit_casa = 1 << int(posicao_casa.y * NUMERO_COLUNAS + posicao_casa.x)
	return (bitboard_jogador_local | bitboard_oponente) & bit_casa

func existe_peca_jogador_local_em(posicao_peca) -> bool:
	var bit_peca = 1 << int(posicao_peca.y * NUMERO_COLUNAS + posicao_peca.x)
	return bitboard_jogador_local & bit_peca

func existe_peca_oponente_em(posicao_peca) -> bool:
	var bit_peca = 1 << int(posicao_peca.y * NUMERO_COLUNAS + posicao_peca.x)
	return bitboard_oponente & bit_peca

func quantidade_pecas(jogador_local: bool) -> int:
	var numero_pecas = 0
	var bitboard
	if jogador_local:
		bitboard = bitboard_jogador_local
	else:
		bitboard = bitboard_oponente
	while bitboard != 0:
		bitboard &= bitboard - 1
		numero_pecas += 1
	return numero_pecas

func pode_mover_peca(posicao_atual, posicao_nova):
	if posicao_atual == null or posicao_nova == null:
		return false
	if existe_peca_em(posicao_nova):
		return false
	var diferenca_x = abs(posicao_atual.x - posicao_nova.x)
	var diferenca_y = abs(posicao_atual.y - posicao_nova.y)
	if (diferenca_x + diferenca_y) == 1:
		return true
	else:
		return false

func peca_capturavel_por(posicao_peca_movida):
	if posicao_peca_movida.x > 1:
		var posicao_possivel_peca_oponente = Vector2(posicao_peca_movida.x - 1, posicao_peca_movida.y)
		if posicao_possivel_peca_oponente != POSICAO_PECA_MEIO and \
		existe_peca_oponente_em(posicao_possivel_peca_oponente) and \
		existe_peca_jogador_local_em(Vector2(posicao_peca_movida.x - 2, posicao_peca_movida.y)):
			return posicao_possivel_peca_oponente
	if posicao_peca_movida.x < NUMERO_COLUNAS - 2:
		var posicao_possivel_peca_oponente = Vector2(posicao_peca_movida.x + 1, posicao_peca_movida.y)
		if posicao_possivel_peca_oponente != POSICAO_PECA_MEIO and \
		existe_peca_oponente_em(posicao_possivel_peca_oponente) and \
		existe_peca_jogador_local_em(Vector2(posicao_peca_movida.x + 2, posicao_peca_movida.y)):
			return posicao_possivel_peca_oponente
	if posicao_peca_movida.y > 1:
		var posicao_possivel_peca_oponente = Vector2(posicao_peca_movida.x, posicao_peca_movida.y - 1)
		if posicao_possivel_peca_oponente != POSICAO_PECA_MEIO and \
		existe_peca_oponente_em(posicao_possivel_peca_oponente) and \
		existe_peca_jogador_local_em(Vector2(posicao_peca_movida.x, posicao_peca_movida.y - 2)):
			return posicao_possivel_peca_oponente
	if posicao_peca_movida.y < NUMERO_LINHAS - 2:
		var posicao_possivel_peca_oponente = Vector2(posicao_peca_movida.x, posicao_peca_movida.y + 1)
		if posicao_possivel_peca_oponente != POSICAO_PECA_MEIO and \
		existe_peca_oponente_em(posicao_possivel_peca_oponente) and \
		existe_peca_jogador_local_em(Vector2(posicao_peca_movida.x, posicao_peca_movida.y + 2)):
			return posicao_possivel_peca_oponente
	return null

func capturar_peca(posicao_peca, jogador_local: bool):
	var peca = find_child("p%d,%d" % [int(posicao_peca.x), int(posicao_peca.y)])
	peca.queue_free()
	var bit_peca = 1 << int(posicao_peca.y * NUMERO_COLUNAS + posicao_peca.x)
	if jogador_local:
		bitboard_oponente ^= bit_peca
	else:
		bitboard_jogador_local ^= bit_peca
