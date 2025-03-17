#include "gtlib.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/reg_ex.hpp>
#include <godot_cpp/classes/http_request.hpp>
#include <godot_cpp/classes/http_client.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/timer.hpp>
#include <godot_cpp/classes/http_client.hpp>


using namespace godot;


Dictionary GTLib::date_difference_iso_8601(String date_1, String date_2) {
    Array date_split_1 = date_1.split("-");
    Array date_split_2 = date_2.split("-");

    while (date_split_1.size() < 3) date_split_1.append("1");
    while (date_split_2.size() < 3) date_split_2.append("1");

    Dictionary date_1_dict;
    date_1_dict["year"] = int(date_split_1[0]);
    date_1_dict["month"] = int(date_split_1[1]);
    date_1_dict["day"] = int(date_split_1[2]);

    Dictionary date_2_dict;
    date_2_dict["year"] = int(date_split_2[0]);
    date_2_dict["month"] = int(date_split_2[1]);
    date_2_dict["day"] = int(date_split_2[2]);

    int unix_1 = Time::get_singleton()->get_unix_time_from_datetime_dict(date_1_dict);
    int unix_2 = Time::get_singleton()->get_unix_time_from_datetime_dict(date_2_dict);

    if ((unix_1 == 0 && date_1 != "1970-01-01") || (unix_2 == 0 && date_2 != "1970-01-01")) {
        UtilityFunctions::printerr("invalid date!");
        return Dictionary();
    }

    if (unix_1 > unix_2) {
        int temp = unix_1;
        unix_1 = unix_2;
        unix_2 = temp;
    }

    int days = (unix_2 - unix_1) / 86400;
    int years = (int)days / 365;
    //int years = (int)date_2_dict["year"] - (int)date_1_dict["year"];
    int months = (int)days / 30.436768;
    int weeks = days / 7;

    Dictionary returner;
    returner["days"] = days;
    returner["weeks"] = weeks;
    returner["months"] = months;
    returner["years"] = years;

    return returner;
}


int GTLib::get_days_in_month(int month, int year) {
    if (month < 1 || month > 12) {
        return 0;
    }

    switch(month) {
        case 4: case 6: case 9: case 11:
            return 30;
        case 2:
            return (is_leap_year(year)) ? 29 : 28;
        default:
            return 31;
    }

    return 0;
}


bool GTLib::is_leap_year(int year) {
    if (year % 4 != 0) {
        return false;
    } else if (year % 100 != 0) {
        return true;
    } else {
        return (year % 400 == 0);
    }
}


Dictionary GTLib::time_from_ms(int time_ms) {
    int seconds = (int)time_ms / 1000 % 60;
    int minutes = (int)time_ms / 60000 % 60;
    int hours = (int)time_ms / 3600000;

    Dictionary returner;
    returner["seconds"] = seconds;
    returner["minutes"] = minutes;
    returner["hours"] = hours;

    return returner;
}


Dictionary GTLib::time_difference_24h(String time_1, String time_2) {
    Array time_split_1 = time_1.split(":");
    Array time_split_2 = time_2.split(":");

    while (time_split_1.size() < 3) time_split_1.append("00");
    while (time_split_2.size() < 3) time_split_2.append("00");

    int time1 = (int)time_split_1[0] * 3600 + (int)time_split_1[1] * 60 + (int)time_split_1[2];
    int time2 = (int)time_split_2[0] * 3600 + (int)time_split_2[1] * 60 + (int)time_split_2[2];

    if (time2 < time1) {
        time2 += 86400;
    }

    int total_secs = time2 - time1;
    int remaining_secs = total_secs % 3600;
    PackedInt32Array time_diff = {total_secs / 3600, remaining_secs / 60, remaining_secs % 60};

    Dictionary returner;
    returner["hours"] = time_diff[0];
    returner["minutes"] = time_diff[1];
    returner["seconds"] = time_diff[2];

    return returner;
}


