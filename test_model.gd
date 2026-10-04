extends SceneTree

func _initialize():
	var m = load("res://model.gd").new()
	var c = {"start":60.0,"school":50.0,"jobs":50.0,"ties":50.0,"migration":20.0,"stress":20.0}
	m.reset(c,42)
	for i in range(60):
		m.step()
		assert(m.home >= 0 and m.home <= 1)
		assert(m.bilingual >= 0 and m.bilingual <= 1)
		assert(m.ecology >= 0.1 and m.ecology <= 1)
	var first = m.history.duplicate()
	m.reset(c,42)
	for i in range(60):
		m.step()
	assert(m.history == first, "Seed must reproduce the run")
	c.school = 100.0
	c.jobs = 100.0
	c.migration = 0.0
	m.reset(c,42)
	for i in range(60):
		m.step()
	assert(m.home > first.back().x, "Taluma support should affect home use")
	print("PASS: 60-year bounds, repeatability, policy sensitivity")
	quit()
