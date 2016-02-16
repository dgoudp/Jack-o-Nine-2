####	mainMenu root scene
#		
#		the mainMenu is handler to initial screen of the game
#		

extends Node

var libs = preload("res://Game/Main/libs.gd")
var logd = FuncRef.new()


func _enter_tree():
	logd = funcref( get_node("/root/singleton"), "logd")
	pass


#		hide menu box and show warning image
func _ready():
	get_node("titleWarn").connect("input_event",self,"_on_titleWarn_input_event",[])
	logd.call_func( "MSG: mainMenu is _ready")
	get_node("VBoxContainer").hide()
	get_node("titleWarn").show()
	get_node("titleWarn").set_focus_mode(2)
	get_node("titleWarn").grab_focus()
#	if get_node("titleWarn").has_focus() :
#		libs.logd("MSG: titleWarn has focus")
	pass


func _on_newGame_pressed():
	var path = "res://Game/Main/mainGame.tscn"
#	libs.logd(str("MSG: newGame_pressed calling scene: ",path))
	logd.call_func( str("MSG: newGame_pressed calling scene: ",path))
	get_node("/root/singleton").call("changeScene",path)


func _on_exit_pressed():
	logd.call_func( "MSG: mainMenu exit_pressed, quiting game")
	get_tree().quit()


func _input_event(event):
	if event.is_action("ui_close") :
		logd.call_func("MSG: mainMenu ui_close pressed")
		accept_event()
		get_tree().quit()


func _on_titleWarn_input_event(event):
	if (event.type == InputEvent.KEY) or (event.type == InputEvent.MOUSE_BUTTON):
		if event.is_pressed() :
#			libs.logd("MSG: titleWarn input_event pressed")
			get_node("titleWarn").hide()
			get_node("VBoxContainer").show()
			get_node("titleWarn").accept_event()
			get_node("VBoxContainer/newGame").grab_focus()


