####	mainMenu root scene
#		
#		the mainMenu is handler to initial screen of the game
#		

extends Node

var libs = preload("res://Game/Main/libs.gd")

func _enter_tree():
	libs.logd("MSG: mainMenu entered tree",true)
#	self.connect("input_event",self,"_input_event",[])
	get_node("titleWarn").connect("input_event",self,"_on_titleWarn_input_event",[])
	pass


#		hide menu box and show warning image
func _ready():
	get_node("VBoxContainer").hide()
	get_node("titleWarn").show()
	get_node("titleWarn").set_focus_mode(2)
	get_node("titleWarn").grab_focus()
	if get_node("titleWarn").has_focus() :
		libs.logd("MSG: titleWarn has focus")
	pass


func changeScene(path):
	var res = ResourceLoader.load(path)
	var newScene = res.instance()
	var curScene = get_tree().get_current_scene()
	if (newScene == null) :
		libs.logd("ERR: g_changeScene newScene is null")
		return false
	get_tree().get_root().add_child(newScene)
	get_tree().set_current_scene(newScene)
	curScene.queue_free()
	return true


func _on_newGame_pressed():
	var path = "res://Game/Main/mainGame.tscn"
	libs.logd(str("MSG: newGame_pressed calling scene: ",path))
	changeScene(path)


func _on_exit_pressed():
	libs.logd("MSG: mainMenu exit_pressed, quiting game")
	get_tree().quit()


func _input_event(event):
#	print("input: ",event.type)
	if event.is_action("ui_close") :
		libs.logd("MSG: mainMenu ui_close pressed")
		accept_event()
		get_tree().quit()


func _on_titleWarn_input_event(event):
#	print("input: ",event.type)
	if (event.type == InputEvent.KEY) or (event.type == InputEvent.MOUSE_BUTTON):
		if event.is_pressed() :
			libs.logd("MSG: titleWarn input_event pressed")
			get_node("titleWarn").hide()
			get_node("VBoxContainer").show()
			get_node("titleWarn").accept_event()
			get_node("VBoxContainer/newGame").grab_focus()


