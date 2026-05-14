#!/bin/sh -ex

cd repo

rsync -ir --delete kvlt.ee:public/debian/ ./

for dist in sid forky trixie
do
    for arch in amd64 arm64
    do
        artifact_zip="${HOME}/Downloads/eid_${dist}_${arch}.zip"
        test -f "${artifact_zip}"

        pool_dir="pool/${dist}"
        mkdir -p "${pool_dir}"

        unzip -n "${artifact_zip}" -d "${pool_dir}"

        dist_dir="dists/${dist}"
        packages_info_dir="${dist_dir}/main/binary-${arch}"
        mkdir -p "${packages_info_dir}"

        apt-ftparchive --arch "${arch}" packages "${pool_dir}" \
            >"${packages_info_dir}/Packages"
    done

    apt-ftparchive \
        -o APT::FTPArchive::Release::Suite="${dist}" \
        -o APT::FTPArchive::Release::Components='main' \
        -o APT::FTPArchive::Release::Architectures='amd64 arm64' \
        release "${dist_dir}" \
            | gpg --clearsign --yes -o "${dist_dir}/InRelease"
done

rsync -ir --delete ./ kvlt.ee:public/debian/
