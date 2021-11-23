target_generate-keys(){
    info "This target should be called only ONCE at FIRST build"
    require_command zip
    require_command unzip
    require_command scrypt
    require_command openssl
    target_sync-initial
    mkdir -p android-certs
    exec rm -rf certbundle.zip certbundle.zip.sc
    info "Keys subject: $CERT_SUBJECT"
    for x in releasekey platform shared media networkstack testkey; do \
    ./development/tools/make_key android-certs/$x "$CERT_SUBJECT"; \
    done
    for x in releasekey platform shared media networkstack testkey; do
        exec "openssl rsa -inform DER -in android-certs/$x.pk8 -out android-certs/$x.key"
    done
    info "Generating encrypted keys bundle"
    exec zip -r certbundle.zip android-certs
    exec "scrypt enc certbundle.zip > certbundle.zip.sc"
    success "Generated encrypted keys bundle"
    info "Cleaning up unencrypted keys securely"
    exec srm -r android-certs certbundle.zip
    success "Done."
}

target_open-keys(){
    require_command unzip
    require_command srm
    change_dir /tmp
    info "Opening encrypted key bundle"
    exec "scrypt dec $BASEDIR/certbundle.zip.sc > certbundle.zip"
    exec unzip certbundle.zip
    #exec srm -rf /root/.android-certs $BASEDIR/.android-certs
    exec cp -r android-certs /root/.android-certs
    exec cp -r android-certs $BASEDIR/.android-certs
    srm certbundle.zip
    leave_dir
}

target_close-keys(){
    require_command srm
    srm -r /root/.android-certs $BASEDIR/.android-certs
}
