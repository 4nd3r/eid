#!/bin/sh -e

cd repo

rsync -ir kvlt.ee:public/debian/ ./

for dist in sid forky trixie bookworm
do
    apt-ftparchive packages "pool/${dist}" \
        >"dists/${dist}/main/binary-amd64/Packages"

    apt-ftparchive \
        -o APT::FTPArchive::Release::Suite="${dist}" \
        -o APT::FTPArchive::Release::Components='main' \
        -o APT::FTPArchive::Release::Architectures='amd64' \
        release "dists/${dist}" \
            | gpg --clearsign --yes -o "dists/${dist}/InRelease"
done

rsync -ir --delete ./ kvlt.ee:public/debian/
