STORAGE_DIR="/home/p01ar/sakura"

target_sakura(){
   require_root
   require_command docker
   info "Preparing build"
   info "Creating storage"
   exec mkdir -p $STORAGE_DIR
   info "Preparing storage"
   exec rm -f $STORAGE_DIR/Buildfile
   exec cp build/Buildfile $STORAGE_DIR/Buildfile
   info "Starting build docker image"
   exec docker build . -t polarmod.build
   info "Launching build in docker"
   exec docker run -it -v $STORAGE_DIR:/root/sakura polarmod.build
   success "Succesfully build sakura ROM"
}
