extends Node

## A node that contains methods to make certain stuff faster.

## Get the difference in [b]days[/b], [b]weeks[/b], [b]months[/b] and [b]years[/b] between a date and another.[br]
## Will return an empty dictionary if one of the dates is invalid.
## [codeblock]
## var date_difference = GTLib.date_difference_iso_8601("2022-02-04", "2022-02-11")
## print(date_difference) # Prints { "days": 7, "weeks": 1, "months": 0, "years": 0 }
## [/codeblock]
func date_difference_iso_8601(date_1: String, date_2: String) -> Dictionary:
	var date_split = [date_1.split('-'), date_2.split('-')]
	for i in range(date_split.size()):
		while date_split[i].size() < 3:
			date_split[i].append("1")

	var date_1_dict = {
		"year": int(date_split[0][0]),
		"month": int(date_split[0][1]),
		"day": int(date_split[0][2])
	}

	var date_2_dict = {
		"year": int(date_split[1][0]),
		"month": int(date_split[1][1]),
		"day": int(date_split[1][2])
	}

	var unix_1 = Time.get_unix_time_from_datetime_dict(date_1_dict)
	var unix_2 = Time.get_unix_time_from_datetime_dict(date_2_dict)

	if unix_1 == 0 || unix_2 == 0:
		printerr("invalid date!")
		return {}

	if unix_1 > unix_2:
		var temp = unix_1
		unix_1 = unix_2
		unix_2 = temp

	var days: int = (unix_2 - unix_1) / 86400
	var years = date_2_dict["year"] - date_1_dict["year"]
	var months = (years * 12) + (date_2_dict["month"] - date_1_dict["month"])
	var weeks = days / 7

	return {
		"days": days,
		"weeks": weeks,
		"months": months,
		"years": years,
	}


## Converts [b]ms[/b] to [b]seconds[/b], [b]minutes[/b] and [b]hours.[/b]
## [codeblock]
## var time = GTLib.time_from_ms(5000)
## print(time) # Will print { "seconds": 5, "minutes": 0, "hours": 0 }
## [/codeblock]
func time_from_ms(time_ms: int) -> Dictionary:
	var seconds = int(time_ms / 1000) % 60
	var minutes = int(time_ms / (1000 * 60)) % 60
	var hours = int(time_ms / (1000 * 60 * 60))

	return {
		"seconds": seconds,
		"minutes": minutes,
		"hours": hours,
	}


## Get the difference in [b]hours[/b], [b]minutes[/b] and [b]seconds[/b] between a 24 hour timestamp and another.[br]
## [codeblock]
## var time_difference = GTLib.time_difference_24h("06:25:21", "16:24:39")
## print(time_difference) # Will print { "hours": 9, "minutes": 59, "seconds": 18 }
## [/codeblock]
func time_difference_24h(time_1: String, time_2: String) -> Dictionary:
	var time_split = [time_1.split(":"), time_2.split(":")]

	for i in range(time_split.size()):
		while time_split[i].size() < 3:
			time_split[i].append("00")

	var time1 = (int(time_split[0][0]) * 3600) + (int(time_split[0][1]) * 60) + int(time_split[0][2])
	var time2 = (int(time_split[1][0]) * 3600) + (int(time_split[1][1]) * 60) + int(time_split[1][2])

	if time2 < time1:
		time2 += 86400

	var total_secs = time2 - time1
	var remaining_secs = total_secs % 3600
	var time_diff = [total_secs / 3600, remaining_secs / 60, remaining_secs % 60]

	return {
		"hours": time_diff[0],
		"minutes": time_diff[1],
		"seconds": time_diff[2],
	}


