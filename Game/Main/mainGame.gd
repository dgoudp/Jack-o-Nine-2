####	Main Game script
#	
#		This object will handle most of the game main interface
#		Including main navigation and panels
#		extra screens like invetory and stats, will also be child of this node

extends Control

const Def_unavailable = -1
const Def_disable = 0
const Def_location = 1
const Def_resident = 2
const Def_person = 3
const Def_dialog = 4
const Def_store = 5

#		world path, eventually will be an setting option
export(String, DIR) var world = "res://Rome/"
#		database for most game files
var dataBank = {}
var resourceBank = ResourcePreloader.new()
#		tracking of current location is needed
var current_local = {}

func _enter_tree():
	loadWorld(world)
	print("MSG: mainGame entered tree")

func _ready():
	call_deferred("change_local","rome_main")
	print("MSG: mainGame is ready")
#	change_local("rome_main")
#	pass


#		This calls on all world data files to be loaded into dataBank
func loadWorld(path = ""):
	if path.empty() :
		print("ERR: loadWorld path is empty")
		return
	var filelist = get_node("/root/global_func").g_listFiles(path)
	if filelist==null :
		print("ERR: loadWorld file list came empty")
		return
	for i in range(filelist.size()):
		if (filelist[i].find("template")!=-1) :
			continue
		elif (filelist[i].extension()=="json") :
			var data = get_node("/root/global_func").g_loadJson(str(path,filelist[i]))
			if data==null :
				print("ERR: loadWorld failed to load data: ",filelist[i])
				continue
			elif (!data.has("name")) or (data["name"]==""):
				print("ERR: loadWrold data has no name: ",filelist[i])
				continue
			elif (!data.has("type")) or (typeof(data["type"])!=TYPE_INT):
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


#		loads resource based on path and keep track of cache
func loadRes(path):
	if (path==null) or !(path.is_rel_path()):
		print("ERR: loadRes path is null or not relative ",path)
		return null
	if !(File.new().file_exists(path)):
		print("ERR: loadRes file missing: ",path)
		return null
	if !(resourceBank.has_resource(path)):
		var res = ResourceLoader.load(str(world,path))
		resourceBank.add_resource(path, res)
		print("MSG: loadRes loaded resource to cache: ",path)
	return resourceBank.get_resource(name)


#		major function for when local changes
func change_local(local):
	if dataBank.has(local) :
		#		keep track the previous location
		var previous = current_local("name")
		current_local.erase("prev")
		#		possible code if copying local without referencing it
		#		current_local.clear()
		#		for key in dataBank[local] :
		#			current_local[key] = dataBank[local][key]
		current_local = dataBank[local]
		current_local("prev") = previous
		print("MSG: change_local changing local to ",local)
		#		do common checks and assigments for all data
		if current_local.has("title") :
			get_node("topPanel/title").set_text(current_local["title"])
		var background
		#		check background and check for same name file
		if current_local.has("background") :
			background = loadRes(current_local["background"])
		else :
			background = loadRes(str("background/",current_local["name"],".jpg"))
		if background != null :
			get_node("centerPanel/back").set_texture(background)
		#		check for char file, may be specific to type
		if current_local.has("char") :
			get_node("centerPanel/back/char").set_texture(loadRes(current_local["char"]))
			get_node("centerPanel/back/char").show()
		else :
			get_node("centerPanel/back/char").hide()
		#		do check for type and apply specific action
		if (current_local["type"]==Def_location) :
			if current_local.has("menu") :
				get_node("centerPanel/dialog").hide()
				buildNav()
			else :
				print("ERR: change_local ",current_local["name"]," does not have menu data")
		elif (current_local["type"]==Def_dialog) :
			if current_local.has("dialog") :
				get_node("centerPanel/nav").hide()
				buildDialog()
			else :
				print("ERR: change_local ",current_local["name"]," does not have dialog data")
		return
	else :
		print("ERR: change_local dataBank doesn't have ",local)
		return




#		ugly needs change
#		Call to build the navigation menu of the main game
func buildNav():
	var nav = get_node("centerPanel/nav")
	#		resets box size
	if ( nav.get_child_count() > 0) :
		nav.get_child(0).free()
		nav.set_margin(MARGIN_TOP,32)
		nav.set_margin(MARGIN_LEFT,32)
		nav.set_margin(MARGIN_BOTTOM,64)
		nav.set_margin(MARGIN_RIGHT,400)
	#	create hierarchy nodes
	var vbox = VBoxContainer.new()
	vbox.set_name("vbox")
	nav.add_child(vbox)
	#	iterate between range of menu size, in order
	for i in range(current_local["menu"].size()) :
		var but = Button.new()
		but.set_name("nav"+str(i))
		var butlocal = current_local["menu"][i]
		if (dataBank.has(butlocal)) :
			if (dataBank[butlocal]["type"]==Def_unavailable) :
				continue
			elif (dataBank[butlocal]["type"]==Def_disable) :
				but.set_disabled(true)
			else :
				but.connect("pressed",self,"_on_nav_pressed",[butlocal])
			if dataBank[butlocal].has["title"] :
				but.set_text(dataBank[butlocal]["title"])
			if dataBank[butlocal].has["icon"] :
				loadRes(str("icons/",butlocal))
				but.set_button_icon(loadRes(dataBank[butlocal]["icon"]))
			else :
				but.set_button_icon(loadRes(str("icons/",butlocal,".png")))
		else :
			#	needs rewrite, button should not be shown
			print("ERR: buildNav data not found for ",butlocal)
			but.set_text(str(butlocal," not found"))
			but.set_disabled(true)
		but.set_text_align(HALIGN_LEFT)
		vbox.add_child(but)
	vbox.queue_sort()
	nav.update()
	print("MSG: buildNav nav control has been built ")
	return true


func _on_nav_pressed(local):
	if !dataBank.has(local) :
		print("ERR: nav_pressed but dataBank does not have ",local)
		return
	else :
		call_deferred("change_local",local)
		return


func buildDialog():
	if !current.has("dialog") :
		print("ERR: buildDialog data doesn't have dialog ",current["name"])
		return false
	if !current.has("dialogstep") :
		current["dialogstep"] = 1
	else :
		current["dialogstep"] += 1
	if current.has("title") :
		get_node("centerPanel/dialog/hbox/title").set_text(current["title"])
	if current["dialogstep"] <= current["dialog"].size() :
		get_node("centerPanel/dialog/hbox/panel/text").set_bbcode(current["dialog"][current["dialogstep"]-1])
		get_node("centerPanel/dialog").connect("input_event",self,"_on_dialog_input")
#		ugly, need re-write


func _on_size_change(controlname):
#	if controlname == "nav" :
#		var control = get_node("centerPanel/nav")
#		var sizey = control.find_node("panel",true,false).get_size().y
#		var sizex = control.find_node("panel",true,false).get_size().x
#		print("MSG: on_size_changed ",controlname," ",sizex,",",sizey)
#		print("MSG: on_size_changed ",control.get_size().x,",",control.get_size().y)
#		control.set_margin(MARGIN_TOP,sizey/2)
#		control.set_margin(MARGIN_BOTTOM,-sizey/2)
#		control.set_margin(MARGIN_RIGHT,sizex+32)
#	else :
#		pass
	pass


func _on_menu_toggled( pressed ):
	if pressed :
		get_node("anime").play("topmenu")
	else :
		get_node("anime").play_backwards("topmenu")


func _on_quit_pressed():
	get_tree().quit()


func _on_dialog_input( ev ):
	pass # replace with function body
