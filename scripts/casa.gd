class_name Casa
extends Area2D

func get_tamanho():
	return $CollisionShape2D.shape.get_rect().size
