####	Main Game script
#	
#		This object will handle most of the game main interface
#		Including main navigation and panels
#		extra screens like invetory and stats, will also be child of this node

extends Control

const Def_disable = 0
const Def_location = 1
const Def_resident = 2
const Def_shopper = 3
const Def_store = 4

export(String, DIR) var world = "res://Rome/"
var dataBank = {}
var resourceBank = ResourcePreloader.new()


func _enter_tree():
	loadWorld(world)
	print("MSG: mainGame entered tree")

func _ready():
	call_deferred("change_local","rome_main")
	print("MSG: mainGame is ready")
#	change_local("rome_main")
#	pass


#		This calls on all world data files to be loaded into dataBank
func loadWorld(path):
	var filelist = get_node("/root/global_func").g_listFiles(path)
	if filelist==null :
		print("ERR: g_loadData file list came empty")
		return
	for i in range(filelist.size()):
		if (filelist[i].find("template")!=-1) :
			continue
		elif (filelist[i].extension()=="json") :
			var data = get_node("/root/global_func").g_loadJson(str(path,filelist[i]))
			if data==null :
				print("ERR: loadWorld failed to load data: ",filelist[i])
				continue
			elif !(data.has("name")) :
				print("ERR: loadWrold data has no name: ",filelist[i])
				continue
			elif !(data.has("type")) :
				print("ERR: loadWorld data has no type: ",filelist[i])
				continue
			elif dataBank.has(data["name"]) :
				print("ERR: loadWorld already has data: ",data["name"])
				continue
			else :
				dataBank[data["name"]] = data
		else :
			continue

		
	return


#		Call to build the navigation menu of the main game
func buildNav(local):
	if !(dataBank.has(local)) :
		print("ERR: buildNav dataBank doesn't have ",local)
		return false
	var data = dataBank[local]
	var navControl = get_node("centerPanel/navControl")
	if ( navControl.get_child_count() > 0) :
		navControl.get_child(0).free()
		navControl.set_margin(MARGIN_TOP,10)
		navControl.set_margin(MARGIN_BOTTOM,-10)
		navControl.set_margin(MARGIN_RIGHT,400)
	var panel = PanelContainer.new()
	panel.set_name("panel")
	panel.set_custom_minimum_size(Vector2(368,0))
	var vbox = VBoxContainer.new()
	vbox.set_name("vbox")
	navControl.add_child(panel)
	panel.add_child(vbox)
	panel.connect("resized",get_tree().get_current_scene(),"_on_size_change",["navControl"])
	for i in range(data["menu"].size()) :
		var but = Button.new()
		but.set_name("nav"+str(i))
		var butlocal = data["menu"][i]
		if (dataBank.has(butlocal)) :
			but.set_text(dataBank[butlocal]["title"])
			var icon = get_node("/root/global_func").g_loadRes(str("icons/",butlocal),str(world,"icons/",butlocal,".png"))
			but.set_button_icon(icon)
			if (dataBank[butlocal]["type"]==Def_disable):
				but.set_disabled(true)
			else:
				but.connect("pressed",get_tree().get_current_scene(),"_on_nav_pressed",[butlocal])
		else :
			print("ERR: buildNav data not found for ",butlocal)
			but.set_text(str(butlocal," not found"))
			but.set_disabled(true)
		but.set_text_align(HALIGN_LEFT)
		vbox.add_child(but)
#		print("MSG: created button ",but.get_text()," on navControl with a call to ",butlocal)
	vbox.queue_sort()
	navControl.update()
	print("MSG: buildNav nav control has been built ")
	return true


func _on_nav_pressed(name):
	var type = dataBank[name]["type"]
	print("MSG: _on_nav call: ",name," type: ",type)
	if (type==Def_disable):
		return
	elif (type==Def_location):
		call_deferred("change_local",name)
		return


func change_local(local):
	if dataBank.has(local) :
		print("MSG: change_local changing local: ",local)
		get_node("anime").call_deferred("play","transition")
		yield(get_node("anime"),"finished")
#		while get_node("anime").get_current_animation_length() > get_node("anime").get_current_animation_pos() :
#			pass
		var title = dataBank[local]["title"]
		var texture = get_node("/root/global_func").g_loadRes("background/"+local,world+"background/"+local+".jpg")
		get_node("topPanel/title").set_text(title)
		get_node("centerPanel/back").set_texture(texture)
		buildNav(local)
		get_node("anime").call_deferred("play_backwards","transition")
		return
	else :
		print("ERR: change_local dataBank doesn't have ",local)
		return



func _on_size_change(controlname):
	if controlname == "navControl" :
		var control = get_node("centerPanel/navControl")
		var sizey = control.find_node("panel",true,false).get_size().y
		var sizex = control.find_node("panel",true,false).get_size().x
		print("MSG: on_size_changed ",controlname," ",sizex,",",sizey)
		print("MSG: on_size_changed ",control.get_size().x,",",control.get_size().y)
		control.set_margin(MARGIN_TOP,sizey/2)
		control.set_margin(MARGIN_BOTTOM,-sizey/2)
		control.set_margin(MARGIN_RIGHT,sizex+32)
	else :
		pass


func _on_menu_toggled( pressed ):
	if pressed :
		get_node("anime").play("topmenu")
	else :
		get_node("anime").play_backwards("topmenu")


func _on_quit_pressed():
	get_tree().quit()
