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
define(`_PROPERTY_PROXY',
    `ifdef(`_PROPERTY_PROXY_$2',
           `',
           `
#ifdef DOXYGEN_SHOULD_ADD_THIS
  /**
   * $6
   *
   * @accessors dnl
ifelse($4,_ReadOnly,get_$2(),
       `ifelse($4,_WriteOnly,set_$2(), get_$2() set_$2()dnl
define(`_PROPERTY_PROXY_$2', `$1'))')
   */
   Q_PROPERTY(_QUOTE($3) $2)
#endif dnl
           ')dnl
    ')dnl
