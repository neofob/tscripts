#!/usr/bin/env bash
# References:
# * https://docs.rockylinux.org/gemstones/setup_local_repo/
# * https://forum.level1techs.com/t/how-to-create-a-local-mirror-of-rocky-linux-9-3-repo-when-rsync-isnt-available-anymore/219934
# updated: tuan t. pham
# It's about 232 GB for x86_64 binary packages
# NOTE:
# * The URL for webpage has "pub"
# * The URI for rsync does not have "pub"

REPO_BASE_DIR=${REPO_BASE_DIR:-"/opt/www/rpm-mirror"}
REPO_VERSION=${REPO_VERSION:-9}
REPO_EXCLUDES_LIST=${REPO_EXCLUDES_LIST:-"./excludes.txt"}
REPO_BASE_URL=${REPO_BASE_URL:-"mirror.cs.vt.edu/pub/rocky"}
REPO_URL=${REPO_URL:-"mirror.cs.vt.edu/rocky/${REPO_VERSION}"}
REPO_BASE_EPEL_URL=${REPO_BASE_EPEL_URL:-mirror.cs.vt.edu/pub/epel/}
REPO_EPEL_URL=${REPO_EPEL_URL:-"mirror.cs.vt.edu/epel/${REPO_VERSION}/Everything"}

REPO_ROCKY_V_BASE_DIR="${REPO_BASE_DIR}/pub/rocky/${REPO_VERSION}"
REPO_ROCKY_EPEL_V_BASE_DIR="${REPO_BASE_DIR}/pub/rocky/${REPO_VERSION}/Everything"
mkdir -p "${REPO_ROCKY_V_BASE_DIR}" "${REPO_ROCKY_EPEL_V_BASE_DIR}" || exit 1

if [[ ! -d "$REPO_BASE_DIR" ]]; then
    echo "Base repo directory does not exist: $REPO_BASE_DIR" >&2
    exit 1
fi

rsync_opts=(
    --archive
    --verbose
    --compress
    --human-readable
    --progress
    --delete
)

if [[ -f "$REPO_EXCLUDES_LIST" ]]; then
    rsync_opts+=('--exclude-from='"$REPO_EXCLUDES_LIST")
fi

echo rsync "${rsync_opts[@]}" "rsync://${REPO_URL}/" "${REPO_ROCKY_V_BASE_DIR}/"
rsync "${rsync_opts[@]}" "rsync://${REPO_URL}/" "${REPO_ROCKY_V_BASE_DIR}/" || exit 1

echo
echo rsync "${rsync_opts[@]}" "rsync://${REPO_EPEL_URL}/" "${REPO_ROCKY_EPEL_V_BASE_DIR}/"
rsync "${rsync_opts[@]}" "rsync://${REPO_EPEL_URL}/" "${REPO_ROCKY_EPEL_V_BASE_DIR}/" || exit 1

keys=(
    RPM-GPG-KEY-rockyofficial
    RPM-GPG-KEY-Rocky-$REPO_VERSION
)

epel_key="RPM-GPG-KEY-EPEL-$REPO_VERSION"

for key in "${keys[@]}"; do
    if [[ ! -e ${REPO_BASE_DIR}/"$key" ]]; then
        wget -P "$REPO_BASE_DIR" "https://$REPO_BASE_URL/$key" || exit 1
    fi
done

for key in "${epel_key[@]}"; do
    if [[ ! -e ${REPO_BASE_DIR}/"$key" ]]; then
        wget -P "$REPO_BASE_DIR" "https://$REPO_BASE_EPEL_URL/$key" || exit 1
    fi
done
