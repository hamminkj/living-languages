extends Control
var sim
var baseline: Array = []
var graph = false

func _draw():
	if sim == null:
		return
	var w = size.x
	if graph:
		for level in [0.0, 0.5, 1.0]:
			draw_line(Vector2(15, 15 + (1-level)*150), Vector2(w-15, 15+(1-level)*150), Color("#29404d"), 1)
		for metric in range(3):
			var color = [Color("#51d6b0"), Color("#f4bc68"), Color("#99b9ff")][metric]
			for i in range(1, sim.history.size()):
				draw_line(Vector2(15+(i-1)*(w-30)/60, 15+(1-sim.history[i-1][metric])*150), Vector2(15+i*(w-30)/60, 15+(1-sim.history[i][metric])*150), color, 3)
		for i in range(1, baseline.size()):
			draw_line(Vector2(15+(i-1)*(w-30)/60,15+(1-baseline[i-1].x)*150),Vector2(15+i*(w-30)/60,15+(1-baseline[i].x)*150),Color("#889296"),2)
		return
	for z in range(3):
		draw_style_box(panel(Color("#173d34") if z == 0 else Color("#243747") if z == 1 else Color("#343a51")), Rect2(z*w/3+4, 0, w/3-8, size.y))
	var indices = [0, 0, 0]
	for p in sim.people:
		var z = p.place
		var i = indices[z]
		indices[z] += 1
		var columns = 12
		var x = z*w/3+14+(i%columns)*(w/3-26)/columns
		var y = 20+floori(float(i)/columns)*13
		if y < size.y-10:
			draw_circle(Vector2(x,y),4, Color("#99b9ff") if p.t >= 0.55 and p.e >= 0.55 else Color("#51d6b0") if p.t > p.e else Color("#f4bc68"))

func panel(color: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(12)
	return s
