extends Area2D

signal hit
signal scored

func _on_body_entered(body: Node2D) -> void:
	hit.emit()


func _on_score_detector_body_entered(body: Node2D) -> void:
	scored.emit()
