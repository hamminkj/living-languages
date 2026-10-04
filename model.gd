extends RefCounted

# Stylized mechanisms, not fitted predictions of real populations.
var rng = RandomNumberGenerator.new()
var people: Array = []
var year = 0
var ecology = 0.85
var history: Array = []
var events: Array = []
var settings = {"start": 60.0, "school": 50.0, "jobs": 50.0, "ties": 50.0, "migration": 20.0, "stress": 20.0}
var home = 0.0
var work = 0.0
var bilingual = 0.0

func reset(config: Dictionary, random_seed: int = 42):
	settings = config.duplicate()
	rng.seed = random_seed
	year = 0
	ecology = 0.85
	people.clear()
	history.clear()
	events.clear()
	for i in range(240):
		var taluma = rng.randf() < settings.start / 100.0
		people.append({"t": 0.95 if taluma else 0.15, "e": 0.15 if taluma else 0.95, "place": i % 3, "age": rng.randi_range(0, 70)})
	measure()

func choose_t(p: Dictionary, influence: float) -> float:
	return clampf(0.5 + (p.t - p.e) * 0.65 + (influence - 0.5) * 0.7, 0.0, 1.0)

func step():
	if year >= 60:
		return
	year += 1
	var shock = rng.randf() < settings.stress / 100.0 * 0.28
	ecology = clampf(ecology + 0.035 - settings.stress / 100.0 * 0.045 - (0.16 if shock else 0.0), 0.1, 1.0)
	if shock:
		events.push_front("Year %d: drought disrupts rural livelihoods; some families move to town." % year)
	var local = [0.0, 0.0, 0.0]
	var counts = [0, 0, 0]
	for p in people:
		local[p.place] += choose_t(p, 0.5)
		counts[p.place] += 1
	for z in range(3):
		local[z] /= maxf(1.0, counts[z])
	var next: Array = []
	for p in people:
		var q: Dictionary = p.duplicate()
		q.age += 1
		if q.age > 75 and rng.randf() < 0.16:
			continue
		if q.place == 0 and rng.randf() < (1.0 - ecology) * 0.15:
			q.place = 2
		elif rng.randf() < settings.ties / 100.0 * 0.04:
			q.place = rng.randi_range(0, 2)
		var network = lerpf(local[q.place], home, settings.ties / 100.0)
		var home_use = choose_t(q, network)
		var work_pressure = clampf(settings.jobs / 100.0 + (0.12 * ecology if q.place == 0 else -0.10), 0.0, 1.0)
		var public_use = choose_t(q, work_pressure)
		var exposure = 0.55 * home_use + 0.45 * public_use
		if q.age < 19:
			exposure = 0.4 * home_use + 0.6 * settings.school / 100.0
		# Both languages can grow with exposure; little use causes gradual attrition.
		q.t = clampf(q.t + 0.09 * exposure * (1.0 - q.t) - 0.025 * (1.0 - exposure) * q.t, 0, 1)
		q.e = clampf(q.e + 0.09 * (1.0 - exposure) * (1.0 - q.e) - 0.025 * exposure * q.e, 0, 1)
		next.append(q)
		if q.age >= 23 and q.age <= 37 and rng.randf() < 0.045 and next.size() < 360:
			next.append({"t": 0.25 + 0.45 * home_use, "e": 0.25 + 0.45 * (1.0 - home_use), "place": q.place, "age": 0})
	for i in range(int(settings.migration / 100.0 * 7.0)):
		if next.size() < 360:
			next.append({"t": 0.12, "e": 0.95, "place": 2, "age": rng.randi_range(18, 40)})
	people = next
	measure()

func measure():
	home = 0.0
	work = 0.0
	bilingual = 0.0
	for p in people:
		home += choose_t(p, 0.5)
		var pressure = clampf(settings.jobs / 100.0 + (0.12 * ecology if p.place == 0 else -0.10), 0.0, 1.0)
		work += choose_t(p, pressure)
		if p.t >= 0.55 and p.e >= 0.55:
			bilingual += 1
	var n = maxf(1, people.size())
	home /= n
	work /= n
	bilingual /= n
	history.append(Vector3(home, work, bilingual))

func outcome() -> String:
	if home > 0.75:
		return "Taluma dominates home life"
	if home < 0.25:
		return "English dominates home life"
	if absf(home - work) > 0.17:
		return "Different languages dominate different settings"
	if bilingual > 0.5:
		return "Widespread bilingualism"
	return "Languages coexist; the balance is changing"
