dnl
dnl
dnl  Code generation sections for properties
dnl
dnl

dnl                  $1         $2            $3          $4           $5        $6
dnl _PROPERTY_PROXY(name, name_underscored, cpp_type, proxy_suffix, deprecated, docs)
dnl proxy_suffix could be "", "_WriteOnly" or "_ReadOnly"
dnl The method will be const if the propertyproxy is _ReadOnly.
dnl
define(`_PROPERTY_PROXY',`dnl
dnl
dnl Put spaces around the template parameter if necessary.
pushdef(`__PROXY_TYPE__',`dnl
Glib::PropertyProxy$4< _QUOTE($3) >'dnl
)dnl
#ifdef DOXYGEN_SHOULD_ADD_THIS
/**
   * $6
   * @accessors get_$2(), set_$2()
   */
   Q_PROPERTY(_QUOTE($3) $2)
#endif
_PUSH(SECTION_CC_PROPERTYPROXIES)
_POP()
popdef(`__PROXY_TYPE__')dnl
')dnl
