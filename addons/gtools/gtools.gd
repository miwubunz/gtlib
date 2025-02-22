extends Node

## A node that contains methods to make development faster.

var _playback = null

## Get the difference in [b]days[/b], [b]weeks[/b], [b]months[/b] and [b]years[/b] between a date and another.[br]
## [codeblock]
## var date_difference = GTools.date_difference_iso_8601("2022-02-04", "2022-02-11")
## print(date_difference) # Prints { "days": 7, "weeks": 1, "months": 0, "years": 0 }
## [/codeblock]
func date_difference_iso_8601(date_1: String, date_2: String) -> Dictionary:
	var date_split = [date_1.split('-'), date_2.split('-')]
	
	var unix_1 = Time.get_unix_time_from_datetime_dict({
		"years": date_split[0][0],
		"month": date_split[0][1],
		"day": date_split[0][2]
	})

	var unix_2 = Time.get_unix_time_from_datetime_dict({
		"years": date_split[1][0],
		"month": date_split[1][1],
		"day": date_split[1][2]
	})
	
	var days: int = int(unix_2 - unix_1) / 86400
	var weeks = int(days / 7)
	var months: int = int(date_split[1][1]) - int(date_split[0][1])
	var years: int = int(date_split[1][0]) - int(date_split[0][0])
	
	return {
		"days": days,
		"weeks": weeks,
		"months": months,
		"years": years
	}

## @experimental: [b]this feature has not been polished, expect misbehaviour.[/b]
## Converts [b]markdown[/b] to [b]BBCode[/b].
## [br]
## [codeblock]GTools.markdown_to_bbcode("**This is bold.**") # Returns "[b]This is bold.[/b]"[/codeblock]
func markdown_to_bbcode(string: String) -> String:
	if string.contains("****"):
		string = string.replace("****", "")
	var result = ""
	var index = 0
	var stack = []
	var heading = false

	while index < string.length():
		# bold italics
		if string.substr(index, 3) == "***":
			if stack.size() > 0 and stack[-1] == "b+i":
				result += "[/i][/b]"
				stack.pop_back()
			else:
				result += "[b][i]"
				stack.append("b+i")
			index += 3
			continue

		# bold
		elif string.substr(index, 2) == "**":
			if stack.size() > 0 and stack[-1] == "b":
				result += "[/b]"
				stack.pop_back()
			else:
				result += "[b]"
				stack.append("b")
			index += 2
			continue

		# italics
		elif string[index] == "*":
			if stack.size() > 0 and stack[-1] == "i":
				result += "[/i]"
				stack.pop_back()
			else:
				result += "[i]"
				stack.append("i")
			index += 1
			continue

		# code
		elif string[index] == "`":
			if stack.size() > 0 and stack[-1] == "code":
				result += "[/code]"
				stack.pop_back()
			else:
				result += "[code]"
				stack.append("code")
			index += 1
			continue

		# heading
		elif string[index] == "#":
			if stack.size() > 0 and stack[-1] == "heading":
				result += "[/font_size]"
				stack.pop_back()
				heading = false
			else:
				result += "[font_size=50]"
				stack.append("heading")
				heading = true
			index += 1
			continue

		# newline
		elif string[index] == "\n" and heading:
			if stack.size() > 0 and stack[-1] == "heading":
				result += "[/font_size]"
				stack.pop_back()
				heading = false

		# images
		elif string[index] == "!" and index + 1 < string.length() and string[index + 1] == "[":
			index += 2
			var img = ""
			var on_parentheses = false

			while index < string.length():
				if not on_parentheses:
					if string[index] == "]":
						index += 1
						continue
					elif string[index] == "(":
						on_parentheses = true
						index += 1
						continue
				else:
					if string[index] == ")":
						on_parentheses = false
						index += 1
						break
					img += string[index]
				index += 1

			result += "[img]%s[/img]" % img
			continue

		# links
		elif string[index] == "[":
			index += 1
			var title = ""
			var url = ""
			var on_parentheses = false

			while index < string.length():
				if not on_parentheses:
					if string[index] == "]":
						index += 1
						continue
					elif string[index] == "(":
						on_parentheses = true
						index += 1
						continue
					title += string[index]
				else:
					if string[index] == ")":
						on_parentheses = false
						index += 1
						break
					url += string[index]
				index += 1

			result += "[url=%s]%s[/url]" % [url, title]
			continue

		result += string[index]
		index += 1

	while stack.size() > 0:
		var last_tag = stack.pop_back()
		if last_tag == "b":
			result += "[/b]"
		elif last_tag == "i":
			result += "[/i]"
		elif last_tag == "b+i":
			result += "[/i][/b]"
		elif last_tag == "code":
			result += "[/code]"
		elif last_tag == "heading":
			result += "[/font_size]"

	return result

