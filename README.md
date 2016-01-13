# ACE Mac

## Specific instructions for ACE Mac build

0. Get build time dependancies:
    
    A. Get homebrew from http://brew.sh/
    
    B. Open terminal app and run: 

        brew update 
        brew install doxygen nasm yasm optipng imagemagick coreutils intltool ninja antlr cmake gettext
        brew link --force gettext
        brew install cairo --without-x11
        brew install gtk+ --without-x11
        brew install gtk-mac-integration hicolor-icon-theme
        wget --no-check-certificate https://raw.github.com/yuvi/gas-preprocessor/master/gas-preprocessor.pl
        chmod +x gas-preprocessor.pl
        sudo mv gas-preprocessor.pl /usr/local/bin
        sudo ln -s /usr/local/bin/glibtoolize /usr/local/bin/libtoolize
        
    C. Initalize your git submodules: 
        
        git submodule update --init --recursive

1. Open terminal app in the current directory and run:

        prepare.py -G Ninja -DENABLE_WEBRTC_AEC=ON -DENABLE_H263=YES -DENABLE_FFMPEG=YES -DENABLE_NON_FREE_CODECS=ON  -DENABLE_GPL_THIRD_PARTIES=ON -DENABLE_AMRWB=YES -DENABLE_AMRNB=YES -DENABLE_OPENH264=YES -DENABLE_G729=YES -DENABLE_MPEG4=YES -DENABLE_H263P=ON -DENABLE_ILBC=ON -DENABLE_ISAC=ON -DENABLE_SILK=ON -DENABLE_VCARD=ON -p

2. Build the SDK with:

        make 

3. Open the ACE.xcodeproj in Xcode and run the project

Bonus. Update your local git repository:
    
    git pull && git submodule update --recursive 

# Customizing your build

Some options can be given during the `prepare.py` step to customize the build. The basic usage of the `prepare.py` script is:

        ./prepare.py [options]

Here are the main options you can use.

## Building with debug symbols

Building with debug symbols is necessary if you want to be able to debug the application using some tools like GDB or the Visual Studio debugger. To do so, pass the `--debug` option to `prepare.py`:

        ./prepare.py --debug [other options]

## Generating an installation package (on Windows and Mac OS X platforms)

You might want to generate an installation package to ease the distribution of the application. To add the package generation step to the build just run:

        ./prepare.py --package [other options]

## Activate the build of all codecs

        ./prepare.py --all-codecs

## Using more advanced options

The `prepare.py` script is wrapper around CMake. Therefore you can give any CMake option to the `prepare.py` script.
To get a list of the options you can pass, you can run:

        ./prepare.py --list-cmake-variables

The options that enable you to configure what will be built are the ones beginning with "ENABLE_". So for example, you might want to build linphone without the opus codec support. To do so use:

        ./prepare.py -DENABLE_OPUS=NO

# Updating your build

Simply re-building using the appropriate tool corresponding to your platform (make, Visual Studio...) should be sufficient to update the build (after having updated the source code via git).
However if the compilation fails, you may need to rebuild everything from scratch using:

        ./prepare.py -C && ./prepare.py [options]

Then you re-build as usual.
