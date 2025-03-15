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
    Dictionary date_difference_iso_8601(String date1, String date2) const;
    Dictionary time_from_ms(int time_ms) const;
    Dictionary time_difference_24h(String time_1, String time_2) const;
    String markdown_to_bbcode(String markdown) const;
    String bbcode_to_markdown(String bbcode, String lang) const;
    bool is_upper(String character) const;
    Color rgb_to_normalized(int red, int green, int blue, float alpha = 1) const;
    PackedVector2Array get_available_resolutions(bool follow_project_size = false) const;
    Ref<ImageTexture> img_to_texture(String img_path) const;
    int random_number(int min, int max, PackedInt32Array exceptions = {}) const;
    void set_mouse_filter_recursive(Control *node, Control::MouseFilter filter, bool children = false, PackedStringArray exceptions = {});
    String slugify(String string, String delimiter = "-", Dictionary extend = {}) const;
    Node* node(String path, Node *starting_node);
    int text_distance(String string_1, String string_2) const;
    int get_days_in_month(int month, int year) const;
    bool is_leap_year(int year) const;

    // private methods
    bool _is_type(Node *node, PackedStringArray types) const;
    bool _are_in(String string, Dictionary dict, PackedStringArray array) const;
    PackedInt32Array _range(int end) const;
    PackedInt32Array _range(int start, int end) const;
    PackedInt32Array _remove_repeated(PackedInt32Array array) const;

    // constructor
    GTLib();
    ~GTLib();

};