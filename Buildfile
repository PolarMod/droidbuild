include "config.sh"

target_droid(){
    target_container
    exec docker run -v "'$STORAGE_DIR:/opt/droid/buildroot'" \
                    -v "'$BASEDIR/config.sh:/opt/droid/config/config.sh'" \
                    -v "'$PREV_BUILD_DIR:/opt/droid/buildroot/out_dir'" \
                    -it droidbuild
}

target_generate-keys(){
    target_container
    info Launching signing keys generation in docker
    exec rm -f $PREV_BUILD_DIR/certbundle.zip.sc
    exec docker run -v \
         "'$STORAGE_DIR:/opt/droid/buildroot'" \
         -v "'$PREV_BUILD_DIR:/opt/droid/buildroot/out_dir'" \
         -v "'$BASEDIR/config.sh:/opt/droid/config/config.sh'" \
         --entrypoint '/opt/droid/scripts/container-generate-keys.sh' \
         -it droidbuild
    success Key generation successful
}

target_container(){
   require_root
   require_command docker
   info "Building docker image"
   exec docker build . -t droidbuild
}

target_container-unpack(){
   target_container
   exec docker run -v "'$STORAGE_DIR:/opt/droid/buildroot'" \ 
                   -v "'$BASEDIR/config.sh:/opt/droid/config/config.sh'" \
                   -v "'$PREV_BUILD_DIR:/opt/droid/buildroot/out_dir'" \
                   --entrypoint /opt/droid/docker-unpack.sh -it droidbuild
}

target_shell(){
   target_container
   exec docker run -v "'$STORAGE_DIR:/opt/droid/buildroot'" \
                   -v "'$BASEDIR/config.sh:/opt/droid/config/config.sh'" \
                   -v "'$PREV_BUILD_DIR:/opt/droid/buildroot/out_dir'" \
                   --entrypoint /bin/bash -it droidbuild
}
