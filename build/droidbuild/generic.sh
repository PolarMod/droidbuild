target_signing(){
  exec rm -rf build/make/tools/framework
  exec rm -rf build/make/tools/lib64
  exec rm -rf build/make/tools/bin
  exec cp -r out/host/linux-x86/framework build/make/tools/framework
  exec cp -r out/host/linux-x86/lib64 build/make/tools/lib64
  exec cp -r out/host/linux-x86/bin build/make/tools/bin

}

target_ccache(){
  if def CCACHE_FLAG; then
     return
  fi
  if def ENABLE_CCACHE; then
     if $ENABLE_CCACHE; then
        export USE_CCACHE=1
        export CCACHE_EXEC=$(which ccache)
        info "Enabling ccache"
        info "CCache executable path: $CCACHE_EXEC"
        if ndef CCACHE_SIZE; then
           error "CCache enabled, but size is missing!"
           error "Aborting build."
           exit -1
        fi
        exec "$CCACHE_EXEC -M $CCACHE_SIZE"
    fi
  else
    warn "Can not determine CCache status, because ENABLE_CCACHE is not defined, defaulting to false"
  fi
  export CCACHE_FLAG=true
}

target_build-device-signed(){
  target_ccache
  TARGET_KEYS="release-keys"
  export keys="release-keys"
  target_env
  target_open-keys
  if ndef CONFIG_NPROC; then
	  error "CONFIG_NPROC is not defined! Seems that build target called too early."
	  error "Aborting build"
	  exit -1
  fi
  export keys="release-keys"
  previous_target_files=$(get_latest_file "*${TARGET_CODENAME}*signed-target_files*" "${out_dir}")
  target_name="PolarMod-${version_codename}-${signature}.${keys}"
  print_info
  info "Updating sigining keys..."
  #exec rm -rf ~/.android-certs
  exec cp -r /root/.android-certs .android-certs
  success "Updated signing keys"
  info "Starting build"
  exec ". build/envsetup.sh"
  exec "lunch lineage_${TARGET_CODENAME}-${TARGET_BUILDTYPE}"
  exec "mka target-files-package otatools -j$CONFIG_NPROC"
  success "Built target files package succesfully"
  info "Preparing signing enviroment"
  target_signing
  success "Signing enviroment ready"
  info "Signing files"
  exec "sign_target_files_apks -o -d ~/.android-certs $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip ${out_dir}/${target_name}-signed-target_files.zip"
  success "Signed files succesfully"
  info "Building full OTA"
  exec "ota_from_target_files --skip_compatibility_check -v -k ~/.android-certs/releasekey --block ${out_dir}/${target_name}-signed-target_files.zip ${out_dir}/${target_name}-OTA-signed.zip"
  success "Succesfully built full OTA!"
  incremental_path=""
  if [[ -f $previous_target_files ]]; then
    info "Building incremental OTA"
    exec "ota_from_target_files --skip_compatibility_check -v -k ~/.android-certs/releasekey --block -i ${previous_target_files} ${out_dir}/${target_name}-signed-target_files.zip ${out_dir}/${target_name}-INCREMENTAL-OTA-signed.zip"
    incremental_path="${out_dir}/${target_name}-INCREMENTAL-OTA-signed.zip"
  fi
  target_close-keys
  on_device_signed_build_finished $TARGET_CODENAME "${out_dir}/${target_name}-OTA-signed.zip" $incremental_path
}

target_build-device-unsigned(){
 target_ccache
 TARGET_KEYS="test-keys"
 export keys="test-keys"
 target_env
 print_info
 change_dir $BASEDIR
 if ndef CONFIG_NPROC; then
   error "Can not read CONFIG_NPROC"
   error "Aborting build."
   exit -1
 fi
 if ndef TARGET_CODENAME; then
   error "Can not read TARGET_CODENAME"
   error "Aborting build."
   exit -1
 fi
 if ndef TARGET_BUILDTYPE; then
   error "Can not read TARGET_BUILDTYPE"
   exit -1
 fi
 info "Starting build"
 exec ". build/envsetup.sh"
 exec "lunch lineage_${TARGET_CODENAME}-${TARGET_BUILDTYPE}"
 exec "mka bacon -j$CONFIG_NPROC"
 success "Built OTA package succesfully"
}

target_build-emulator-generic(){
 target_ccache
 TARGET_KEYS="test-keys"
 export keys="test-keys"
 target_env
 if ndef CONFIG_NPROC; then
   error "Can not read CONFIG_NPROC"
   error "Aborting build."
   exit -1
 fi
 if ndef TARGET_BUILDTYPE; then
   error "Can not read TARGET_BUILDTYPE"
   exit -1
 fi
 if ndef TARGET_ARCH; then
   error "Can not read TARGET_ARCH"
   exit -1
 fi
 info "Starting build"
 exec ". build/envsetup.sh"
 exec "lunch lineage_${TARGET_ARCH}-${TARGET_BUILDTYPE}"
 exec "mka sdk_addon -j$CONFIG_NPROC"
 success "Built emulator package succesfully"
 target_name="PolarMod-${version_codename}-${signature}.${keys}"
 info "Moving resulting images ZIP to out_dir"
 move "$BASEDIR/out/host/linux-x86/sdk_addon/*-img.zip" "$out_dir/$target_name-SYSIMAGES.zip"
}