## Converts [b]markdown[/b] to [b]BBCode[/b].
## [br]
## [codeblock]GTLib.markdown_to_bbcode("**This is bold.**") # Returns "[b]This is bold.[/b]"[/codeblock]
func markdown_to_bbcode(string: String) -> String:
	var rules = [
		# images: ![alt](url) -> [img]url[/img]
		{"pattern": "!\\[(.*?)\\]\\((.*?)\\)", "replace": "[img]$2[/img]"},
		# hyperlink: [text](url) -> [url=url]text[/url]
		{"pattern": "\\[(.+?)\\]\\((.+?)\\)", "replace": "[url=$2]$1[/url]"},
		# heading 1: # text -> [font_size=50]text[/font_size]
		{"pattern": "^# (.+)$", "replace": "[b][font_size=50]$1[/font_size][/b]"},
		# heading 2: ## text -> [font_size=45]text[/font_size]
		{"pattern": "^## (.+)$", "replace": "[b][font_size=45]$1[/font_size][/b]"},
		# heading 3: ### text -> [font_size=40]text[/font_size]
		{"pattern": "^### (.+)$", "replace": "[b][font_size=40]$1[/font_size][/b]"},
		# bold italics: ***text*** -> [b][i]text[/i][/b]
		{"pattern": "\\*\\*\\*(.+?)\\*\\*\\*", "replace": "[b][i]$1[/i][/b]"},
		# strikethrough: ~~text~~ -> [s]text[/s]
		{"pattern": "\\~\\~(.+?)\\~\\~", "replace": "[s]$1[/s]"},
		# bold: **text** or __text__ -> [b]text[/b]
		{"pattern": "\\*\\*(.+?)\\*\\*", "replace": "[b]$1[/b]"},
		{"pattern": "\\_\\_(.+?)\\_\\_", "replace": "[b]$1[/b]"},
		# italic: *text* or _text_ -> [i]text[/i]
		{"pattern": "\\*(.+?)\\*", "replace": "[i]$1[/i]"},
		{"pattern": "\\_(.+?)\\_", "replace": "[i]$1[/i]"},
		
		# codeblock: ```code``` -> [codeblock]code[/codeblock]
		#{"pattern": "```(.*?)```", "replace": "[codeblock]$1[/codeblock]"},
		
		# code: `code` -> [code]code[/code]
		{"pattern": "`(.+?)`", "replace": "[code]$1[/code]"},
	]

	for i in rules:
		var regex = RegEx.new()
		var err = regex.compile(i["pattern"])
		if err != OK:
			printerr("error while compiling!")
			return ""
		string = regex.sub(string, i["replace"], true)

	return string


## Makes an HTTPRequest and returns the response in a dictionary.[br]
## [codeblock]
## var data = await GTLib.fetch("https://httpbin.org/get")
## print(data.body.get_string_from_utf8()) # Returns the content
## [/codeblock]
func fetch(url: String = "", headers: PackedStringArray = PackedStringArray(), method: HTTPClient.Method = 0, request_data: String = "") -> Dictionary:
	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, method, request_data)

	var response = await req.request_completed
	req.queue_free()

	return {
		"result": response[0],
		"status_code": response[1],
		"headers": response[2],
		"body": response[3],
	}


## Returns [code]true[/code] if the provided character is uppercase.[br]
## [codeblock]GTLib.is_upper("A") # Returns true[/codeblock]
func is_upper(char: String) -> bool:
	if char.length() > 0:
		if char[0].to_upper() == char[0]:
			return true
		else:
			return false
	else:
		return false


## Converts RGB [code](255,255,255)[/code] or RGBA [code](255,255,255,1)[/code] to Godot's color system [code](1,1,1,1)[/code]
func rgb_to_normalized(red: float, green: float, blue: float, alpha: float = 1) -> Color:
	return Color(red / 255, green / 255, blue / 255, alpha)


## Returns available resolutions.[br]
## [param follow_project_size] parameter will return resolutions based in the project window size and display if true.
func get_recommended_resolutions(follow_project_size: bool = false) -> Array:
	var display = Vector2(DisplayServer.screen_get_size())
	var resolutions = []

	if !follow_project_size:
		resolutions = [
			display / 3.0,
			display / 2.5,
			display / 2.0,
			display / 1.5,
			display,
		]
	else:
		var viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width", -1)
		var viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height", -1)

		if viewport_width <= 0 or viewport_height <= 0:
			printerr("invalid project size settings, using display instead")
			return get_recommended_resolutions()

		var project_size = Vector2(viewport_width, viewport_height)
		resolutions = [
			project_size / 3.0,
			project_size / 2.5,
			project_size / 2.0,
			project_size / 1.5,
			project_size,
		]

		var multiplier = 1.5
		var next = project_size * multiplier

		while next.x <= display.x and next.y <= display.y:
			resolutions.append(next)
			multiplier += 0.5
			next = project_size * multiplier

	return resolutions


## Converts an image to a texture.[br]
## [codeblock]
## var texture = GTLib.img_to_texture("path/to/image.png")
## var txr_rect = TextureRect.new()
## txr_rect.texture = texture # will assign the texture
## [/codeblock]
func img_to_texture(img_path: String) -> ImageTexture:
	if FileAccess.file_exists(img_path):
		var image = Image.new()
		image.load(img_path)

		var texture = ImageTexture.new()
		texture.set_image(image)

		return texture
	else:
		printerr('%s is invalid' % img_path)
		return null