String GTLib::markdown_to_bbcode(String markdown, int heading_size, int heading_decrease) {
    Dictionary rules;
    // center: <center> -> [center]
    rules["\\<center>(.+)\\<\\/center>"] = "[center]$1[/center]";
    // images: ![alt](url) -> [img]url[/img]
    rules["!\\[(.*?)\\]\\((.*)\\)"] = "[img tooltip=$1]$2[/img]";
    // hyperlink: [text](url) -> [url=url]text[/url]
    rules["\\[(.+?)\\]\\((.+?)\\)"] = "[url=$2]$1[/url]";
    // bold italics: ***text*** -> [b][i]text[/i][/b]
    rules["\\*\\*\\*(.+?)\\*\\*\\*"] = "[b][i]$1[/i][/b]";
    // strikethrough: ~~text~~ -> [s]text[/s]
    rules["\\~\\~(.+?)\\~\\~"] = "[s]$1[/s]";
    // bold: **text** or __text__ -> [b]text[/b]
    rules["\\*\\*(.+?)\\*\\*"] = "[b]$1[/b]";
    rules["\\_\\_(.+?)\\_\\_"] = "[b]$1[/b]";
    // italic: *text* or _text_ -> [i]text[/i]
    rules["\\*(.+?)\\*"] = "[i]$1[/i]";
    rules["\\_(.+?)\\_"] = "[i]$1[/i]";
    // unordered list: - text -> [ul] text[/ul]
    rules["^\\-(.+?)(\\n|$)"] = "[ul]$1[/ul][p][/p]";

    // code: `text` -> [code]text[/code]
    rules["`(.+)`"] = "[code]$1[/code]";
    // heading 3: ### text -> [font_size=30]text[/font_size]
    rules["(?m)^### (.+?)(\\n|$)"] = String("[b][font_size={0}]$1[/font_size][/b][p][/p]").format(Array::make(heading_size - (heading_decrease * 2)));
    // heading 2: ## text -> [font_size=35]text[/font_size]
    rules["(?m)^## (.+?)(\\n|$)"] = String("[b][font_size={0}]$1[/font_size][/b][p][/p]").format(Array::make(heading_size - heading_decrease));
    // heading 1: # text -> [font_size=40]text[/font_size]
    rules["(?m)^# (.+?)(\\n|$)"] = String("[b][font_size={0}]$1[/font_size][/b][p][/p]").format(Array::make(heading_size));
    // newlines
    rules["\\\\\\s*([^\n]+)$"] = "[p]$1[/p]";
    // replace newlines with tabs
    rules["\\\n"] = " ";

    for (int i = 0; i < rules.size(); i++) {
        String key = Array(rules.keys())[i];
        Ref<RegEx> regex = memnew(RegEx());
        int err = regex->compile(key);

        if (err != OK) {
            UtilityFunctions::printerr("error while compiling!");
            return markdown;
        }

        markdown = regex->sub(markdown, rules[key], true);
    }

    return markdown;
}


bool GTLib::is_upper(String character) {
    String ch = String::chr(character[0]);
    return (ch.to_upper() == ch);
}


Color GTLib::rgb_to_normalized(int red, int green, int blue, float alpha) {
    return Color((float)red / 255, (float)green / 255, (float)blue / 255, alpha);
}


PackedVector2Array GTLib::get_available_resolutions(bool follow_project_size) {
    Vector2 display = Vector2(DisplayServer::get_singleton()->screen_get_size());
    PackedVector2Array resolutions = {};

    if (!follow_project_size) {
        resolutions = {
            display / 3.0,
            display / 2.5,
            display / 2,
            display / 1.5,
            display,
        };
    } else {
        int vp_width = ProjectSettings::get_singleton()->get_setting("display/window/size/viewport_width", -1);
        int vp_height = ProjectSettings::get_singleton()->get_setting("display/window/size/viewport_height", -1);

        if (vp_width <= 0 || vp_height <= 0) {
            UtilityFunctions::printerr("invalid project settings, using display instead...");
            return get_available_resolutions();
        }

        Vector2 project_size = Vector2(vp_width, vp_height);
        resolutions = {
            project_size / 3.0,
            project_size / 2.5,
            project_size / 2.0,
            project_size / 1.5,
            project_size,
        };

        float multiplier = 1.5;
        Vector2 next = project_size * multiplier;

        while (next.x <= display.x && next.y <= display.y) {
            resolutions.append(next);
            multiplier += 0.5;
            next = project_size * multiplier;
        }
    }

    return resolutions;
}


Ref<ImageTexture> GTLib::img_to_texture(String img_path) {
    if (FileAccess::file_exists(img_path)) {
        Ref<Image> image = memnew(Image);
        image->load(img_path);

        Ref<ImageTexture> texture = memnew(ImageTexture);
        texture->set_image(image);

        
        return texture;
    } else {
        UtilityFunctions::printerr(String("{0} is invalid").format(Array::make(img_path)));
        return nullptr;
    }
}


