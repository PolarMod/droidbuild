# This file contains default variables fro droid build
# Please, DO NOT write external configuration here
TARGET_NEEDS_RESYNC=false
TARGET_LOCAL_MANIFESTS=()
TARGET_REMOVE_DIRS=()
TARGET_USE_DIRS=()
TARGET_ARCH="armv8a"
TARGET_CODENAME=""
TARGET_ARCH_BITNESS=64
TARGET_SIGNED_BUILD=false
TARGET_KEYS_TYPE="test-keys"

# microG target should be available in make, so
# we need to export it.
export TARGET_USES_MICROG=0

# Whether target support G-Visual
export TARGET_SUPPORTS_GVISUAL=1
