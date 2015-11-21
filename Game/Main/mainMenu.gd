
extends Node

####	mainMenu root scene
#		
#		the mainMenu is handler to initial screen of the game
#		


func _ready():
	set_process_input(true)
	if is_processing_input() :
		print("MSG: "+self.get_name()+" is processing input")
	pass


#		hide menu box and show warning image
func _enter_tree():
	get_node("VBoxContainer").hide()
	get_node("titleWarn").show()
	pass


func _on_newGame_pressed():
	var path = "res://Game/Main/mainGame.scn"
	print("MSG: ",self.get_name()," calling scene: ",path)
#	needs a local change scene	
#	get_node("/root/global_func").g_changeScene(path)


func _on_exit_pressed():
	print("MSG: ",self.get_name()," exit button pressed, quiting game")
	get_tree().quit()


func _input(event):
	if event.type == InputEvent.NONE :
		return
	elif event.is_action("ui_close") and event.is_pressed():
		print("event ui_close pressed")
		get_node("/root/global_func").g_closeDialog()
		accept_event()


func _on_titleWarn_input_event(event):
#	if event.is_released() and (event.is_action("ui_accept") or event.is_action("ui_left_click") or event.is_action("ui_right_click") or event.is_action("ui_cancel")):
	if (event.type == InputEvent.ACTION) or (event.type == InputEvent.MOUSE_BUTTON):
		print("titleWarn event pressed")
		get_node("titleWarn").hide()
		get_node("VBoxContainer").show()
		print("MSG: "+self.get_name()+" titleWarn is hidden via key input")
		accept_event()


func _on_titleWarn_focus_exit():
	print("MSG: "+self.get_name()+" titleWarn is hidden via lost focus")
	get_node("titleWarn").hide()
	get_node("VBoxContainer").show()



