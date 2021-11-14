STORAGE_DIR="/home/p01ar/sakura-release"
PREV_BUILD_DIR="/home/p01ar/Documents/Polar\ Group/PolarMod-out"

target_sakura(){
   require_root
   require_command docker
   info "Preparing build"
   info "Creating storage"
   exec mkdir -p $STORAGE_DIR
   info "Preparing storage"
   exec rm -f $STORAGE_DIR/Buildfile
   exec rm -rf $STORAGE_DIR/droidbuild
   exec cp build/Buildfile $STORAGE_DIR/Buildfile
   exec cp -r build/droidbuild $STORAGE_DIR/droidbuild
   exec mkdir -p $STORAGE_DIR/out_dir
   exec cp "$PREV_BUILD_DIR/*target*.zip" $STORAGE_DIR/out_dir/
   success "Prepared storage"
   info "Starting build docker image"
   exec docker build . -t droidbuild
   info "Launching build in docker"
   exec docker run -it -v $STORAGE_DIR:/root/sakura droidbuild
   success "Succesfully build sakura ROM"
}
