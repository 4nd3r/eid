#!/bin/sh -e

cd repo

rsync -ir --delete kvlt.ee:public/debian/ ./

for dist in sid forky trixie bookworm
do
    d="dists/${dist}/main/binary-amd64"
    mkdir -p "${d}"
    apt-ftparchive --arch amd64 packages "pool/${dist}" >"${d}/Packages"

    d="dists/${dist}/main/binary-arm64"
    mkdir -p "${d}"
    apt-ftparchive --arch arm64 packages "pool/${dist}" >"${d}/Packages"

    apt-ftparchive \
        -o APT::FTPArchive::Release::Suite="${dist}" \
        -o APT::FTPArchive::Release::Components='main' \
        -o APT::FTPArchive::Release::Architectures='amd64 arm64' \
        release "dists/${dist}" \
            | gpg --clearsign --yes -o "dists/${dist}/InRelease"
done

rsync -ir --delete ./ kvlt.ee:public/debian/
