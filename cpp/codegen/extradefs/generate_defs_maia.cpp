#include <iostream>
#include <glibmm_generate_extra_defs/generate_extra_defs.h>
#include "maia.h"

int main (int argc, char** argv)
{
    g_type_init ();

    std::cout << get_defs (MAIA_LOG_TYPE_LOGGER);

    std::cout << get_defs (MAIA_CORE_TYPE_ANY);
    std::cout << get_defs (MAIA_CORE_TYPE_OBJECT);
    std::cout << get_defs (MAIA_CORE_TYPE_ITERATOR);
    std::cout << get_defs (MAIA_CORE_TYPE_COLLECTION);
    std::cout << get_defs (MAIA_CORE_TYPE_ARRAY);
    std::cout << get_defs (MAIA_CORE_TYPE_SET);
    std::cout << get_defs (MAIA_CORE_TYPE_PAIR);
    std::cout << get_defs (MAIA_CORE_TYPE_MAP);
    std::cout << get_defs (MAIA_CORE_TYPE_TIMELINE);
    std::cout << get_defs (MAIA_CORE_TYPE_ANIMATOR);
    std::cout << get_defs (MAIA_CORE_TYPE_PARSER);
    std::cout << get_defs (MAIA_CORE_TYPE_EVENT_ARGS);
    std::cout << get_defs (MAIA_CORE_TYPE_EVENT);
    std::cout << get_defs (MAIA_CORE_TYPE_EVENT_LISTENER);
    std::cout << get_defs (MAIA_CORE_TYPE_EVENT_BUS);

    std::cout << get_defs (MAIA_GRAPHIC_TYPE_COLOR);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_CONTEXT);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_DEVICE);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_GLYPH);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_GRADIENT);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_IMAGE);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_IMAGE_GIF);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_IMAGE_JPG);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_IMAGE_PNG);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_IMAGE_SVG);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_LINEAR_GRADIENT);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_MESH_GRADIENT);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_PATH);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_PATTERN);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_POINT);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_RADIAL_GRADIENT);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_RANGE);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_LINE);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_RECTANGLE);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_REGION);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_SIZE);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_SURFACE);
    std::cout << get_defs (MAIA_GRAPHIC_TYPE_TRANSFORM);

    std::cout << get_defs (MAIA_MANIFEST_TYPE_ATTRIBUTE);
    std::cout << get_defs (MAIA_MANIFEST_TYPE_ATTRIBUTE_BIND);
    std::cout << get_defs (MAIA_MANIFEST_TYPE_ATTRIBUTE_SCANNER);
    std::cout << get_defs (MAIA_MANIFEST_TYPE_DOCUMENT);
    std::cout << get_defs (MAIA_MANIFEST_TYPE_ELEMENT);
    std::cout << get_defs (MAIA_MANIFEST_TYPE_FUNCTION);
    std::cout << get_defs (MAIA_MANIFEST_TYPE_THEME);
    std::cout << get_defs (MAIA_MANIFEST_TYPE_STYLE);
    std::cout << get_defs (MAIA_MANIFEST_STYLE_TYPE_PROPERTY);

    std::cout << get_defs (MAIA_TYPE_APPLICATION);
    std::cout << get_defs (MAIA_TYPE_BUTTON);
    std::cout << get_defs (MAIA_TYPE_CANVAS);
    std::cout << get_defs (MAIA_TYPE_CHECK_BUTTON);
    std::cout << get_defs (MAIA_TYPE_CURSOR);
    std::cout << get_defs (MAIA_TYPE_DOCUMENT);
    std::cout << get_defs (MAIA_TYPE_DOCUMENT_VIEW);
    std::cout << get_defs (MAIA_TYPE_REPORT);
    std::cout << get_defs (MAIA_TYPE_DRAWABLE);
    std::cout << get_defs (MAIA_TYPE_DRAWING_AREA);
    std::cout << get_defs (MAIA_TYPE_ENTRY);
    std::cout << get_defs (MAIA_TYPE_GRID);
    std::cout << get_defs (MAIA_TYPE_GROUP);
    std::cout << get_defs (MAIA_TYPE_HIGHLIGHT);
    std::cout << get_defs (MAIA_TYPE_IMAGE);
    std::cout << get_defs (MAIA_TYPE_ITEM);
    std::cout << get_defs (MAIA_TYPE_ITEM_MOVABLE);
    std::cout << get_defs (MAIA_TYPE_ITEM_PACKABLE);
    std::cout << get_defs (MAIA_TYPE_ITEM_RESIZABLE);
    std::cout << get_defs (MAIA_TYPE_KEY);
    std::cout << get_defs (MAIA_TYPE_LABEL);
    std::cout << get_defs (MAIA_TYPE_MODEL);
    std::cout << get_defs (MAIA_MODEL_TYPE_COLUMN);
    std::cout << get_defs (MAIA_TYPE_ORIENTATION);
    std::cout << get_defs (MAIA_TYPE_PAGE_FORMAT);
    std::cout << get_defs (MAIA_TYPE_PATH);
    std::cout << get_defs (MAIA_TYPE_RECTANGLE);
    std::cout << get_defs (MAIA_TYPE_SCROLL);
    std::cout << get_defs (MAIA_TYPE_TOGGLE);
    std::cout << get_defs (MAIA_TOGGLE_TYPE_TOGGLED_EVENT_ARGS);
    std::cout << get_defs (MAIA_TYPE_TOGGLE_GROUP);
    std::cout << get_defs (MAIA_TYPE_TOGGLE_BUTTON);
    std::cout << get_defs (MAIA_TYPE_POPUP_BUTTON);
    std::cout << get_defs (MAIA_TYPE_VIEW);
    std::cout << get_defs (MAIA_TYPE_SHORTCUT);
    std::cout << get_defs (MAIA_TYPE_POPUP);
    std::cout << get_defs (MAIA_TYPE_COMBO);
    std::cout << get_defs (MAIA_COMBO_TYPE_CHANGED_EVENT_ARGS);
    std::cout << get_defs (MAIA_TYPE_TOOLBOX);
    std::cout << get_defs (MAIA_TOOLBOX_TYPE_ADD_ITEM_EVENT_ARGS);
    std::cout << get_defs (MAIA_TOOLBOX_TYPE_CURRENT_ITEM_EVENT_ARGS);
    std::cout << get_defs (MAIA_TYPE_TOOL);
    std::cout << get_defs (MAIA_TYPE_ARROW);
    std::cout << get_defs (MAIA_TYPE_WINDOW);
    std::cout << get_defs (MAIA_TYPE_ADJUSTMENT);
    std::cout << get_defs (MAIA_TYPE_PROGRESS_BAR);
    std::cout << get_defs (MAIA_TYPE_SEEK_BAR);
    std::cout << get_defs (MAIA_ENTRY_TYPE_CHANGED_EVENT_ARGS);
    std::cout << get_defs (MAIA_TYPE_CHART);
    std::cout << get_defs (MAIA_TYPE_CHART_POINT);
    std::cout << get_defs (MAIA_TYPE_CHART_INTERSECT);
    std::cout << get_defs (MAIA_TYPE_CHART_VIEW);


    return 0;
}
