
target_patch-bootloader(){
  require_command sed
  require_command patch
  info "Patching bootloader locking support"
  #info "Patching sm8150-common"
  #change_dir device/oneplus/sm8150-common
  #exec "sed -i 's/^BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2/#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2/' BoardConfigCommon.mk"
  #exec "sed -i 's/^BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag/#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --#set_hashtree_disabled_flag/' BoardConfigCommon.mk"
  #exec "sed -i 's/^BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external\/avb\/test\/data\/testkey_rsa2048.pem/BOARD_AVB_KEY_PATH := \/root\/.android-certs\/releasekey.key/' BoardConfigCommon.mk"
  #exec "sed -i 's/^# OMX/# OEM Unlock reporting\nPRODUCT_DEFAULT_PROPERTY_OVERRIDES += \\\n    ro.oem_unlock_supported=1\n\n# OMX/' common.mk"
  #success "Patched sm8150-common succesfully"
  #leave_dir
  info "Patching core buildsystem"
  change_dir build/core
  exec patch Makefile ~/patches/core-Makefile-fix-18.1.patch
  leave_dir
  success "Succesfully patched bootloader locking support"
}

target_signing(){
  exec rm -rf build/make/tools/framework
  exec rm -rf build/make/tools/lib64
  exec rm -rf build/make/tools/bin
  exec cp -r out/host/linux-x86/framework build/make/tools/framework
  exec cp -r out/host/linux-x86/lib64 build/make/tools/lib64
  exec cp -r out/host/linux-x86/bin build/make/tools/bin

}

target_patch(){
  GITHUB="https://github.com/PolarMod"
  require_command git
  info "Patching packages"
  exec rm -rf system/update_engine
#  exec rm -rf frameworks/base
  exec rm -rf bootable/recovery
  info "Updating packages from PolarMod"
  change_dir /tmp
  exec git clone "$GITHUB/system_update_engine"
#  exec git clone "$GITHUB/frameworks_base"
  exec git clone "$GITHUB/android_bootable_recovery"
  info "Replacing packages with patched ones"
  exec mv system_update_engine $BASEDIR/system/update_engine
#  exec mv frameworks_base $BASEDIR/frameworks/base
  exec mv android_bootable_recovery $BASEDIR/bootable/recovery
  success "Patched basic repositories"
  leave_dir
  info "Patching prebuilts"
  exec rm -rf prebuilts/prebuiltapks
  exec cp -r ~/polar/prebuilts prebuilts/prebuiltapks
  success "Succesfully patched prebuilts"
  info "Patching NetworkStack overlay"
  exec rm -f vendor/lineage/overlay/common/packages/modules/NetworkStack/res/values/config.xml
  exec cp ~/overlays/networkstack_config.xml vendor/lineage/overlay/common/packages/modules/NetworkStack/res/values/config.xml
  success "Patched NetworkStack overlay"
  info "Patching PRODUCT_PACKAGES"
  change_dir vendor/lineage
  exec patch config/common.mk ~/patches/common.mk.patch
  success "Succesfully patched PRODUCT_PACKAGES"
  leave_dir
  info "Patching Updater"
  exec mkdir -p vendor/lineage/overlay/common/packages/apps/Updater/res/values
  exec mkdir -p vendor/lineage/overlay/packages/apps/Updater/res/values
  exec cp ~/overlays/updater_config.xml vendor/lineage/overlay/common/packages/apps/Updater/res/values/strings.xml
  exec cp ~/overlays/updater_config.xml vendor/lineage/overlay/packages/apps/Updater/res/values/strings.xml
  success "Patched Updater package"
  leave_dir
}

target_any-signed(){
  target_env
  export keys="release-keys"
  previous_target_files=$(get_latest_file "*${devname}*signed-target_files*" "${out_dir}")
  target_name="PolarMod-Sakura-${signature}.${keys}"
  print_info
  info "Updating sigining keys..."
  #exec rm -rf ~/.android-certs
  exec cp -r /root/.android-certs .android-certs
  success "Updated signing keys"
  info "Starting build"
  exec ". build/envsetup.sh"
  exec "lunch lineage_${devname}-${buildtype}"
  exec "mka target-files-package otatools -j6"
  success "Built target files package succesfully"
  info "Preparing signing enviroment"
  target_signing
  success "Signing enviroment ready"
  info "Signing files"
  exec "./build/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip ${out_dir}/${target_name}-signed-target_files.zip"
  success "Signed files succesfully"
  info "Building full OTA"
  exec "./build/tools/releasetools/ota_from_target_files --skip_compatibility_check -v -k ~/.android-certs/releasekey --block ${out_dir}/${target_name}-signed-target_files.zip ${out_dir}/${target_name}-OTA-signed.zip"
  success "Succesfully built full OTA!"
  info "Building incremental OTA"
  exec "./build/tools/releasetools/ota_from_target_files --skip_compatibility_check -v -k ~/.android-certs/releasekey --block -i ${previous_target_files} ${out_dir}/${target_name}-signed-target_files.zip ${out_dir}/${target_name}-INCREMENTAL-OTA-signed.zip"
}

target_build-device-unsigned(){
 target_env
 export keys="test-keys"
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
 fi
 info "Starting build"
 exec ". build/envsetup.sh"
 exec "lunch lineage_${TARGET_CODENAME}-${TARGET_BUILDTYPE}"
 exec "mka bacon -j$CONFIG_NPROC"
 success "Built OTA package succesfully"
}
