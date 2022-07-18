# Your Git email for repo configuration
GIT_EMAIL="git@github.com"
# Your Git username for repo configuration
GIT_USERNAME="git"
# Certificate subject for openssl key genration
CERT_SUBJECT="/C=US/ST=CA/L=Mountain View/O=Android/OU=Android development/CN=Android/emailAddress=android@android.com"
# Directory to build ROM
STORAGE_DIR="/home/p01ar/droid"
# Directory to store builds,keys,etc.
PREV_BUILD_DIR="/home/p01ar/droid-out"
# Our ROM base repo(LineageOS, but may be different)
BASE_REPO="https://github.com/LineageOS/android.git"
# Base repo barnch
BASE_REPO_BRANCH="lineage-19.1"
# CCache
ENABLE_CCACHE=true
# CCache size
CCACHE_SIZE=50G
# Do not remove manifests(recommended for debug in order to speed up builds
NO_REMOVE_MANIFESTS=1
