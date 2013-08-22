_CONVERSION(`const char*',`const Glib::ustring&',`$3')
_CONVERSION(`unsigned int',`guint',`$3')
_CONVERSION(`guint',`unsigned int',`$3')

_CONVERSION(`Glib::RefPtr<Object>',`MaiaCoreObject*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Object>&',`MaiaCoreObject*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaCoreObject*',`const Glib::RefPtr<Object>&',`Glib::wrap($3)')
_CONVERSION(`MaiaCoreObject*',`Glib::RefPtr<Object>',`Glib::wrap($3)')

_CONVERSION(`Glib::QueryQuark',`guint32',`(guint32)$3.id ()')
_CONVERSION(`guint32',`Glib::QueryQuark',`Glib::QueryQuark ((GQuark)$3)')

_CONVERSION(`MaiaCoreObjectIterator*',`Object::iterator',`Glib::wrap($3)')

_CONVERSION(`MaiaCoreParserIterator*',`Parser::iterator',`Glib::wrap($3)')

_CONVERSION(`MaiaGraphicPoint*',`Point',`Glib::wrap(&$3)')
_CONVERSION(`MaiaGraphicPoint*',`const Point&',`Glib::wrap($3)')
_CONVERSION(`Point',`MaiaGraphicPoint*',`*$3.gobj ()')
_CONVERSION(`const Point&',`MaiaGraphicPoint*',`const_cast <MaiaGraphicPoint*> ($3.gobj ())')
_CONVERSION(`Point&',`MaiaGraphicPoint*',`$3.gobj ()')
_CONVERSION(`MaiaGraphicPoint*',`Point&',`Glib::wrap($3)')

_CONVERSION(`MaiaGraphicSize*',`const Size&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicSize*',`Size',`Glib::wrap(&$3)')
_CONVERSION(`Size',`MaiaGraphicSize*',`*$3.gobj ()')
_CONVERSION(`const Size&',`MaiaGraphicSize*',`const_cast <MaiaGraphicSize*> ($3.gobj ())')
_CONVERSION(`Size&',`MaiaGraphicSize*',`$3.gobj ()')
_CONVERSION(`MaiaGraphicSize*',`Size&',`Glib::wrap($3)')

_CONVERSION(`const Rectangle&',`MaiaGraphicRectangle*',`const_cast <MaiaGraphicRectangle*> ($3.gobj ())')
_CONVERSION(`Rectangle&',`MaiaGraphicRectangle*',`$3.gobj ()')
_CONVERSION(`Rectangle',`MaiaGraphicRectangle*',`$3.gobj ()')
_CONVERSION(`MaiaGraphicRectangle*',`const Rectangle&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicRectangle*',`Rectangle&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicRectangle*',`Rectangle',`Glib::wrap($3)')

_CONVERSION(`const Glib::RefPtr<Transform>&',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicTransform*',`const Glib::RefPtr<Transform>&',`Glib::wrap($3)')

_CONVERSION(`const Glib::RefPtr<Region>&',`MaiaGraphicRegion*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`Glib::RefPtr<Region>',`MaiaGraphicRegion*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicRegion*',`const Glib::RefPtr<Region>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicRegion*',`Glib::RefPtr<Region>',`Glib::wrap($3)')

_CONVERSION(`MaiaGraphicRegionIterator*',`Region::iterator',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Path>',`MaiaGraphicPath*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Path>&',`MaiaGraphicPath*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicPath*',`const Glib::RefPtr<Path>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicPath*',`Glib::RefPtr<Path>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Transform>',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Transform>&',`MaiaGraphicTransform*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicTransform*',`const Glib::RefPtr<Transform>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicTransform*',`Glib::RefPtr<Transform>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Pattern>',`MaiaGraphicPattern*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Pattern>&',`MaiaGraphicPattern*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicPattern*',`const Glib::RefPtr<Pattern>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicPattern*',`Glib::RefPtr<Pattern>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Color>',`MaiaGraphicColor*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Color>&',`MaiaGraphicColor*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicColor*',`const Glib::RefPtr<Color>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicColor*',`Glib::RefPtr<Color>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Gradient>',`MaiaGraphicGradient*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Gradient>&',`MaiaGraphicGradient*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicGradient*',`const Glib::RefPtr<Gradient>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicGradient*',`Glib::RefPtr<Gradient>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Context>',`MaiaGraphicContext*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Context>&',`MaiaGraphicContext*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicContext*',`const Glib::RefPtr<Context>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicContext*',`Glib::RefPtr<Context>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Glyph>',`MaiaGraphicGlyph*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Glyph>&',`MaiaGraphicGlyph*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicGlyph*',`const Glib::RefPtr<Glyph>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicGlyph*',`Glib::RefPtr<Glyph>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Surface>',`MaiaGraphicSurface*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Surface>&',`MaiaGraphicSurface*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicSurface*',`const Glib::RefPtr<Surface>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicSurface*',`Glib::RefPtr<Surface>',`Glib::wrap($3)')

_CONVERSION(`Glib::RefPtr<Image>',`MaiaGraphicImage*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`const Glib::RefPtr<Image>&',`MaiaGraphicImage*',__CONVERT_REFPTR_TO_P)
_CONVERSION(`MaiaGraphicImage*',`const Glib::RefPtr<Image>&',`Glib::wrap($3)')
_CONVERSION(`MaiaGraphicImage*',`Glib::RefPtr<Image>',`Glib::wrap($3)')

_CONVERSION(`Glib::ustring',`const gchar*',`$3.c_str ()')

_CONV_ENUM(MaiaCore,ParserToken)
_CONV_ENUM(MaiaCore,TimelineDirection)
_CONV_ENUM(MaiaGraphic,RegionOverlap)
_CONV_ENUM(MaiaGraphic,PathDataType)
_CONV_ENUM(MaiaGraphic,Operator)
