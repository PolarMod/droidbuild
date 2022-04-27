include_if_exists "config.sh"

target_droid(){
   target_build-docker
   if [[ ! -f "$PREV_BUILD_DIR/certbundle.zip.sc" ]]; then
        target_generate-keys
   fi
   info "Restoring certbundle"
   exec "cp $PREV_BUILD_DIR/certbundle.zip.sc $STORAGE_DIR/certbundle.zip.sc"
   info "Copying previous target files"
   copy $PREV_BUILD_DIR/'*target*.zip' "$STORAGE_DIR/out_dir/"
   info "Launching build in docker"
   exec docker run -it -v $STORAGE_DIR:/root/droid droidbuild
   success "Succesfully built PolarMod ROM"
   info "Updating target files for future incremental updates"
   move $PREV_BUILD_DIR/'*.zip' "$PREV_BUILD_DIR/previous/"
   copy $STORAGE_DIR/'out_dir/*target*.zip' "$PREV_BUILD_DIR/"
   success "Done updating target files"
}

target_generate-keys(){
    info "Launching signing keys generation in docker"
    exec "rm -f $PREV_BUILD_DIR/certbundle.zip.sc"
    exec "docker run -v $STORAGE_DIR:/root/droid --entrypoint '/root/scripts/container-generate-keys.sh' -it droidbuild"
    exec "cp $STORAGE_DIR/certbundle.zip.sc $PREV_BUILD_DIR/certbundle.zip.sc"
    success "Key generation was successful"
}

target_storage(){
    exec mkdir -p $STORAGE_DIR
    exec mkdir -p $STORAGE_DIR/out_dir
    exec cp -r build/droidbuild $STORAGE_DIR/
    exec cp build/Buildfile $STORAGE_DIR/
    exec mkdir -p $STORAGE_DIR/.repo
    exec mkdir -p $STORAGE_DIR/.repo/local_manifests
    exec rm -f $STORAGE_DIR/.repo/local_manifests/*.xml
    exec cp manifests/*.xml $STORAGE_DIR/.repo/local_manifests
    exec cp manifests/private/* $STORAGE_DIR/.repo/local_manifests
    exec cp config.sh $STORAGE_DIR/
    #change_dir $PREV_BUILD_DIR
    copy $PREV_BUILD_DIR/'*target*.zip' "$STORAGE_DIR/out_dir"
    #leave_dir
}
target_build-docker(){
   require_root
   require_command docker
   info "Preparing build"
   target_storage
   if [[ -f $PREV_BUILD_DIR/*target*.zip ]]; then
        exec cp "$PREV_BUILD_DIR/*target*.zip" "$STORAGE_DIR/out_dir/"
   fi
   success "Prepared storage"
   info "Starting build docker image"
   exec docker build . -t droidbuild
}

target_shell(){
   target_build-docker 
   exec "cp $PREV_BUILD_DIR/certbundle.zip.sc $STORAGE_DIR/certbundle.zip.sc"
   exec docker run -v $STORAGE_DIR:/root/droid --entrypoint /bin/bash -it droidbuild
}


