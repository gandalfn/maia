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

