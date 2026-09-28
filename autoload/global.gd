extends CanvasLayer


func _on_button_pressed() -> void:
	var button: Button = $Button
	var audio: AudioStreamPlayer = $AudioStreamPlayer
	
	if audio.playing:
		audio.stop()
		button.modulate = Color(1, 0, 0)
	else:
		audio.play()
		button.modulate = Color(1, 1, 1)
