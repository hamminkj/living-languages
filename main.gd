extends Control
const Model = preload("res://model.gd")
const World = preload("res://world.gd")
var sim = Model.new()
var sliders = {}
var stats: Label
var event_text: Label
var map
var chart
var run_button: Button
var running = false
var elapsed = 0.0
var seed_value = 42
var seed_label: Label
var goal: OptionButton
var result: Label
var baseline: Array = []
var baseline_text = ""
var tabs: TabContainer

func _ready():
	var theme_new = Theme.new()
	theme_new.default_font_size = 25
	theme = theme_new
	var bg = ColorRect.new()
	bg.color = Color("#09131c")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	tabs = TabContainer.new()
	tabs.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tabs.add_theme_font_size_override("font_size",28)
	for state in ["tab_selected","tab_unselected","tab_hovered"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#173d34") if state == "tab_selected" else Color("#15232f")
		style.content_margin_top = 24
		style.content_margin_bottom = 24
		style.content_margin_left = 18
		style.content_margin_right = 18
		tabs.add_theme_stylebox_override(state,style)
	add_child(tabs)
	var box = tab_box("Set up")
	label(box,"TUJUJU STUDIOS",18,Color("#51d6b0"))
	label(box,"Living Languages",42)
	label(box,"A community. Two languages. Many possible futures.",24)
	label(box,"Set conditions, choose a challenge, then run 60 years. Pause to change policies. Tap Restart to replay the same population.",23)
	goal = OptionButton.new()
	for text in ["Free exploration","Shift toward Taluma: home use > 75%","Support bilingualism: > 50%","Separate domains: gap > 17 points"]:
		goal.add_item(text)
	goal.custom_minimum_size.y = 86
	box.add_child(goal)
	seed_label = label(box,"",20)
	var presets = HBoxContainer.new()
	box.add_child(presets)
	button(presets,"Balanced",func(): preset([60,50,50,50,20,20]))
	button(presets,"Taluma shift",func(): preset([30,90,90,70,0,20]))
	button(presets,"Split domains",func(): preset([80,20,5,15,0,20]))
	label(box,"Starting conditions",30)
	make_slider(box,"start","Starting Taluma speakers",60)
	make_slider(box,"school","Taluma in school",50)
	make_slider(box,"jobs","Taluma job opportunities",50)
	make_slider(box,"ties","Contact between districts",50)
	make_slider(box,"migration","English-speaking immigration",20)
	make_slider(box,"stress","Environmental pressure",20)
	label(box,"School, jobs, contact, migration and pressure can change while paused. Starting speakers apply on Restart.",20)
	button(box,"Observe community",func(): tabs.current_tab=1)
	box = tab_box("Observe")
	label(box,"Living Languages",34)
	var actions = HBoxContainer.new()
	box.add_child(actions)
	run_button = button(actions,"Run",toggle)
	button(actions,"+1 year",func(): running=false; advance())
	button(actions,"Restart",restart)
	var extra = HBoxContainer.new()
	box.add_child(extra)
	button(extra,"New seed",func(): seed_value += 1; restart())
	button(extra,"Keep comparison",keep_comparison)
	stats = label(box,"",26)
	label(box,"Rural              Riverside             Town",21)
	map = World.new()
	map.custom_minimum_size = Vector2(0,230)
	map.sim = sim
	box.add_child(map)
	label(box,"Dots: green Taluma | gold English | blue bilingual\nEach dot is a resident. Crowded districts may hide extra dots.",19)
	chart = World.new()
	chart.sim = sim
	chart.graph = true
	chart.custom_minimum_size = Vector2(0,180)
	box.add_child(chart)
	label(box,"0 to 60 years | vertical scale: 0 to 100%\nGreen: Taluma at home. Gold: Taluma at work.\nBlue: bilingual residents. Gray: saved home-use comparison.",19)
	result = label(box,"",25,Color("#51d6b0"))
	event_text = label(box,"",22)
	box = tab_box("About")
	label(box,"Taluma words",30)
	label(box,"sela = water   |   nari = person   |   lum = land\nmi = I   |   ta = you   |   paku = protect\nmi paku sela = I protect water.\nTaluma uses subject + verb + object. This version models language use and learning, not grammar change or creole formation.",22)
	label(box,"How the system works",30)
	label(box,"Language use builds proficiency; proficiency influences later use. Children learn through family and school. New residents change the contact network. Environmental pressure lowers ecosystem health, pushing some rural residents to town. Effects accumulate over decades.\n\nThe labels describe game thresholds, not scientific diagnoses. Different settings can resemble diglossia, but this model does not establish it. Immigration direction is a scenario assumption. No language is inherently more useful.\n\nTry keeping the seed fixed and changing one factor at a time. Does a policy work at first but fade later?",22)
	restart()

func tab_box(title: String) -> VBoxContainer:
	var scroll = ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+side,24)
	scroll.add_child(margin)
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation",18)
	margin.add_child(box)
	return box

func label(parent, text: String, font_size = 25, color = Color("#e3edf2")) -> Label:
	var l = Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size",font_size)
	l.add_theme_color_override("font_color",color)
	parent.add_child(l)
	return l

func button(parent, text: String, action: Callable) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0,86)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size",22)
	b.pressed.connect(action)
	parent.add_child(b)
	return b

func make_slider(parent, key: String, text: String, value: float):
	var caption = label(parent,"%s: %d%%" % [text,value],23)
	var s = HSlider.new()
	s.min_value = 0
	s.max_value = 100
	s.step = 5
	s.value = value
	s.custom_minimum_size.y = 86
	sliders[key] = s
	s.value_changed.connect(func(v): caption.text="%s: %d%%" % [text,v])
	parent.add_child(s)

func config() -> Dictionary:
	var c = {}
	for key in sliders:
		c[key] = sliders[key].value
	return c

func preset(values: Array):
	var keys = ["start","school","jobs","ties","migration","stress"]
	for i in range(keys.size()):
		sliders[keys[i]].value = values[i]
	restart()

func restart():
	running = false
	sim.reset(config(),seed_value)
	refresh()

func toggle():
	running = not running if sim.year < 60 else false
	refresh()

func _process(delta):
	if running:
		elapsed += delta
		if elapsed >= 0.35:
			elapsed = 0
			advance()

func advance():
	sim.settings = config()
	sim.step()
	if sim.year >= 60:
		running = false
	refresh()

func keep_comparison():
	baseline = sim.history.duplicate()
	baseline_text = "Saved run: year %d, home Taluma %d%% (seed %d)." % [sim.year,sim.home*100,seed_value]
	chart.baseline = baseline
	refresh()

func refresh():
	run_button.text = "Pause" if running else "Run"
	run_button.disabled = sim.year >= 60
	seed_label.text = "Population seed: %d | same seed = same initial population" % seed_value
	stats.text = "Year %d / 60   |   Residents %d\nTaluma home %d%%   |   Work %d%%\nBilingual %d%%   |   Ecosystem health %d%%" % [sim.year,sim.people.size(),sim.home*100,sim.work*100,sim.bilingual*100,sim.ecology*100]
	var achieved = [false,sim.home>0.75,sim.bilingual>0.5,absf(sim.home-sim.work)>0.17][goal.selected]
	result.text = sim.outcome()
	if goal.selected > 0:
		result.text += "\n" + ("Challenge reached." if achieved else "Challenge in progress." if sim.year < 60 else "Challenge not reached. Try another setup.")
	event_text.text = baseline_text + "\n" + ("No drought events yet." if sim.events.is_empty() else "\n".join(sim.events.slice(0,3)))
	map.queue_redraw()
	chart.queue_redraw()