## Plays a song globally.[br]
## [param vol] is a linear volume value, therefore, 1 = 0 decibels.
## [codeblock]GTLib.play_global_mus("path/to/song.mp3", 1, "Music") # Will play a song in the audio bus "Music".
func play_global_mus(music: String, vol: float = 1, bus: String = ''):
	var music_node = AudioStreamPlayer.new()
	music_node.name = "music"

	if grab_music_node():
		printerr("another music instance is running, stop it before trying to play another song")
		return

	add_child(music_node)
	music_node.stream = load(music)

	if bus.length() > 0:
		if AudioServer.get_bus_index(bus) >= 0:
			music_node.bus = bus
		else:
			printerr("bus '%s' does not exist, playing on master instead" % bus)

	await get_tree().process_frame
	music_node.volume_db = linear_to_db(vol)
	music_node.play()


## Will stop global music if playing.
func stop_global_mus():
	var node = grab_music_node()
	if node:
		node.stop()
		node.queue_free()
	else:
		printerr('music node not found, is music playing?')


## Will pause global music if playing.
func pause_global_mus():
	var node = grab_music_node()
	if node:
		if node.playing:
			_playback = node.get_playback_position()
			node.stop()
		else:
			printerr("can not pause music as music is not playing")
	else:
		printerr('music node not found, is music playing?')


## Will resume global music if it exists.
func resume_global_mus():
	var node = grab_music_node()
	if node:
		if _playback:
			node.play()
			global_mus_jump_to(_playback)
			_playback = null
		else:
			return
	else:
		printerr('music node not found, is music playing?')


## Changes the position of the global music.
func global_mus_jump_to(seek: float):
	var node = grab_music_node()
	if node:
		node.seek(seek)
	else:
		printerr('music node not found, is music playing?')


## Returns the music node.[br]
## Will return [code]null[/code] if music is not playing.
func grab_music_node() -> AudioStreamPlayer:
	if get_child_count() > 0:
		for i in get_children():
			if i is AudioStreamPlayer:
				if i.name == "music":
					return i
	return null


## Waits until the time runs out.[br]
## [param time] uses ms, therefore, 1000ms = 1s.
## [codeblock]
## await GTLib.wait(1000) # Will wait for 1 second before printing 'Hello World!'
## print("Hello World!")
## [/codeblock]
func wait(time: int) -> void:
	var timer = Timer.new()
	timer.wait_time = float(time) / float(1000)
	timer.name = str(random_id(100, 500))

	add_child(timer)
	timer.start()

	await timer.timeout
	timer.stop()
	timer.queue_free()
	return


## Returns a random integer between [param min] and [param max].[br]
## Exceptions can be added.[br]
## Will return [code]-1[/code] if [param exceptions] covers all possible numbers.
## [codeblock]
## GTLib.random_id(1, 100, [50]) # Will give a number from 1 to 100, but will avoid 50.
## [/codeblock]
func random_id(min: int, max: int, exceptions: PackedInt32Array = []) -> int:
	if len(exceptions) >= (max - min + 1):
		printerr("'exceptions' contains all values that can be possibly generated, returning -1")
		return -1
	var id = randi_range(min,max)
	return id if id not in exceptions else random_id(min,max,exceptions)


## @experimental: lacks [b]headings[/b] and [b]quoteblocks[/b].
## Convert [b]BBCode[/b] to [b]markdown[/b].[br]
## [codeblock]GTLib.bbcode_to_markdown("[b]This is bold.[/b]") # Returns "**This is bold.**"[/codeblock]
func bbcode_to_markdown(string: String, lang: String = "") -> String:
	var rules = [
		# images: [img]url[/img] -> ![alt](url)
		{"pattern": "\\[img](.+?)\\[/img]", "replace": "![]($1)"},
		# hyperlink: [url=url]text[/url] -> [text](url)
		{"pattern": "\\[url=(.+?)](.+?)\\[/url]", "replace": "[$2]($1)"},
		# bold italics: [b][i]text[/i][/b] -> ***text***
		{"pattern": "\\[b]\\[i](.+?)\\[/i]\\[/b]", "replace": "***$1***"},
		# strikethrough: [s]text[/s] -> ~~text~~
		{"pattern": "\\[s](.+?)\\[/s]", "replace": "~~$1~~"},
		# bold: [b]text[/b] -> **text**
		{"pattern": "\\[b](.+?)\\[/b]", "replace": "**$1**"},
		# italic: [i]text[/i] -> *text*
		{"pattern": "\\[i](.+?)\\[/i]", "replace": "*$1*"},
		# codeblock: [codeblock]code[/codeblock] -> 
		# ```lang 
		# code
		# ```
		{"pattern": "\\[codeblock](.+?)\\[/codeblock]", "replace": "```%s\n$1\n```" % lang},
		# code: [code]code[/code] -> `code`
		{"pattern": "\\[code](.+?)\\[/code]", "replace": "`$1`"},
	]

	for i in rules:
		var regex = RegEx.new()
		var err = regex.compile(i["pattern"])
		if err != OK:
			printerr("error while compiling!")
			return ""
		string = regex.sub(string, i["replace"], true)
	
	return string


