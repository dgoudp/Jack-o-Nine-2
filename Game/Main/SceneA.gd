####	SceneA
#
#		Handles Scene A
#		will generate all of the dialog and game menu navigation
#		top bar for quick access and side bar for additional info

extends Control

#		type constants for location
const Def_unavailable = -1
const Def_disable = 0
const Def_location = 1
const Def_dialog = 2
const Def_script = 3

var logd 
var loadRes
var worldBank
var worldPath
#var resBank
var current_local

#export(String, DIR) var pathBackdrop = "res://Resources/UI"


func _enter_tree():
	logd = self.get_parent().get("logd")
	loadRes = self.get_parent().get("loadRes")
	worldBank = self.get_parent().get("worldBank")
	#resBank = self.get_parent().get("resBank")
	current_local = self.get_parent().get("current_local")
	worldPath = self.get_parent().get("worldPath")
	pass

func _ready():
	genBackdrop( get_node("/root/singleton").get("pathResources"))
	get_node("centerPanel").set_focus_mode(2)
	get_node("topPanel").connect("mouse_enter",self,"_on_topPanel_mouse",[true])
	get_node("topPanel/menu").connect("toggled",self,"_on_menu_toggled",[])
	get_node("topPanel/menu/HBoxContainer/quit").connect("pressed",self,"_on_quit_pressed",[])
	pass

#		major function for when local changes
func change_local(local):
	if worldBank.has(local) :
		#		keep track the previous location
		var previous 
		if current_local.has("name") :
			previous = current_local["name"]
		else :
			previous = ""
		current_local.erase("localprev")
		current_local.erase("dialogstep")
		#		possible code if copying local without referencing it
		#		current_local.clear()
		#		for key in worldBank[local] :
		#			current_local[key] = worldBank[local][key]
		#		currently it references the original data
		current_local = worldBank[local]
		current_local["localprev"] = previous
		logd.call_func( str("MSG: change_local changing local to ",local))
		#		do common checks and assigments for all data
		if current_local.has("title") :
			get_node("topPanel/title").set_text(current_local["title"])
		var background
		#		check background and check for same name file
		if current_local.has("background") :
			background = loadRes.call_func( str( worldPath,current_local["background"]))
		else :
			background = loadRes.call_func( str( worldPath,"background/",current_local["name"],".jpeg"))
		if background != null :
			get_node("centerPanel/back").set_texture(background)
		#		check for char file, may be specific to type
		if current_local.has("char") :
			get_node("centerPanel/back/char").set_texture( loadRes.call_func( str( worldPath,current_local["char"])))
			get_node("centerPanel/back/char").show()
		else :
			get_node("centerPanel/back/char").hide()
		#		do check for type and apply specific action
		if (current_local["type"]==Def_location) :
			if current_local.has("menu") :
				get_node("centerPanel/dialog").hide()
				buildNav()
			else :
				logd.call_func(str("ERR: change_local ",current_local["name"]," does not have menu data"))
		elif (current_local["type"]==Def_dialog) :
			if current_local.has("dialog") :
				get_node("centerPanel/nav").hide()
				buildDialog()
			else :
				logd.call_func(str("ERR: change_local ",current_local["name"]," does not have dialog data"))
		return
	else :
		logd.call_func(str("ERR: change_local worldBank doesn't have ",local))
		return


#		Call to build the navigation menu of the main game
func buildNav():
	var nav = get_node("centerPanel/nav")
	#		resets box size
	while ( nav.get_child_count() > 0) :
		nav.get_child(0).free()
	nav.set_margin(MARGIN_TOP,32)
	nav.set_margin(MARGIN_LEFT,32)
	nav.set_margin(MARGIN_BOTTOM,64)
	nav.set_margin(MARGIN_RIGHT,64)
	#	create hierarchy nodes
	var vbox1 = VBoxContainer.new()
	var hbox = HBoxContainer.new()
	var vbox2 = VBoxContainer.new()
	var odd = false
	var menusize = current_local["menu"].size()
	#	detect if menu should be split
	if (menusize > 10) :
		nav.add_child(hbox)
		hbox.add_child(vbox1)
		hbox.add_child(vbox2)
		if ((menusize % 2) == 1) :
			odd = true
	else :
		nav.add_child(vbox1)
		hbox.free()
		vbox2.free()
	#	iterate between range of menu size, in order
	for i in range(menusize) :
		var but = Button.new()
		but.set_name(str("nav",i))
		but.set_text_align(HALIGN_LEFT)
		but.set_custom_minimum_size(Vector2(300,48))
		var butlocal = current_local["menu"][i]
		if (worldBank.has(butlocal)) :
			if (worldBank[butlocal]["type"]==Def_unavailable) :
				continue
			elif (worldBank[butlocal]["type"]==Def_disable) :
				but.set_disabled(true)
			else :
				but.connect("pressed",self,"_on_nav_pressed",[butlocal])
			if current_local.has("menutext") :
				if current_local["menutext"].size() == menusize:
					but.set_text(current_local["menutext"][i])
			elif worldBank[butlocal].has("title") :
				but.set_text(worldBank[butlocal]["title"])
			if current_local.has("menuicon") :
				if current_local["menuicon"].size() == menusize:
					but.set_button_icon( loadRes.call_func( str( worldPath,current_local["menuicon"][i])))
			elif worldBank[butlocal].has("icon") :
				but.set_button_icon( loadRes.call_func( str( worldPath,worldBank[butlocal]["icon"])))
			else :
				but.set_button_icon( loadRes.call_func( str( worldPath,"icon/",butlocal,".png")))
		else :
			#	needs rewrite, button should not be shown
			logd.call_func( str("WRN: buildNav data not found for ",butlocal))
			but.set_text( str(butlocal," not found"))
			but.set_disabled(true)
		if (menusize > 10) :
			var menuhalf = int(menusize / 2)
			if odd :
				menuhalf += 1
			if ((i+1) > menuhalf) :
				vbox2.add_child(but)
			else :
				vbox1.add_child(but)
		else :
			vbox1.add_child(but)
	nav.find_node("nav0",true,false).grab_focus()
	nav.show()
	
	

