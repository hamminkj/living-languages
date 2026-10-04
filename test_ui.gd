extends SceneTree
func _initialize():
	call_deferred("check")
func check():
	var ui = load("res://main.tscn").instantiate()
	root.add_child(ui)
	root.size = Vector2i(720,1280)
	await process_frame
	await process_frame
	assert(ui.tabs.get_combined_minimum_size().x <= 720)
	ui.tabs.current_tab = 1
	await process_frame
	await process_frame
	assert(ui.tabs.get_child(1).get_child(0).size.x <= 720)
	ui.advance()
	assert(ui.sim.year == 1)
	ui.keep_comparison()
	ui.restart()
	assert(ui.sim.year == 0 and ui.chart.baseline.size() == 2)
	print("PASS: portrait layout width, step, comparison, restart")
	quit()