## Sets a mouse filter to a node and its children (optional).[br]
## Exceptions can be added.
## [codeblock]
## # Sets "ignore" filter for obj and its children, except Buttons.
## GTLib.set_mouse_filter($obj, Control.MOUSE_FILTER_IGNORE, true, ["Button"])
## [/codeblock]
func set_mouse_filter(node: Node, filter : Control.MouseFilter, children: bool = false, exceptions: PackedStringArray = []) -> void:
	if !_is_type(node, exceptions):
		if "mouse_filter" in node:
			node.mouse_filter = filter

	if children:
		if node.get_child_count() > 0:
			for i in node.get_children():
				if i.get_child_count() > 0:
					set_mouse_filter(i, filter, children, exceptions)
				if _is_type(i, exceptions):
					continue
				if "mouse_filter" in i:
					i.mouse_filter = filter


## Converts a string to an url-friendly string.
## [codeblock]
## var string = GTLib.slugify("Hello World ♥", "_", {"♥": "love"})
## print(string) # Will print "hello_world_love"
## [/codeblock]
func slugify(string: String, delimiter: String = "-", extend: Dictionary = {}) -> String:
	var index = 0
	var result = ''
	var available = []
	for i in range(97, 123):
		available.append(char(i))
	for i in range(48, 58):
		available.append(char(i))

	while index < string.length():
		if string[index] == " ":
			result += delimiter
			index += 1
			continue
		elif string[index] in extend:
			if !_are_in(string[index], extend, available):
				index += 1
				continue
			result += extend[string[index]].to_lower()
			index += 1
			continue
		elif string[index] not in available:
			if string[index].to_lower() in available:
				result += string[index].to_lower()
				index += 1
				continue
			else:
				index += 1
				continue

		result += string[index]
		index += 1

	return result


## Returns a node from the scene tree by following a custom path format using [code]" > "[/code] as a separator.[br]
## By default, it will get nodes from the root node.[br]
## [param starting_node] defines the node it will start getting nodes from.[br]
## Will return [code]null[/code] if a node doesn't exist.[br]
## 
## [codeblock]
## # Assuming a scene structure like this:
## ┖ root
##    ┖╴player
##       ┠ camera
##       ┖ weapon
## [/codeblock]
## [codeblock]
## var found_node = node("player > camera") # Will return the camera node
## [/codeblock]
func node(path: String, starting_node: Node = get_tree().current_scene):
	var nodes = path.split(" > ")
	var prev_node = starting_node
	for i in nodes:
		if prev_node:
			prev_node = prev_node.get_node(i)
			if !prev_node:
				printerr("'%s' not found!" % i)
				return null
		else:
			return null

	return prev_node


## Returns the number of differences between a string and another.[br]
## [codeblock]
## var text1 = "kitten"
## var text2 = "sitting"
## print(GTLib.text_distance(text1, text2)) # Will print "3"
## [/codeblock]
func text_distance(string: String, string2: String) -> int:
	var length1 = string.length()
	var length2 = string2.length()

	var prev_row = range(length2 + 1)
	var current_row = range(length2 + 1)

	for i in range(length2 + 1):
		prev_row.append(i)
		current_row.append(0)

	for i in range(1, length1 + 1):
		current_row[0] = i

		for j in range(1, length2 + 1):
			if string[i - 1] == string2[j - 1]:
				current_row[j] = prev_row[j - 1]
			else:
				current_row[j] = 1 + min(
					current_row[j - 1],
					prev_row[j],
					prev_row[j - 1],
				)

		prev_row = current_row.duplicate()

	return current_row[length2]


var _playback = null


func _are_in(string, dict, array):
	for i in dict[string]:
		if i.to_lower() not in array:
			return false
	return true


func _is_type(node, types):
	for e in range(types.size()):
		if node.get_class() == types[e]:
			return true
	return false
