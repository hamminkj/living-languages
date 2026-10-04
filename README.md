# Living Languages

A touch-first Godot 4.5.1 prototype by TuJuJu Studios.

## Play in Godot

Extract this folder, import project.godot in Godot 4.5.1 or a compatible newer
Godot 4 release, and press F6 or F5. No plugins or external assets are required.

## Play on a phone

Use the accompanying Web build after hosting it. The project source itself is
not an Android APK or an iPhone app.

1. Upload the Web ZIP to an HTML game project on itch.io.
2. Choose "This file will be played in the browser".
3. Enable mobile support and use a portrait-friendly embedded frame or fullscreen.
4. Open the published game URL on the phone.

The Web ZIP must have index.html at its root and all accompanying files.
Do not open index.html directly from a phone's file manager.
Single-threaded Compatibility rendering is configured for the browser.
Mobile browser performance varies. Touch controls and rendering were checked in a Chromium browser at 390 x 844 with touch emulation. This build has not been tested on physical phones.

To rebuild: install the matching Godot export templates, then use Project >
Export > Web and export index.html. The included export preset enables PWA
support. Hosting this on HTTPS allows supported browsers to offer home-screen
installation. Native Android and iOS exports require separate platform setup.

## Controls

Use Set up, Observe and About tabs. Scroll vertically. Use sliders and large buttons; no keyboard or dragging
objects is required. Run advances one simulated year every 0.35 seconds.
Pause allows interventions. +1 year pauses and advances exactly one year.
Restart applies the current settings and repeats the same seed.
New seed changes the initial population and random event sequence.
Keep comparison retains the current home-use curve in gray until the session ends.
There is no persistent saved game in this version.

## Challenges

Free exploration; Taluma home-use above 75%; bilingual residents above 50%;
or a home/work use gap above 17 percentage points.
Targets are checked against the current state, including the starting year.
A target reached early can subsequently be lost.

## Simulation assumptions

240 residents begin in three districts. Each has age, district and two language
proficiencies. Learning depends on home use, job incentives and schooling.
Low exposure produces slow attrition. Children emphasize home and school.
Adults emphasize home and work. Proficiency affects subsequent language use,
forming a feedback loop. Home use is an expected probability, not an observed
count of conversations. Bilingual means both proficiencies are at least 0.55.

Contacts mix district language prevalence with community prevalence. The model
uses district aggregates rather than persistent person-to-person network edges.
Births, deaths, English-speaking migration and relocation alter the population.
Drought probability and ecosystem decline depend on pressure. Ecosystem recovery
is limited; declining health increases rural relocation to town, where work
incentives differ. All environmental effects on language are mediated by the
specified relocation and livelihood assumptions.

Taluma is a fictional language sketch, with six sample words and SVO word order.
This prototype simulates language proficiency and domain use. It does not
simulate borrowing, syntax change, pidginization or creole emergence.
Outcome labels are illustrative game thresholds. Domain separation alone
does not establish sociolinguistic diglossia.

Parameters are invented for exploration, not estimates from real research.
The model must not be used to predict any actual language community.

## Repeatable experiments

Keep the seed fixed, save a comparison at year 60, change one slider and restart.
Compare trajectories. Identical settings and seed reproduce identical runs.
Changed policies can also change later random-event sequences because movement
and demographic branches consume random draws. The seed is not a guarantee
of identical shocks under different policies.

## Verification

Godot headless import and launch; 60-year bounds, reproducibility and
policy-sensitivity checks in test_model.gd, plus portrait layout and control checks in test_ui.gd. Run:

godot --headless --path . --script res://test_model.gd

## License

Project code and text may be used, modified and distributed for your teaching
and TuJuJu Studios projects. Godot runtime distribution terms remain separate.
See the engine's license notices in the Web export.
