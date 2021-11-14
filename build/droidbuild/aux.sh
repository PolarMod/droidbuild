## AUX functions

print_info(){
  info "---------------------------------------------------------------------------------"
  info "Target device:         ${devname}"
  info "Target name:           ${target_name}"
  info "Build type:            ${buildtype}"
  info "Out directory:         ${out_dir}"
  info "Keys:                  ${keys}"
  info "Display ID:            ${BUILD_DISPLAY_ID}"
  info "Previous target files: ${previous_target_files}"
  info "---------------------------------------------------------------------------------"
}

# $1 -- pattern to match
# $2 -- directory to search
get_latest_file(){
   echo `find $2 -name $1 -print0 | xargs -r -0 ls -1 -t | head -1`
}