int GTLib::random_number(int min, int max, PackedInt32Array exceptions) {
    exceptions = _remove_repeated(exceptions);

    if (exceptions.size() >= (max - min + 1)) {
        UtilityFunctions::printerr("'exceptions' contains all values that can be possibly generated, skipping exceptions...");
        return random_number(min, max);
    }

    int id = UtilityFunctions::randi_range(min,max);
    return (exceptions.has(id)) ? random_number(min,max,exceptions) : id;
}


String GTLib::slugify(String string, String delimiter, Dictionary extend) {
    int index = 0;
    String result = "";
    PackedStringArray available = {};

    for (int i = 97; i < 123; i++) {
        available.append(String::chr(i));
    }

    for (int i = 48; i < 58; i++) {
        available.append(String::chr(i));
    } 

    while (index < string.length()) {
        if (String::chr(string[index]) == " ") {
            result += delimiter;
            index++;
            continue;
        }

        if (extend.has(String::chr(string[index]))) {
            if (!_are_in(String::chr(string[index]), extend, available)) {
                index++;
                continue;
            }

            result += String(extend[String::chr(string[index]).to_lower()]);
            index++;
            continue;
        }

        if (!available.has(String::chr(string[index]))) {
            if (available.has(String::chr(string[index]).to_lower())) {
                result += String::chr(string[index]).to_lower();
                index++;
                continue;
            } else {
                index++;
                continue;
            }
        }

        result += String::chr(string[index]);
        index++;
    }

    return result;
}


void GTLib::set_mouse_filter_recursive(Control *node, Control::MouseFilter filter, bool children, PackedStringArray exceptions) {
    if (!node) {
        return;
    }

    if (!_is_type(node, exceptions)) {
        node->set_mouse_filter(filter);
    }

    if (children) {
        if (node->get_child_count() > 0) {
            for (int i = 0; i < node->get_children().size(); i++) {
                Node *child = node->get_child(i);
                Control *child_control = Object::cast_to<Control>(child);

                if (_is_type(child, exceptions)) {
                    continue;
                }

                if (child_control) {
                    set_mouse_filter_recursive(child_control, filter, children, exceptions);
                    child_control->set_mouse_filter(filter);
                }
            }
        }
    }
}


String GTLib::bbcode_to_markdown(String bbcode, String lang) {
    Dictionary rules;
    // center: [center] -> <center>
    rules["\\[center](.+)\\[\\/center]"] = "<center>$1</center>";
    // images: ![alt](url) -> [img]url[/img]
    rules["\\[img](.+?)\\[/img]"] = "![]($1)";
    // hyperlink: [text](url) -> [url=url]text[/url]
    rules["\\[url=(.+?)](.+?)\\[/url]"] = "[$2]($1)";
    // bold italics: ***text*** -> [b][i]text[/i][/b]
    rules["\\[b]\\[i](.+?)\\[/i]\\[/b]"] = "***$1***";
    // strikethrough: ~~text~~ -> [s]text[/s]
    rules["\\[s](.+?)\\[/s]"] = "~~$1~~";
    // bold: **text** or __text__ -> [b]text[/b]
    rules["\\[b](.+?)\\[/b]"] = "**$1**";
    // italic: *text* or _text_ -> [i]text[/i]
    rules["\\[i](.+?)\\[/i]"] = "*$1*";
    // unordered list: - text -> [ul] text[/ul]
    rules["\\[codeblock](.+?)\\[/codeblock]"] = String("```{0}\n$1\n```\n").format(Array::make(lang));

    // code: `text` -> [code]text[/code]
    rules["\\[code](.+?)\\[/code]"] = "`$1`";
    // newline
    rules["\\[br]$"] = String::chr(92);

    for (int i = 0; i < rules.size(); i++) {
        String key = Array(rules.keys())[i];
        Ref<RegEx> regex = memnew(RegEx);
        int err = regex->compile(key);

        if (err != OK) {
            UtilityFunctions::printerr("error while compiling!");
            return bbcode;
        }

        bbcode = regex->sub(bbcode, rules[key], true);

    }

    return bbcode;
}


Node* GTLib::node(String path, Node *starting_node) {
    PackedStringArray nodes = path.split(" > ");
    Node *prev_node = starting_node;

    for (int i = 0; i < nodes.size(); i++) {
        if (prev_node) {
            prev_node = prev_node->get_node_or_null(nodes[i]);
            if (!prev_node) {
                UtilityFunctions::printerr(String("'{0}' not found!").format(Array::make(nodes[i])));
                return nullptr;
            }
        } else {
            return nullptr;
        }
    }

    return prev_node;
}


