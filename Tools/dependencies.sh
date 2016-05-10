#!/bin/bash
set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

which brew || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#
#if [ -n "$TRAVIS" ]; then
#  export HOMEBREW_PREFIX=$HOME/.homebrew
#  if [[ -d $HOMEBREW_PREFIX ]]; then echo "HOMEBREW_PREFIX=$HOMEBREW_PREFIX"; else rsync -aq /usr/local/ $HOMEBREW_PREFIX; fi
#  export PATH=$HOMEBREW_PREFIX/bin:$PATH; hash -r
#fi
#which ccache || brew install ccache || brew link --force ccache || true
#export CCACHE_DIR=$HOME/.ccache
#export LINPHONE_CCACHE=ccache
#export CCACHE_SLOPPINESS=pch_defines,time_macros,include_file_mtime,include_file_ctime,file_macro
#export CCACHE_COMPILERCHECK=content
#ccache -M 5G
#ccache -s 
brew update 1>/dev/null
brew install doxygen homebrew/versions/nasm21106 yasm optipng imagemagick intltool ninja antlr
brew install cmake || true
brew install gettext || true
nasm -v
brew link --force gettext
brew install cairo --without-x11
brew install gtk+ --without-x11
brew install gtk-mac-integration hicolor-icon-theme
wget --no-check-certificate https://raw.github.com/yuvi/gas-preprocessor/master/gas-preprocessor.pl
chmod +x gas-preprocessor.pl
[ -x /usr/local/bin/gas-preprocessor.pl ] || sudo mv -f gas-preprocessor.pl /usr/local/bin
[ -x /usr/local/bin/libtoolize ] || sudo ln -sf /usr/local/bin/glibtoolize /usr/local/bin/libtoolize
git submodule update --init --recursive
bundle install
