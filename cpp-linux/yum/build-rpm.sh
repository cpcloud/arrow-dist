#!/bin/sh
# -*- sh-indentation: 2; sh-basic-offset: 2 -*-
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

run()
{
  "$@"
  if test $? -ne 0; then
    echo "Failed $@"
    exit 1
  fi
}

rpmbuild_options=

. /vagrant/env.sh

distribution=$(cut -d " " -f 1 /etc/redhat-release | tr "A-Z" "a-z")
if grep -q Linux /etc/redhat-release; then
  distribution_version=$(cut -d " " -f 4 /etc/redhat-release)
else
  distribution_version=$(cut -d " " -f 3 /etc/redhat-release)
fi
distribution_version=$(echo ${distribution_version} | sed -e 's/\..*$//g')

architecture="$(arch)"
case "${architecture}" in
  i*86)
    architecture=i386
    ;;
esac

run yum install -y epel-release
run yum groupinstall -y "Development Tools"

if [ "${distribution_version}" = 6 ]; then
  # libarchive-3 is required for cmake3
  srpm_download_url=http://vault.centos.org/7.3.1611/os/Source/SPackages
  libarchive_srpm_base=libarchive-3.1.2-10.el7_2.src.rpm
  run wget $srpm_download_url/$libarchive_srpm_base
  run yum install -y yum-utils autoconf268
  run yum-builddep -y --nogpgcheck $libarchive_srpm_base
  run env AUTOM4TE=autom4te268 rpmbuild --rebuild $libarchive_srpm_base
  run yum install -y ~/rpmbuild/RPMS/*/libarchive-3.*.rpm
  run rm -rf ~/rpmbuild/

  run yum install -y centos-release-scl
  run yum install -y devtoolset-6
fi

run yum install -y rpm-build rpmdevtools tar ${DEPENDED_PACKAGES}

if [ -x /usr/bin/rpmdev-setuptree ]; then
  rm -rf .rpmmacros
  run rpmdev-setuptree
else
  run cat <<EOM > ~/.rpmmacros
%_topdir ${HOME}/rpmbuild
EOM
  run mkdir -p ~/rpmbuild/SOURCES
  run mkdir -p ~/rpmbuild/SPECS
  run mkdir -p ~/rpmbuild/BUILD
  run mkdir -p ~/rpmbuild/RPMS
  run mkdir -p ~/rpmbuild/SRPMS
fi

repository="/vagrant/repositories/${distribution}/${distribution_version}"
rpm_dir="${repository}/${architecture}/Packages"
srpm_dir="${repository}/source/SRPMS"
run mkdir -p "${rpm_dir}" "${srpm_dir}"

# for debug
# rpmbuild_options="$rpmbuild_options --define 'optflags -O0 -g3'"

cd

if [ -n "${SOURCE_ARCHIVE}" ]; then
  run cp /vagrant/tmp/${SOURCE_ARCHIVE} rpmbuild/SOURCES/
else
  run cp /vagrant/tmp/${PACKAGE}-${VERSION}.* rpmbuild/SOURCES/
fi
run cp \
    /vagrant/tmp/${distribution}/${PACKAGE}.spec \
    rpmbuild/SPECS/

cat <<BUILD > build.sh
#!/bin/bash

rpmbuild -ba ${rpmbuild_options} rpmbuild/SPECS/${PACKAGE}.spec
BUILD
run chmod +x build.sh
if [ "${distribution_version}" = 6 ]; then
  run scl enable devtoolset-6 ./build.sh
else
  run ./build.sh
fi

run mv rpmbuild/RPMS/*/* "${rpm_dir}/"
run mv rpmbuild/SRPMS/* "${srpm_dir}/"