int GTLib::text_distance(String string_1, String string_2) {
    int length1 = string_1.length();
    int length2 = string_2.length();

    PackedInt32Array prev_row = _range(length2 + 1);
    PackedInt32Array current_row = _range(length2 + 1);

    for (int i = 1; i <= length1; i++) {
        current_row[0] = i;

        for (int j = 1; j <= length2; j++) {
            if (string_1[i - 1] == string_2[j - 1]) {
                current_row[j] = prev_row[j - 1];
            } else {
                current_row[j] = 1 + (int)UtilityFunctions::min(
                    current_row[j - 1],
                    prev_row[j],
                    prev_row[j - 1]
                );
            }
        }

        prev_row = current_row.duplicate();
    }

    return current_row[length2];
}


// private methods
bool GTLib::_is_type(Node *node, PackedStringArray exceptions){
    for (int e = 0; e < exceptions.size(); e++) {
        if (node->get_class() == exceptions[e]) {
            return true;
        }
    }

    return false;
}


bool GTLib::_are_in(String string, Dictionary dict, PackedStringArray array){
    Array value = dict[string];

    for (int i = 0; i < value.size(); i++) {
        String element = (String)value[i];
        String lower = element.to_lower();

        if (!array.has(lower)) {
            return false;
        }
    }

    return true;
}


PackedInt32Array GTLib::_range(int end){
    return _range(0, end);
}


PackedInt32Array GTLib::_range(int start, int end){
    Array result;

    for (int i = start; i < end; i++) {
        result.append(i);
    }

    return result;
}


PackedInt32Array GTLib::_remove_repeated(PackedInt32Array array){
    PackedInt32Array result = {};
    
    for (int i = 0; i < array.size(); i++) {
        if (result.has(array[i])) {
            continue;
        } else {
            result.append(array[i]);
        }
    }

    return result;
}


// constructor
GTLib::GTLib() {
    _playback = 0;
}


GTLib::~GTLib() {
    _playback = 0;
}


// methods
void GTLib::_bind_methods() {
    ClassDB::bind_method(D_METHOD("date_difference_iso_8601", "date_1", "date_2"), &GTLib::date_difference_iso_8601);
    ClassDB::bind_method(D_METHOD("time_from_ms", "time_ms"), &GTLib::time_from_ms);
    ClassDB::bind_method(D_METHOD("time_difference_24h", "time_1", "time_2"), &GTLib::time_difference_24h);
    ClassDB::bind_method(D_METHOD("markdown_to_bbcode", "markdown", "heading_size", "heading_decreaser"), &GTLib::markdown_to_bbcode, DEFVAL(50), DEFVAL(5));
    ClassDB::bind_method(D_METHOD("is_upper", "character"), &GTLib::is_upper);
    ClassDB::bind_method(D_METHOD("rgb_to_normalized", "red", "green", "blue", "alpha"), &GTLib::rgb_to_normalized, DEFVAL(1.0));
    ClassDB::bind_method(D_METHOD("get_available_resolutions", "follow_project_size"), &GTLib::get_available_resolutions, DEFVAL(false));
    ClassDB::bind_method(D_METHOD("img_to_texture", "img_path"), &GTLib::img_to_texture);
    ClassDB::bind_method(D_METHOD("random_number", "min", "max", "exceptions"), &GTLib::random_number, DEFVAL(Array()));
    ClassDB::bind_method(D_METHOD("slugify", "string", "delimiter", "extend"), &GTLib::slugify, DEFVAL("-"), DEFVAL(Dictionary()));
    ClassDB::bind_method(D_METHOD("set_mouse_filter_recursive", "node", "filter", "children", "exceptions"), &GTLib::set_mouse_filter_recursive, DEFVAL(false), DEFVAL(PackedStringArray()));
    ClassDB::bind_method(D_METHOD("bbcode_to_markdown", "bbcode", "lang"), &GTLib::bbcode_to_markdown, DEFVAL(""));
    ClassDB::bind_method(D_METHOD("node", "path", "starting_node"), &GTLib::node);
    ClassDB::bind_method(D_METHOD("text_distance", "string_1", "string_2"), &GTLib::text_distance);
    ClassDB::bind_method(D_METHOD("get_days_in_month", "month", "year"), &GTLib::get_days_in_month);
    ClassDB::bind_method(D_METHOD("is_leap_year", "year"), &GTLib::is_leap_year);
}