#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/classes/http_client.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/scene_tree.hpp>

using namespace godot;

class GTLib : public Object {
    GDCLASS(GTLib, Object);

protected:
    static void _bind_methods();

private:
    Variant _playback = 0;

public:
    // public methods
    Dictionary date_difference_iso_8601(String date1, String date2);
    Dictionary time_from_ms(int time_ms);
    Dictionary time_difference_24h(String time_1, String time_2);
    String markdown_to_bbcode(String markdown, int heading_size = 50, int heading_decrease = 5);
    String bbcode_to_markdown(String bbcode, String lang);
    bool is_upper(String character);
    Color rgb_to_normalized(int red, int green, int blue, float alpha = 1);
    PackedVector2Array get_available_resolutions(bool follow_project_size = false);
    Ref<ImageTexture> img_to_texture(String img_path);
    int random_number(int min, int max, PackedInt32Array exceptions = {});
    void set_mouse_filter_recursive(Control *node, Control::MouseFilter filter, bool children = false, PackedStringArray exceptions = {});
    String slugify(String string, String delimiter = "-", Dictionary extend = {});
    Node* node(String path, Node *starting_node);
    int text_distance(String string_1, String string_2);
    int get_days_in_month(int month, int year);
    bool is_leap_year(int year);

    // private methods
    bool _is_type(Node *node, PackedStringArray types);
    bool _are_in(String string, Dictionary dict, PackedStringArray array);
    PackedInt32Array _range(int end);
    PackedInt32Array _range(int start, int end);
    PackedInt32Array _remove_repeated(PackedInt32Array array);

    // constructor
    GTLib();
    ~GTLib();

};
