extends Control


func play():
	var root = $HBoxContainer/play
	var to = GTLib.node("LineEdit", root)
	GTLib.play_global_mus(to.text, 0.2)


func stop():
	GTLib.stop_global_mus()


func pause():
	GTLib.pause_global_mus()


func resume():
	GTLib.resume_global_mus()


func jump():
	var root = $HBoxContainer/jump
	var to = GTLib.node("LineEdit", root)

	GTLib.global_mus_jump_to(float(to.text))
