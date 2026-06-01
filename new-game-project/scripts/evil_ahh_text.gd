extends Label

var char_set = ["a", "b", "c", "d", "e", "f", "g", "h",
"i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
"v", "w", "x", "y", "z"]
# Called when the node enters the scene tree for the first time.
func _get_random_letter_string(length: int) -> String:
	var string_result = ""
	for i in range(length):
		string_result += char_set[randi_range(0, 25)]
	return string_result
		
func _ready() -> void:
	pass # Replace with function body.
	
	print(Marshalls.utf8_to_base64(_get_random_letter_string(25)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(text.length()):
		if randi_range(0, 10000) > 9995:
			if randi_range(0,1) == 0:
				text[i] = _get_random_letter_string(1)
			else:
				text[i] = _get_random_letter_string(1).to_upper()
				
	pass


func _on_timer_timeout() -> void:
	text = Marshalls.utf8_to_base64(_get_random_letter_string(10000))
