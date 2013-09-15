_CONVERSION(`const char*',`const Glib::ustring&',`$3')
_CONVERSION(`unsigned int',`guint',`$3')
_CONVERSION(`guint',`unsigned int',`$3')

_CONVERSION(`Glib::RefPtr<Object>',`MaiaCoreObject*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Object>&',`MaiaCoreObject*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaCoreObject*',`const Glib::RefPtr<Object>&',`Glib::wrap($3)')
_CONVERSION(`MaiaCoreObject*',`Glib::RefPtr<Object>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Timeline>',`MaiaCoreTimeline*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Core::Timeline>',`MaiaCoreTimeline*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Timeline>&',`MaiaCoreTimeline*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Core::Timeline>&',`MaiaCoreTimeline*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaCoreTimeline*',`const Glib::RefPtr<Timeline>&',`Glib::wrap($3)')
_CONVERSION(`MaiaCoreTimeline*',`const Glib::RefPtr<Core::Timeline>&',`Glib::wrap($3)')
_CONVERSION(`MaiaCoreTimeline*',`Glib::RefPtr<Timeline>',`Glib::wrap($3, true)')
_CONVERSION(`MaiaCoreTimeline*',`Glib::RefPtr<Core::Timeline>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::QueryQuark',`guint32',`(guint32)$3.id ()')
_CONVERSION(`guint32',`Glib::QueryQuark',`Glib::QueryQuark ((GQuark)$3)')

_CONVERSION(`MaiaCoreObjectIterator*',`Object::iterator',`Glib::wrap($3)')

_CONVERSION(`MaiaCoreParserIterator*',`Parser::iterator',`Glib::wrap($3)')

_CONVERSION(`MaiaGraphicPoint*',`Point',`Glib::wrap(&$3)')
_CONVERSION(`MaiaGraphicPoint*',`Graphic::Point',`Glib::wrap(&$3)')
_CONVERSION(`MaiaGraphicPoint*',`const Point&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicPoint*',`const Graphic::Point&',`Glib::wrap($3)')
_CONVERSION(`Point',`MaiaGraphicPoint*',`*$3.gobj ()')
_CONVERSION(`Graphic::Point',`MaiaGraphicPoint*',`*$3.gobj ()')
_CONVERSION(`const Point&',`MaiaGraphicPoint*',`const_cast <MaiaGraphicPoint*> ($3.gobj ())')
_CONVERSION(`const Graphic::Point&',`MaiaGraphicPoint*',`const_cast <MaiaGraphicPoint*> ($3.gobj ())')
_CONVERSION(`Point&',`MaiaGraphicPoint*',`$3.gobj ()')
_CONVERSION(`Graphic::Point&',`MaiaGraphicPoint*',`$3.gobj ()')
_CONVERSION(`MaiaGraphicPoint*',`Point&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicPoint*',`Graphic::Point&',`Glib::wrap($3)')

_CONVERSION(`MaiaGraphicSize*',`const Size&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicSize*',`const Graphic::Size&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicSize*',`Size',`Glib::wrap(&$3)')
_CONVERSION(`MaiaGraphicSize*',`Graphic::Size',`Glib::wrap(&$3)')
_CONVERSION(`Size',`MaiaGraphicSize*',`*$3.gobj ()')
_CONVERSION(`Graphic::Size',`MaiaGraphicSize*',`*$3.gobj ()')
_CONVERSION(`const Size&',`MaiaGraphicSize*',`const_cast <MaiaGraphicSize*> ($3.gobj ())')
_CONVERSION(`const Graphic::Size&',`MaiaGraphicSize*',`const_cast <MaiaGraphicSize*> ($3.gobj ())')
_CONVERSION(`Size&',`MaiaGraphicSize*',`$3.gobj ()')
_CONVERSION(`Graphic::Size&',`MaiaGraphicSize*',`$3.gobj ()')
_CONVERSION(`MaiaGraphicSize*',`Size&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicSize*',`Graphic::Size&',`Glib::wrap($3)')

_CONVERSION(`const Rectangle&',`MaiaGraphicRectangle*',`const_cast <MaiaGraphicRectangle*> ($3.gobj ())')
_CONVERSION(`Rectangle&',`MaiaGraphicRectangle*',`$3.gobj ()')
_CONVERSION(`Rectangle',`MaiaGraphicRectangle*',`$3.gobj ()')
_CONVERSION(`MaiaGraphicRectangle*',`const Rectangle&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicRectangle*',`Rectangle&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicRectangle*',`Rectangle',`Glib::wrap($3)')

_CONVERSION(`const Glib::RefPtr<Transform>&',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicTransform*',`const Glib::RefPtr<Transform>&',`Glib::wrap($3)')

_CONVERSION(`const Glib::RefPtr<Region>&',`MaiaGraphicRegion*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Graphic::Region>&',`MaiaGraphicRegion*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Region>',`MaiaGraphicRegion*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Graphic::Region>',`MaiaGraphicRegion*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicRegion*',`const Glib::RefPtr<Region>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicRegion*',`const Glib::RefPtr<Graphic::Region>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicRegion*',`Glib::RefPtr<Region>',`Glib::wrap($3, true)')
_CONVERSION(`MaiaGraphicRegion*',`Glib::RefPtr<Graphic::Region>',`Glib::wrap($3, true)')

_CONVERSION(`MaiaGraphicRegionIterator*',`Region::iterator',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Path>',`MaiaGraphicPath*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Path>&',`MaiaGraphicPath*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicPath*',`const Glib::RefPtr<Path>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicPath*',`Glib::RefPtr<Path>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Transform>',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Graphic::Transform>',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Transform>&',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Graphic::Transform>&',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicTransform*',`const Glib::RefPtr<Transform>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicTransform*',`const Glib::RefPtr<Graphic::Transform>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicTransform*',`Glib::RefPtr<Transform>',`Glib::wrap($3, true)')
_CONVERSION(`MaiaGraphicTransform*',`Glib::RefPtr<Graphic::Transform>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Pattern>',`MaiaGraphicPattern*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Graphic::Pattern>',`MaiaGraphicPattern*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Pattern>&',`MaiaGraphicPattern*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Graphic::Pattern>&',`MaiaGraphicPattern*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicPattern*',`const Glib::RefPtr<Pattern>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicPattern*',`const Glib::RefPtr<Graphic::Pattern>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicPattern*',`Glib::RefPtr<Pattern>',`Glib::wrap($3, true)')
_CONVERSION(`MaiaGraphicPattern*',`Glib::RefPtr<Graphic::Pattern>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Color>',`MaiaGraphicColor*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Graphic::Color>',`MaiaGraphicColor*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Color>&',`MaiaGraphicColor*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Graphic::Color>&',`MaiaGraphicColor*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicColor*',`const Glib::RefPtr<Color>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicColor*',`const Glib::RefPtr<Graphic::Color>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicColor*',`Glib::RefPtr<Color>',`Glib::wrap($3, true)')
_CONVERSION(`MaiaGraphicColor*',`Glib::RefPtr<Graphic::Color>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Gradient>',`MaiaGraphicGradient*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Gradient>&',`MaiaGraphicGradient*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicGradient*',`const Glib::RefPtr<Gradient>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicGradient*',`Glib::RefPtr<Gradient>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Context>',`MaiaGraphicContext*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Graphic::Context>',`MaiaGraphicContext*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Context>&',`MaiaGraphicContext*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Graphic::Context>&',`MaiaGraphicContext*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicContext*',`const Glib::RefPtr<Context>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicContext*',`const Glib::RefPtr<Graphic::Context>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicContext*',`Glib::RefPtr<Context>',`Glib::wrap($3, true)')
_CONVERSION(`MaiaGraphicContext*',`Glib::RefPtr<Graphic::Context>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Glyph>',`MaiaGraphicGlyph*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Glyph>&',`MaiaGraphicGlyph*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicGlyph*',`const Glib::RefPtr<Glyph>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicGlyph*',`Glib::RefPtr<Glyph>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Surface>',`MaiaGraphicSurface*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Graphic::Surface>',`MaiaGraphicSurface*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Surface>&',`MaiaGraphicSurface*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Graphic::Surface>&',`MaiaGraphicSurface*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicSurface*',`const Glib::RefPtr<Surface>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicSurface*',`const Glib::RefPtr<Graphic::Surface>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicSurface*',`Glib::RefPtr<Surface>',`Glib::wrap($3, true)')
_CONVERSION(`MaiaGraphicSurface*',`Glib::RefPtr<Graphic::Surface>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Image>',`MaiaGraphicImage*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Image>&',`MaiaGraphicImage*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicImage*',`const Glib::RefPtr<Image>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicImage*',`Glib::RefPtr<Image>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<AttributeBind>',`MaiaManifestAttributeBind*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<AttributeBind>&',`MaiaManifestAttributeBind*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaManifestAttributeBind*',`const Glib::RefPtr<AttributeBind>&',`Glib::wrap($3)')
_CONVERSION(`MaiaManifestAttributeBind*',`Glib::RefPtr<AttributeBind>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<AttributeScanner>',`MaiaManifestAttributeScanner*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<AttributeScanner>&',`MaiaManifestAttributeScanner*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaManifestAttributeScanner*',`const Glib::RefPtr<AttributeScanner>&',`Glib::wrap($3)')
_CONVERSION(`MaiaManifestAttributeScanner*',`Glib::RefPtr<AttributeScanner>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Document>',`MaiaManifestDocument*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Document>&',`MaiaManifestDocument*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaManifestDocument*',`const Glib::RefPtr<Document>&',`Glib::wrap($3)')
_CONVERSION(`MaiaManifestDocument*',`Glib::RefPtr<Document>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Element>',`MaiaManifestElement*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Element>&',`MaiaManifestElement*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaManifestElement*',`const Glib::RefPtr<Element>&',`Glib::wrap($3)')
_CONVERSION(`MaiaManifestElement*',`Glib::RefPtr<Element>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Style>',`MaiaManifestStyle*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Style>&',`MaiaManifestStyle*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaManifestStyle*',`const Glib::RefPtr<Style>&',`Glib::wrap($3)')
_CONVERSION(`MaiaManifestStyle*',`Glib::RefPtr<Style>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<StyleProperty>',`MaiaManifestStyleProperty*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<StyleProperty>&',`MaiaManifestStyleProperty*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaManifestStyleProperty*',`const Glib::RefPtr<StyleProperty>&',`Glib::wrap($3)')
_CONVERSION(`MaiaManifestStyleProperty*',`Glib::RefPtr<StyleProperty>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Drawable>',`MaiaDrawable*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Drawable>&',`MaiaDrawable*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaDrawable*',`const Glib::RefPtr<Drawable>&',`Glib::wrap($3)')
_CONVERSION(`MaiaDrawable*',`Glib::RefPtr<Drawable>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Item>',`MaiaItem*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Item>&',`MaiaItem*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaItem*',`const Glib::RefPtr<Item>&',`Glib::wrap($3)')
_CONVERSION(`MaiaItem*',`Glib::RefPtr<Item>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<ItemPackable>',`MaiaItemPackable*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<ItemPackable>&',`MaiaItemPackable*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaItemPackable*',`const Glib::RefPtr<ItemPackable>&',`Glib::wrap($3)')
_CONVERSION(`MaiaItemPackable*',`Glib::RefPtr<ItemPackable>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<ToggleButton>',`MaiaToggleButton*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<ToggleButton>&',`MaiaToggleButton*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaToggleButton*',`const Glib::RefPtr<ToggleButton>&',`Glib::wrap($3)')
_CONVERSION(`MaiaToggleButton*',`Glib::RefPtr<ToggleButton>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Model>',`MaiaModel*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Model>&',`MaiaModel*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaModel*',`const Glib::RefPtr<Model>&',`Glib::wrap($3)')
_CONVERSION(`MaiaModel*',`Glib::RefPtr<Model>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<ModelColumn>',`MaiaModelColumn*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<ModelColumn>&',`MaiaModelColumn*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaModelColumn*',`const Glib::RefPtr<ModelColumn>&',`Glib::wrap($3)')
_CONVERSION(`MaiaModelColumn*',`Glib::RefPtr<ModelColumn>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::RefPtr<Toolbox>',`MaiaToolbox*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Toolbox>&',`MaiaToolbox*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaToolbox*',`const Glib::RefPtr<Toolbox>&',`Glib::wrap($3)')
_CONVERSION(`MaiaToolbox*',`Glib::RefPtr<Toolbox>',`Glib::wrap($3, true)')

_CONVERSION(`Glib::ustring',`const gchar*',`$3.c_str ()')

_CONVERSION(`Glib::RefPtr< ::Gtk::TreeModel>',`GtkTreeModel*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr< ::Gtk::TreeModel>&',`GtkTreeModel*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`GtkTreeModel*',`const Glib::RefPtr< ::Gtk::TreeModel>&',`Glib::wrap($3)')
_CONVERSION(`GtkTreeModel*',`Glib::RefPtr< ::Gtk::TreeModel>',`Glib::wrap($3, true)')

_CONVERSION(`GtkButton*', `::Gtk::Button*',__RP2PD)
_CONVERSION(`::Gtk::Adjustment*', `GtkAdjustment*',$3->gobj ())
_CONVERSION(`GtkAdjustment*', `::Gtk::Adjustment*',__RP2PD)
_CONVERSION(`GList*',`Glib::ListHandle< ::Gtk::Button* >',__FL2H_SHALLOW)
_CONVERSION(`PageFormat',`MaiaPageFormat*',`(MaiaPageFormat)$3')
_CONVERSION(`MaiaPageFormat*',`PageFormat',`(PageFormat)$3')

_CONVERSION(`GtkTreePath*',`::Gtk::TreePath', `::Gtk::TreePath($3, false)')
_CONVERSION(`::Gtk::TreePath',`GtkTreePath*',__FR2P)
_CONVERSION(`::Gtk::TreeIter&',`GtkTreeIter*',__FR2P)
_CONVERSION(`const ::Gtk::TreeIter&',`GtkTreeIter*',__FCR2P)

_CONVERSION(`::Cairo::RefPtr< ::Cairo::Context>',`cairo_t*',`($3)->cobj()')
_CONVERSION(`cairo_t*',`::Cairo::RefPtr< ::Cairo::Context>',`::Cairo::RefPtr< ::Cairo::Context>(new ::Cairo::Context($3))')

_CONVERSION(`Glib::RefPtr< ::Pango::Context>',`PangoContext*',`__CONVERT_REFPTR_TO_P')
_CONVERSION(`PangoContext*',`Glib::RefPtr< ::Pango::Context>',`Glib::wrap($3, true)')

_CONVERSION(`::Cairo::RefPtr< ::Cairo::Surface>',`cairo_surface_t*',`($3)->cobj()')
_CONVERSION(`const ::Cairo::RefPtr< ::Cairo::Surface>&',`cairo_surface_t*',`($3)->cobj()')
_CONVERSION(`cairo_surface_t*',`::Cairo::RefPtr< ::Cairo::Surface>',`::Cairo::RefPtr< ::Cairo::Surface>(new ::Cairo::Surface($3))')

_CONVERSION(`Graphic::GlyphAlignment',`MaiaGraphicGlyphAlignment',`(MaiaGraphicGlyphAlignment)$3')
_CONVERSION(`MaiaGraphicGlyphAlignment',`Graphic::GlyphAlignment',`(Graphic::GlyphAlignment)$3')

_CONVERSION(`Graphic::GlyphWrapMode',`MaiaGraphicGlyphWrapMode',`(MaiaGraphicGlyphWrapMode)$3')
_CONVERSION(`MaiaGraphicGlyphWrapMode',`Graphic::GlyphWrapMode',`(Graphic::GlyphWrapMode)$3')

_CONVERSION(`Graphic::GlyphEllipsizeMode',`MaiaGraphicGlyphEllipsizeMode',`(MaiaGraphicGlyphEllipsizeMode)$3')
_CONVERSION(`MaiaGraphicGlyphEllipsizeMode',`Graphic::GlyphEllipsizeMode',`(Graphic::GlyphEllipsizeMode)$3')

_CONV_ENUM(MaiaCore,ParserToken)
_CONV_ENUM(MaiaCore,TimelineDirection)
_CONV_ENUM(MaiaCore,AnimatorProgressType)
_CONV_ENUM(MaiaGraphic,RegionOverlap)
_CONV_ENUM(MaiaGraphic,PathDataType)
_CONV_ENUM(MaiaGraphic,Operator)
_CONV_ENUM(MaiaGraphic,GlyphAlignment)
_CONV_ENUM(MaiaGraphic,GlyphWrapMode)
_CONV_ENUM(MaiaGraphic,GlyphEllipsizeMode)
_CONV_ENUM(Maia,Scroll)
_CONV_ENUM(Maia,Key)
_CONV_ENUM(Maia,Cursor)
_CONV_ENUM(Maia,PageFormat)
_CONV_ENUM(Maia,Orientation)
_CONV_ENUM(Maia,PopupPlacement)
_CONV_ENUM(Maia,ToolAction)
