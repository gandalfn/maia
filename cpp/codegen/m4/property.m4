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
    `dnl
    pushdef(`__GET_ACCESSOR__',`dnl
ifelse(m4_index(`$2', `is_'),0, $2(), `ifelse(m4_index(`$2', `have_'),0, $2(), `ifelse(m4_index(`$2', `can_'),0, $2(), `ifelse(m4_index(`$2', `have_'),0, $2(), `ifelse(`$2', `visible', $2(), `ifelse(m4_index(`$2', `need_'),0, $2(), get_$2())')')')')')dnl
'dnl
)dnl
    pushdef(`__SET_ACCESSOR__',`dnl
ifelse(m4_index(`$2', `is_'),0, `m4_format(`set_%s()', m4_substr($2, 3))', set_$2())dnl
'dnl
)dnl
    ifdef(`_PROPERTY_PROXY_$2',
           `',
           `
#ifdef DOXYGEN_SHOULD_ADD_THIS
  /**
   * $6
   *
   * @accessors dnl
ifelse($4,_ReadOnly,__GET_ACCESSOR__,
       `ifelse($4,_WriteOnly,__SET_ACCESSOR__, __GET_ACCESSOR__ __SET_ACCESSOR__ dnl
define(`_PROPERTY_PROXY_$2', `$1'))')
   */
   Q_PROPERTY(_QUOTE($3) $2)
#endif dnl
           ')dnl
    popdef(`__GET_ACCESSOR__')dnl
    ')dnl
