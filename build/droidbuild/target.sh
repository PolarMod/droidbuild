# $1 -- target name
setup_target(){
#  if ndef DROID_TARGETS; then
#    error "setup_target is called too early. Build system is not yet initialized: can not find DROID_TARGETS!"
#    exit -1
#  fi
  if ndef "TARGET_INCLUDED_$1"; then
    define "TAREGT_INCLUDED_$1" true
    DROID_TARGETS+=($1)
  fi
}