func _on_nav_pressed(local):
	if !worldBank.has(local) :
		logd.call_func( str("ERR: nav_pressed but worldBank does not have ",local))
	else :
		call_deferred("change_local",local)


#		Builds the dialog presentation
func buildDialog():
	var dialog = get_node("centerPanel/dialog")
	#	frees child
	if (dialog.get_child_count() > 0) :
		dialog.get_child(0).free()
	#	create elements
	var hbox = HBoxContainer.new()
	hbox.set_name("hbox")
	hbox.set_ignore_mouse(true)
	var title = Label.new()
	title.set_name("dialogtitle")
	title.set_ignore_mouse(true)
	var panel = Panel.new()
	panel.set_name("panel")
	panel.set_ignore_mouse(true)
	var text = RichTextLabel.new()
	text.set_name("text")
	text.set_selection_enabled(false)
	text.set_stop_mouse(false)
#	text.set_ignore_mouse(true)
	current_local["dialogstep"] = 0
	if current_local.has("dialogtitle") :
		title.set_autowrap(true)
		title.set_align(HALIGN_CENTER)
		title.set_valign(VALIGN_CENTER)
		title.set_custom_minimum_size(Vector2(128,164))
		title.set_text(current_local["dialogtitle"])
		hbox.add_child(title)
	if current_local.has("dialog") :
		panel.set_h_size_flags( SIZE_EXPAND_FILL)
		panel.add_child(text)
		text.set_anchor_and_margin(MARGIN_LEFT,ANCHOR_BEGIN,12)
		text.set_anchor_and_margin(MARGIN_TOP,ANCHOR_BEGIN,12)
		text.set_anchor_and_margin(MARGIN_RIGHT,ANCHOR_END,12)
		text.set_anchor_and_margin(MARGIN_BOTTOM,ANCHOR_END,12)
		text.set_bbcode(current_local["dialog"][current_local["dialogstep"]])
		text.set_use_bbcode(true)
		hbox.add_child(panel)
	dialog.add_child(hbox)
	get_node("centerPanel").connect("input_event",self,"_on_dialog_input")
	get_node("centerPanel").grab_focus()
	dialog.show()


#		shows up next dialog in line and where to go next
func dialog_next():
	current_local["dialogstep"] += 1
	if (current_local["dialogstep"] > (current_local["dialog"].size() - 1)) :
		if current_local.has("menu") :
			buildNav()
		elif current_local.has("localnext") :
			call_deferred("change_local",current_local["localnext"])
		elif current_local.has("localprev") :
			call_deferred("change_local",current_local["localprev"])
		else :
			logd.call_func("ERR: dialog_next has no local to go")
		get_node("centerPanel").disconnect("input_event",self,"_on_dialog_input")
	elif (current_local["dialogstep"] == (current_local["dialog"].size() - 1)) :
		get_node("centerPanel/dialog/hbox/panel/text").set_bbcode(current_local["dialog"][current_local["dialogstep"]])
		if current_local.has("menu") :
			buildNav()
			get_node("centerPanel").disconnect("input_event",self,"_on_dialog_input")
	else :
		get_node("centerPanel/dialog/hbox/panel/text").set_bbcode(current_local["dialog"][current_local["dialogstep"]])


func _on_dialog_input(event):
	#print("DEV: input event ",event.type,event.device,event.ID)
	if event.is_action("ui_accept") or event.is_action("ui_select") or event.is_action("ui_left_click") :
		if event.is_pressed() :
			dialog_next()
			get_node("centerPanel").accept_event()


func _on_menu_toggled(pressed):
	if pressed :
		get_node("anime").queue("topmenu")
	else :
		get_node("anime").queue("topmenuR")


func _on_quit_pressed():
	get_tree().quit()


func _on_topPanel_mouse( enter=false ):
	if enter :
		get_node("anime").queue("toppanel")
		get_node("topPanel").disconnect("mouse_enter",self,"_on_topPanel_mouse")
		get_node("centerPanel").connect("mouse_enter",self,"_on_topPanel_mouse",[false])
		get_node("topPanel/menu").set_ignore_mouse(false)
	else :
		get_node("anime").queue("toppanelR")
		get_node("centerPanel").disconnect("mouse_enter",self,"_on_topPanel_mouse")
		get_node("topPanel").connect("mouse_enter",self,"_on_topPanel_mouse",[true])
		get_node("topPanel/menu").set_ignore_mouse(true)
		if get_node("topPanel/menu").is_pressed() :
			get_node("topPanel/menu").set_pressed(false)
			_on_menu_toggled(false)

#	replace panel backdrops based on path
func genBackdrop(path = ""):
	if (path.empty()) or (path.is_rel_path()) :
		logd.call_func( str("ERR: genBackdrop path is empty or relative ", path))
		return FAILED
	logd.call_func( str("MSG: genBackdrop is fetching resource from ", path))
	#sidepanel1 = loadRes( str(path,"sidePanel1.png"))
	#sidepanel2 = loadRes( str(path,"sidePanel2.png"))
	#topanel1 = loadRes( str(path,"topPanel1.png"))
	get_node("topPanel/back").set_texture( loadRes.call_func( str(path,"Backdrops/topPanel1.png")))
	get_node("sidePanel/back").set_texture( loadRes.call_func( str(path,"Backdrops/sidePanel1.png")))
	# possibility to check for size and scale regardless

