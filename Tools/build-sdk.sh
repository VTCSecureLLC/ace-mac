#!/bin/bash
set -ex

brew install caskroom/cask/brew-cask
brew cask install java

[ -x /usr/bin/xcode-select ] || sudo ln -s /usr/bin/true /usr/bin/xcode-select

brew install homebrew/dupes/zlib
brew link --force zlib

brew install doxygen nasm yasm optipng imagemagick coreutils intltool gettext ninja cmake graphviz
which make || brew install make

[ -h /usr/local/bin/make ] || ln -s /usr/local/bin/gmake /usr/local/bin/make

# This is needed for ruby 1.8 compatibility when building under 10.7/10.8
( export PATH=/usr/local/bin:$PATH; brew install vim )

sudo mkdir -p /opt
sudo chmod 1777 /opt
[ -h /opt/local ] || ln -s /usr/local /opt/local

brew install intltool libtool wget pkg-config automake \
             speex ffmpeg readline libvpx opus

[ -h /usr/local/bin/libtoolize ] || \
(
  [ -f /usr/local/bin/libtoolize ] && rm -f /usr/local/bin/libtoolize
  [ -h /usr/local/bin/libtoolize ] || \
    ln -s /usr/local/bin/glibtoolize /usr/local/bin/libtoolize
)

export MACOSX_DEPLOYMENT_TARGET=10.7
export LDFLAGS="-Wl,-headerpad_max_install_names"

brew install homebrew/dupes/m4
brew link --force m4
[ -x /usr/bin/m4 ] || ln -sf /usr/local/bin/m4 /usr/bin/m4

brew tap Gui13/linphone
brew install antlr3.2 libantlr3.4c gtk-mac-integration srtp libgsm

brew install pixman
brew link --force pixman
brew install fontconfig
brew link --force fontconfig
brew install freetype
brew link --force freetype
brew install libpng
brew link --force libpng
brew install cairo --without-x11
brew link --force cairo
brew install gtk+ --without-x11
brew install ianblenke/taps/gnome-common --without-x11
brew install hicolor-icon-theme

[ -d /opt/polarssl ] || \
(
  cd /opt
  git clone git://git.linphone.org/polarssl.git polarssl || ( rm -fr polarssl ; exit 1 )
  cd polarssl
  ./autogen.sh && ./configure --prefix=/usr/local && make && make install || ( rm -fr polarssl ; exit 1 )
)

[ -d /opt/bzrtp ] || (
  cd /opt
  ( git clone git://git.linphone.org/bzrtp.git && cd bzrtp && ./autogen.sh && ./configure --prefix=/usr/local && make && make install ) || ( rm -fr bzrtp ; exit 1)
)

[ -d /opt/belle-sip ] || \
(
  cd /opt
  git clone git://git.linphone.org/belle-sip.git || ( rm -fr /opt/belle-sip ; exit 1)
  cd belle-sip
  ./autogen.sh && ./configure --prefix=/usr/local && make && make install || ( rm -fr /opt/belle-sip ; exit 1)
)
  
brew link --force gettext
brew link --force readline

brew install shared-mime-info glib-networking hicolor-icon-theme
update-mime-database /usr/local/share/mime

[ -h /usr/local/bin/pango-querymodules ] || \
  which pango-querymodules || \
  ln -s /usr/bin/true /usr/local/bin/pango-querymodules

[ -d /opt/gtk-mac-bundler ] || \
(
    cd /opt
    git clone https://github.com/jralls/gtk-mac-bundler.git || ( rm -fr gtk-mac-bundler ; exit 1)
    cd gtk-mac-bundler
    git checkout 6e2ed855aaeae43c29436c342ae83568573b5636 || ( rm -fr gtk-mac-bundler ; exit 1)
    make install || ( rm -fr gtk-mac-bundler ; exit 1)
    touch /usr/local/lib/charset.alias
)

export PATH=$PATH:~/.local/bin

[ -d /opt/gtk-quartz-engine ] || \
(
  cd /opt
  git clone https://github.com/jralls/gtk-quartz-engine.git || ( rm -fr /opt/gtk-quartz-engine ; exit 1 )
  cd gtk-quartz-engine
  ./autogen.sh && ./configure --prefix=/usr/local && CFLAGS="$CFLAGS -Wno-error" make install || ( rm -fr /opt/gtk-quartz-engine ; exit 1 )
)

pushd VATRP/submodules/linphone

git submodule update --init --recursive

export PACKAGE_VERSION=$(git describe --abbrev=0)
echo PACKAGE_VERSION=$PACKAGE_VERSION

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
./autogen.sh
./configure --prefix=/usr/local --with-srtp=/usr/local --with-gsm=/usr/local --enable-zrtp --disable-strict --enable-relativeprefix --enable-dtls --with-polarssl=/usr/local --with-ffmpeg=/usr/local --enable-truespeech --enable-ipv6 --enable-video --disable-x11 --without-libintl-prefix

for otoolpath in /usr/bin/otool /Library/Developer/CommandLineTools/usr/bin/otool ; do
  [ -f "$otoolpath".bin ] || \
  (
    sudo mv "$otoolpath" "$otoolpath".bin
    cat <<EOF > /tmp/otool.$$
#!/bin/bash
[ -d /opt/linphone/.Linphone.app ] && find /opt/linphone/.Linphone.app/ -type l | while read line; do [ -h "\$line" ] && rsync -aq \$(dirname \$(readlink "\$line" | sed -e 's%\.\..*Cellar%/usr/local/Cellar%'))/ \$(dirname "\$line")/ ; done
exec \$0.bin \$@
EOF
    sudo mv /tmp/otool.$$ "$otoolpath"
    sudo chmod 755 "$otoolpath"
  )
done

make clean
make
make install
make -C oRTP install
make -C mediastreamer2 install

# Overwrite the Belledonne provided binary linphonesdk folder with our source compiled version
popd
pwd

mkdir -p VATRP/linphonesdk/libs/ VATRP/linphonesdk/include/

# Copy in the generated binaries
rsync -SHPaxv /usr/local/lib/ VATRP/linphonesdk/libs/
rsync -SHPaxv /usr/local/include/ VATRP/linphonesdk/include/ || true

# Make the libraries relocatable
set +e
for library in $(find VATRP/linphonesdk/libs/ -name '*.dylib' -type f -print) ; do
  otool -L "$library" | \
  (
    set -x
    read source
    origin=$(echo $source | sed -e 's/:$//')
    chmod 644 $origin
    install_name_tool -id "@rpath/$(basename $origin)" "./$origin"
    grep -e '/opt/local\|/usr/local\|/Volumes/SSD/workspace_mac/linphone-desktop-all-codecs-mac/OUTPUT/lib' | \
    awk '{print $1}' | sed -e 's%^/opt/local/%%' -e 's%^/usr/local/%%' -e 's%^/Volumes/SSD/workspace_mac/linphone-desktop-all-codecs-mac/OUTPUT/lib/%%' | \
    (
      while read file ; do \
        echo $file
        install_name_tool -change "/opt/local/$file" "@rpath/$(basename $file)" "./$origin"
        install_name_tool -change "/usr/local/$file" "@rpath/$(basename $file)" "./$origin"
        install_name_tool -change "/Volumes/SSD/workspace_mac/linphone-desktop-all-codecs-mac/OUTPUT/lib/$file" "@rpath/$(basename $file)" "./$origin"
      done
    )
  )
done

rsync -SHPaxv VATRP/linphonesdk/libs/ /usr/local/lib/
set -e

