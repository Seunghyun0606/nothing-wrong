## Sound effects and office ambience, synthesized at startup so the game ships no
## audio files. Respects Settings.sound.
extends Node

const RATE := 22050

var _players := {}
var _ambience: AudioStreamPlayer


func _ready() -> void:
	_add("message", _tones([[880.0, 0.09], [1318.5, 0.16]], 0.22))
	_add("capture", _shutter())
	_add("success", _tones([[659.3, 0.09], [784.0, 0.09], [1046.5, 0.22]], 0.2))
	_add("fail", _tones([[392.0, 0.12], [311.1, 0.24]], 0.2))
	_add("discover", _tones([[523.3, 0.08], [784.0, 0.08], [987.8, 0.08], [1318.5, 0.26]], 0.16))
	_add("click", _tones([[1760.0, 0.025]], 0.08))
	_ambience = AudioStreamPlayer.new()
	_ambience.stream = _office_hum()
	_ambience.volume_db = -20.0
	add_child(_ambience)
	Settings.sound_changed.connect(_apply_setting)


func play(name: String) -> void:
	if Settings.sound and _players.has(name):
		_players[name].play()


func start_ambience() -> void:
	if Settings.sound and not _ambience.playing:
		_ambience.play()


func stop_ambience() -> void:
	_ambience.stop()


func _apply_setting() -> void:
	if not Settings.sound:
		_ambience.stop()


func _add(name: String, stream: AudioStreamWAV) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	_players[name] = player


static func _wav(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for index in samples.size():
		bytes.encode_s16(index * 2, int(clampf(samples[index], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = bytes
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = samples.size()
	return stream


## A sequence of soft sine notes: [[frequency, seconds], ...].
static func _tones(notes: Array, volume: float) -> AudioStreamWAV:
	var samples := PackedFloat32Array()
	for note in notes:
		var count := int(RATE * float(note[1]))
		for index in count:
			var t := float(index) / RATE
			var envelope := minf(1.0, t * 200.0) * exp(-t * 9.0)
			samples.append(sin(TAU * float(note[0]) * t) * envelope * volume)
	return _wav(samples)


static func _shutter() -> AudioStreamWAV:
	var samples := PackedFloat32Array()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for index in int(RATE * 0.12):
		var t := float(index) / RATE
		var burst := exp(-t * 60.0) + 0.6 * exp(-absf(t - 0.06) * 120.0)
		samples.append(rng.randf_range(-1.0, 1.0) * burst * 0.18)
	return _wav(samples)


## Two seconds of low, filtered noise with a faint mains hum, looped.
static func _office_hum() -> AudioStreamWAV:
	var samples := PackedFloat32Array()
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var brown := 0.0
	var count := RATE * 2
	for index in count:
		brown = clampf(brown + rng.randf_range(-0.02, 0.02), -1.0, 1.0) * 0.998
		var t := float(index) / RATE
		samples.append(brown * 0.5 + sin(TAU * 60.0 * t) * 0.02)
	return _wav(samples, true)
