extends Node

var _ambient_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_pool_size: int = 8
var _sfx_index: int = 0

var _cached_sounds: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for i in range(_sfx_pool_size):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)

	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Master"
	_ambient_player.volume_db = -12.0
	add_child(_ambient_player)

	_cached_sounds["chime"] = _generate_tone(659.25, 0.6, 0.01, 0.55, 0.4)
	_cached_sounds["chime_high"] = _generate_tone(880.0, 0.7, 0.01, 0.65, 0.35)
	_cached_sounds["jump"] = _generate_glide(220.0, 440.0, 0.22, 0.25)
	_cached_sounds["phase_on"] = _generate_glide(260.0, 520.0, 0.35, 0.3, true)
	_cached_sounds["phase_off"] = _generate_glide(520.0, 260.0, 0.3, 0.25, true)
	_cached_sounds["click"] = _generate_tone(400.0, 0.06, 0.005, 0.05, 0.2)
	_cached_sounds["switch"] = _generate_tone(523.25, 0.18, 0.01, 0.15, 0.35)
	_cached_sounds["flutter"] = _generate_noise(0.12, 0.15)
	_cached_sounds["tick"] = _generate_tone(880.0, 0.04, 0.002, 0.038, 0.25)
	_cached_sounds["alarm"] = _generate_glide(550.0, 880.0, 0.35, 0.45)
	_cached_sounds["fanfare"] = _generate_arpeggio([523.25, 659.25, 783.99, 1046.5], 0.15, 0.4)
	_cached_sounds["ascension"] = _generate_arpeggio([440.0, 554.37, 659.25, 880.0, 1108.73, 1318.51], 0.2, 0.35)

func play_sfx(sound_name: String, pitch_scale: float = 1.0) -> void:
	if not _cached_sounds.has(sound_name):
		return
	var stream: AudioStreamWAV = _cached_sounds[sound_name]
	var player = _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_pool_size

	player.stream = stream
	player.pitch_scale = pitch_scale
	player.play()

func play_chime(pitch: float = 1.0) -> void:
	play_sfx("chime", pitch)

func play_jump() -> void:
	play_sfx("jump", randf_range(0.95, 1.05))

func play_phase(is_phasing: bool) -> void:
	if is_phasing:
		play_sfx("phase_on", 1.0)
	else:
		play_sfx("phase_off", 1.0)

func play_click() -> void:
	play_sfx("click", randf_range(0.9, 1.1))

func play_tick() -> void:
	play_sfx("tick", 1.0)

func play_alarm() -> void:
	play_sfx("alarm", 1.0)

func play_switch() -> void:
	play_sfx("switch", 1.0)

func play_fanfare() -> void:
	play_sfx("fanfare", 1.0)

func play_ascension() -> void:
	play_sfx("ascension", 1.0)

func start_ambient() -> void:
	pass

func stop_ambient() -> void:
	if _ambient_player and _ambient_player.playing:
		_ambient_player.stop()

func _generate_tone(freq: float, duration: float, attack: float, decay: float, amp: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t = float(i) / sample_rate
		var env = 1.0
		if t < attack:
			env = t / attack
		else:
			var rel_t = (t - attack) / max(0.001, (duration - attack))
			env = max(0.0, 1.0 - rel_t)
			env = pow(env, 2.0)

		var val = sin(t * freq * TAU) * 0.7 + sin(t * freq * 2.0 * TAU) * 0.2 + sin(t * freq * 3.0 * TAU) * 0.1
		val *= env * amp
		val = clamp(val, -1.0, 1.0)

		var sample_16 = int(val * 32767.0)
		bytes.encode_s16(i * 2, sample_16)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_glide(freq_start: float, freq_end: float, duration: float, amp: float, is_resonant: bool = false) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(total_samples * 2)

	var phase: float = 0.0
	for i in range(total_samples):
		var t = float(i) / total_samples
		var current_freq = lerp(freq_start, freq_end, t)
		phase += (current_freq / sample_rate) * TAU

		var env = sin(t * PI)
		var val = sin(phase)
		if is_resonant:
			val = (val + sin(phase * 1.5) * 0.4 + sin(phase * 0.5) * 0.3) * 0.6
		val *= env * amp
		val = clamp(val, -1.0, 1.0)

		var sample_16 = int(val * 32767.0)
		bytes.encode_s16(i * 2, sample_16)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_noise(duration: float, amp: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t = float(i) / total_samples
		var env = max(0.0, 1.0 - t)
		var val = randf_range(-1.0, 1.0) * env * amp
		var sample_16 = int(val * 32767.0)
		bytes.encode_s16(i * 2, sample_16)

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_arpeggio(freqs: Array, note_duration: float, amp: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_duration = note_duration * freqs.size() + 0.5
	var total_samples: int = int(sample_rate * total_duration)
	var bytes = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		bytes.encode_s16(i * 2, 0)

	for note_idx in range(freqs.size()):
		var freq: float = freqs[note_idx]
		var start_sample = int(note_idx * note_duration * sample_rate)
		var note_len_samples = int(0.7 * sample_rate)

		for s in range(note_len_samples):
			var idx = start_sample + s
			if idx >= total_samples:
				break
			var t = float(s) / sample_rate
			var env = exp(-t * 4.0)
			var val = (sin(t * freq * TAU) + sin(t * freq * 2.0 * TAU) * 0.3) * env * amp

			var existing = bytes.decode_s16(idx * 2) / 32767.0
			var combined = clamp(existing + val, -1.0, 1.0)
			bytes.encode_s16(idx * 2, int(combined * 32767.0))

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav

func _generate_drone(base_freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t = float(i) / sample_rate
		var val1 = sin(t * base_freq * TAU) * 0.4
		var val2 = sin(t * (base_freq * 1.5) * TAU) * 0.3
		var val3 = sin(t * (base_freq * 2.0) * TAU) * 0.2
		var slow_pulse = 0.8 + 0.2 * sin(t * 0.5 * TAU)

		var sample = (val1 + val2 + val3) * slow_pulse * 0.3
		bytes.encode_s16(i * 2, int(sample * 32767.0))

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = bytes
	return wav
