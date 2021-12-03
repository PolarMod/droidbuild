## Auxilary functions

print_info(){
  info "---------------------------------------------------------------------------------"
  info "Target device:         ${TARGET_CODENAME}"
  info "Target name:           ${TARGET_FULLNAME}"
  info "Build type:            ${TARGET_BUILDTYPE}"
  info "Out directory:         ${out_dir}"
  info "Keys:                  ${TARGET_KEYS}"
  info "Display ID:            ${BUILD_DISPLAY_ID}"
  info "Previous target files: ${previous_target_files}"
  info "---------------------------------------------------------------------------------"
}

# $1 -- pattern to match
# $2 -- directory to search
get_latest_file(){
   echo `find $2 -name $1 -print0 | xargs -r -0 ls -1 -t | head -1`
}

# $1 -- pattern to search
# $2 -- dir name
# $3 -- ressulting array name
glob_files(){
   # FIXME: Use $2	
   info "glob $2/$1"
   mapfile -d $'\0' $3 < <(find $2 -wholename "$1" -print0)
}
