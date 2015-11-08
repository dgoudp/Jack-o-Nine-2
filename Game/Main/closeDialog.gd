
extends Popup

func _init():
	pass


func _on_Confirm_pressed():
	print("confirm close pressed")
	get_tree().quit()
	#pass # replace with function body


func _on_Cancel_pressed():
	print("Cancel close pressed")
	#self.hide()
	self.hide()

func _input_event(event):
	if event.is_action("ui_cancel") and event.is_pressed():
		print("ui_cancel pressed on close window")
		self.hide()
		accept_event()
	elif event.is_action("ui_close") and event.is_pressed():
		print("ui_close pessed on close window")
		self.hide()
		accept_event()

#func _input(event):
#	if event.is_action("ui_close"):
#		self.queue_free()
#		accept_event()
