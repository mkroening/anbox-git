# Maintainer: Iwan Timmer <irtimmer@gmail.com>
# Contributor: Martin Kröning <m.kroening@hotmail.de>
_pkgname=anbox
pkgname=anbox-git
pkgver=r1202.576ed3d
pkgrel=1
pkgdesc="Android in a Box - An application-based approach to run a full Android system"
arch=(x86_64)
url=https://anbox.io/
license=(GPL3)
depends=(boost-libs hicolor-icon-theme lxc protobuf sdl2_image)
makedepends=(boost cmake dbus git glm gmock gtest ninja properties-cpp systemd)
optdepends=("anbox-modules-dkms: Anbox requires the binder and ashmem kernel drivers.")
provides=($_pkgname)
conflicts=($_pkgname)
source=(git+https://github.com/mwkroening/$_pkgname.git#branch=impl
        git+https://github.com/bombela/backward-cpp.git
        git+https://github.com/google/cpu_features.git
        0001-Desktop-Entry-Adjust-icon-location.patch
        anbox-container-manager.sh
        anbox-container-manager.service
        anbox.netdev
        anbox.network)
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            '3ab3c6ef3de7d2c056339c31d026ae4a5e4b17415835c480a46fb39ca52c653d'
            '469b33a1a29f0472ead7c8eba772eedc3a2a4aeadca2bed85a7d92f10f90d8f1'
            '3e8f0a7e2e881620c00dcaebbb436f5f1db2d64ea84533affb577a7b7714e34c'
            '559190df4d6d595480b30d8b13b862081fc4aac52790e33eb24cf7fbcb8003b8'
            'ffd7e845f0993572a4d3443bcec3742ffd5006b4ad73414f59e833f490f8fcce')

prepare() {
    cd $_pkgname

    git submodule init
    git config submodule.external/backward-cpp.url "$srcdir"/backward-cpp
    git config submodule.external/cpu_features.url "$srcdir"/cpu_features
    git submodule update

    patch -p1 -i "$srcdir"/0001-Desktop-Entry-Adjust-icon-location.patch
}

pkgver() {
    cd $_pkgname
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
    cmake -G Ninja -S $_pkgname -B build \
        -DANBOX_VERSION=$pkgver \
        -DBINDERFS_PATH=/var/lib/anbox/common/binderfs \
        -DCMAKE_BUILD_TYPE=None \
        -DCMAKE_C_FLAGS="$CPPFLAGS $CFLAGS" \
        -DCMAKE_CXX_FLAGS="$CPPFLAGS $CXXFLAGS" \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -Wno-dev

    cmake --build build
}

check() {
    cmake --build build --target test
}

package() {
    DESTDIR="$pkgdir" cmake --install build

    # Remove files from backward-cpp and cpu_features
    rm "$pkgdir"/usr/bin/list_cpu_features
    rm -r "$pkgdir"/usr/include
    rm -r "$pkgdir"/usr/lib

    # Container manager start script and service
    install -Dm 755 anbox-container-manager.sh "$pkgdir"/usr/lib/systemd/scripts/anbox-container-manager
    install -Dm 644 anbox-container-manager.service -t "$pkgdir"/usr/lib/systemd/system

    # systemd-networkd bridge
    install -Dm 644 anbox.netdev "$pkgdir"/usr/lib/systemd/network/80-anbox.netdev
    install -Dm 644 anbox.network "$pkgdir"/usr/lib/systemd/network/80-anbox.network

    cd $_pkgname
    # Desktop integration
    install -Dm 644 snap/gui/icon.png "$pkgdir"/usr/share/icons/hicolor/512x512/apps/anbox.png
    install -Dm 644 data/desktop/appmgr.desktop "$pkgdir"/usr/share/applications/anbox-appmgr.desktop
}