## Makes an HTTPRequest and returns the response in a dictionary.[br]
## [codeblock]
## var data = await GTools.fetch("https://httpbin.org/get")
## print(data.body.get_string_from_utf8()) # Returns the content
## [/codeblock]
func fetch(url: String = "", headers: PackedStringArray = PackedStringArray(), method: HTTPClient.Method = 0, request_data: String = "") -> Dictionary:
	var req = HTTPRequest.new()
	add_child(req)
	req.request(url, headers, method, request_data)
	
	var response = await req.request_completed
	#print(response)
	req.queue_free()
	return {
		"result": response[0],
		"status_code": response[1],
		"headers": response[2],
		"body": response[3]
	}

## Returns [code]true[/code] if the character provided is uppercase.[br]
## [codeblock]GTools.is_upper("A") # Returns true[/codeblock]
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
		resolutions = [display / 3.0, display / 2.5, display / 2.0, display / 1.5, display]
	else:
		var viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width", -1)
		var viewport_height = ProjectSettings.get_setting("display/window/size/viewport_height", -1)
		
		if viewport_width <= 0 or viewport_height <= 0:
			printerr("invalid project size settings, using display instead")
			return get_recommended_resolutions()
		
		var project_size = Vector2(viewport_width, viewport_height)
		#print("project size: %s" % project_size)
		resolutions = [project_size / 3.0, project_size / 2.5, project_size / 2.0, project_size / 1.5, project_size]

		var multiplier = 1.5
		var next = project_size * multiplier

		while next.x <= display.x and next.y <= display.y:
			resolutions.append(next)
			multiplier += 0.5
			next = project_size * multiplier

	return resolutions

## Converts an image to a texture.[br]
## [codeblock]
## var texture = GTools.img_to_texture("path/to/image.png")
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
## [param vol] is linear, therefore, 1 = 0 decibels.
## [codeblock]GTools.play_global_mus("path/to/song.mp3", 1, "Music") # Will play a song in the audio bus "Music".
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
	#print("loaded song")
	await get_tree().process_frame
	music_node.volume_db = linear_to_db(vol)
	music_node.play()
	#print("playing song %s with %s volume" % [music, vol])

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

## Will resume global music if exists.
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
## await GTools.wait(1000) # Will wait for 1 second before printing 'Hello World!'
## print("Hello World!")
## [/codeblock]
func wait(time: int) -> void:
	var timer = Timer.new()
	timer.wait_time = time / 1000
	timer.name = str(random_id(100, 500))
	
	add_child(timer)
	timer.start()
	
	await timer.timeout
	timer.stop()
	timer.queue_free()
	return

## Returns a random integer between [param min] and [param max].[br]
## Exceptions can be added.[br]
## [codeblock]
## GTools.random_id(1,100,[50]) # Will give a number from 1 to 100, but will avoid 50.
## [/codeblock]
func random_id(min: int, max: int, exceptions: Array = []) -> int:
	if len(exceptions) >= (max - min + 1):
		printerr("'exceptions' contains all values that can be possibly generated, returning -1")
		return -1
	var id = randi_range(min,max)
	return id if id not in exceptions else random_id(min,max,exceptions)

## @experimental: lacks some markdown features.
## Convert [b]BBCode[/b] to [b]markdown[/b].[br]
## [codeblock]GTools.bbcode_to_markdown("[b]This is bold.[/b]") # Returns "**This is bold.**"[/codeblock]
func bbcode_to_markdown(string: String, lang: String = "") -> String:
	var map := {
		"[b]": "**", "[/b]": "**",
		"[i]": "*", "[/i]": "*",
		"[br]": "\n",
		"[codeblock]": "```%s\n" % lang, "[/codeblock]": "\n```"
	}
	
	var result = string
	
	for i in map:
		result = result.replace(i, map[i])
	return result
