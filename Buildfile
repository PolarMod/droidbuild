STORAGE_DIR="/home/p01ar/sakura-release"
PREV_BUILD_DIR="/home/p01ar/Documents/Polar\ Group/PolarMod-out"

target_sakura(){
   require_root
   require_command docker
   info "Preparing build"
   info "Creating storage"
   exec mkdir -p $STORAGE_DIR
   exec mkdir -p "$PREV_BUILD_DIR"
   exec mkdir -p "$PREV_BUILD_DIR/previous"
   info "Preparing storage"
   exec rm -f $STORAGE_DIR/Buildfile
   exec rm -rf $STORAGE_DIR/droidbuild
   exec cp build/Buildfile $STORAGE_DIR/Buildfile
   exec cp -r build/droidbuild $STORAGE_DIR/droidbuild
   exec mkdir -p $STORAGE_DIR/out_dir
   exec "cp $PREV_BUILD_DIR/*target*.zip $STORAGE_DIR/out_dir/"
   success "Prepared storage"
   info "Starting build docker image"
   exec docker build . -t droidbuild
   info "Launching build in docker"
   exec docker run -it -v $STORAGE_DIR:/root/sakura droidbuild
   success "Succesfully built PolarMod ROM"
   info "Updating target files for future incremental updates"
   exec "mv $PREV_BUILD_DIR/*.zip $PREV_BUILD_DIR/previous/"
   exec "cp $STORAGE_DIR/out_dir/*target*.zip $PREV_BUILD_DIR/"
   success "Done updating target files"
}

target_generate-keys(){
    target_build-docker
    exec "docker run -v $STORAGE_DIR:/root/sakura --entrypoint '/bin/bash /usr/bin/build generate-keys' -it droidbuild"
}

target_build-docker(){
   require_root
   require_command docker
   info "Preparing build"
   info "Creating storage"
   exec mkdir -p $STORAGE_DIR
   exec mkdir -p "$PREV_BUILD_DIR"
   exec mkdir -p "$PREV_BUILD_DIR/previous"
   info "Preparing storage"
   exec rm -f $STORAGE_DIR/Buildfile
   exec rm -rf $STORAGE_DIR/droidbuild
   exec cp build/Buildfile $STORAGE_DIR/Buildfile
   exec cp -r build/droidbuild $STORAGE_DIR/droidbuild
   exec mkdir -p $STORAGE_DIR/out_dir
   exec "cp $PREV_BUILD_DIR/*target*.zip $STORAGE_DIR/out_dir/"
   success "Prepared storage"
   info "Starting build docker image"
   exec docker build . -t droidbuild
}

target_shell(){
   target_build-docker
   exec docker run -v $STORAGE_DIR:/root/sakura --entrypoint /bin/bash -it droidbuild
}
