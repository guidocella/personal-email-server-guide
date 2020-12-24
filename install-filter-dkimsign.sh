#!/bin/sh

sed -i '/deb-src.*buster /s/^#//' /etc/apt/sources.list
apt update
apt install -y build-essential libssl-dev libevent-dev
mkdir /tmp/filter-dkimsign
cd /tmp/filter-dkimsign
curl --location --remote-name-all -J https://github.com/de-vri-es/filter-dkimsign/archive/v0.2.arch2.tar.gz https://aur.archlinux.org/cgit/aur.git/plain/Makefile?h=opensmtpd-filter-dkimsign https://distfiles.sigtrap.nl/libopensmtpd-0.4.tar.gz
tar xf filter-dkimsign-0.2.arch2.tar.gz
tar xf libopensmtpd-0.4.tar.gz
mv filter-dkimsign-0.2.arch2 filter-dkimsign
mv libopensmtpd-0.4 libopensmtpd
make
mv filter-dkimsign/filter-dkimsign /usr/libexec/opensmtpd

# You can use apt edit-sources to comment the deb-src repo again,
# and this command will remove the make dependencies:
# apt purge libssl-dev libevent-dev libevent-extra-2.1-6 libevent-openssl-2.1-6 libmpc3 libmpx2 gnupg-utils linux-libc-dev gpg-wks-client gnupg-l10n libfakeroot libc6-dev libksba8 cpp-8 libalgorithm-diff-perl libalgorithm-merge-perl binutils cpp libitm1 g++ gpg-wks-server gcc gpg libasan5 libquadmath0 libassuan0 libisl19 build-essential libfile-fcntllock-perl dirmngr binutils-x86-64-linux-gnu libgcc-8-dev libtsan0 libubsan1 g++-8 make fakeroot gcc-8 liblsan0 manpages-dev binutils-common libc-dev-bin libbinutils gnupg libcc1-0 pinentry-curses libnpth0 libdpkg-perl gpg-agent libalgorithm-diff-xs-perl gpgconf libstdc++-8-dev gpgsm dpkg-dev
