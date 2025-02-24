# date_difference_iso_8601

Get the difference in **days**, **weeks**, **months** and **years** between a date and another.

```gdscript

var date_difference = GTLib.date_difference_iso_8601("2022-02-04", "2022-02-11")
print(date_difference) # Prints { "days": 7, "weeks": 1, "months": 0, "years": 0 }

```

# time_from_ms

Converts **ms** to **seconds**, **minutes** and **hours.**
```gdscript

var time = GTLib.time_from_ms(5000)
print(time) # Will print { "seconds": 5, "minutes": 0, "hours": 0 }

```

# time_difference_24h

Get the difference in **hours**, **minutes** and **seconds** between a 24 hour timestamp and another.

```gdscript

var time_difference = GTLib.time_difference_24h("06:25:21", "16:24:39")
print(time_difference) # Will print { "hours": 9, "minutes": 59, "seconds": 18 }

```

# markdown_to_bbcode

`experimental:` **this feature has not been polished nor finished, expect misbehaviour.**\
Converts **markdown** to **BBCode**.
```gdscript

GTLib.markdown_to_bbcode("**This is bold.**") # Returns "[b]This is bold.[/b]"

```

# fetch

Makes an HTTPRequest and returns the response in a dictionary.

```gdscript

var data = await GTLib.fetch("https://httpbin.org/get")
print(data.body.get_string_from_utf8()) # Returns the content

```

# is_upper

Returns `true` if the provided character is uppercase.

```gdscript
GTLib.is_upper("A") # Returns true
```

# rgb_to_normalized

 Converts RGB `(255,255,255)` or RGBA `(255,255,255,1)` to Godot"s color system `(1,1,1,1)`

# get_recommended_resolutions

Returns available resolutions.

`follow_project_size` parameter will return resolutions based in the project window size and display if true.

# img_to_texture

Converts an image to a texture.

```gdscript

var texture = GTLib.img_to_texture("path/to/image.png")
var txr_rect = TextureRect.new()
txr_rect.texture = texture # will assign the texture

```

# play_global_mus

Plays a song globally.

`vol` is a linear volume value, therefore, 1 = 0 decibels.
```gdscript
GTLib.play_global_mus("path/to/song.mp3", 1, "Music") # Will play a song in the audio bus "Music".
```

# stop_global_mus

 Will stop global music if playing.

# pause_global_mus

 Will pause global music if playing.

# resume_global_mus

 Will resume global music if it exists.

# global_mus_jump_to

 Changes the position of the global music.

# grab_music_node()

Returns the music node.

Will return `null` if music is not playing.

# wait

Waits until the time runs out.

`time` uses ms, therefore, 1000ms = 1s.
```gdscript

await GTLib.wait(1000) # Will wait for 1 second before printing "Hello World!"
print("Hello World!")

```

# random_id

 Returns a random integer between `min` and `max`.\
 Exceptions can be added.\
  Will return `-1` if `exceptions` covers all possible numbers.
```gdscript

 GTLib.random_id(1, 100, [50]) # Will give a number from 1 to 100, but will avoid 50.

```

# bbcode_to_markdown

 `experimental:` lacks some markdown features.\
 Convert **BBCode** to **markdown**.
 ```gdscript

GTLib.bbcode_to_markdown("[b]This is bold.[/b]") # Returns "**This is bold.**"

```

# set_mouse_filter

Sets a mouse filter to a node and its children (optional).\
Exceptions can be added.
```gdscript

GTLib.set_mouse_filter($obj, Control.MOUSE_FILTER_IGNORE, true, ["Button"])
# Sets "ignore" filter for obj and its children, except Buttons.

```

# slugify

Converts a string to an url-friendly string.
```gdscript

var string = GTLib.slugify("Hello World ♥", "_", {"♥": "love"})
print(string) # Will print "hello_world_love"

```
