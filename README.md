# ace-mac

## Accessible Communications for Everyone

This is source tree for the ACE App for Mac. 

## Building

This github project is automatically built via Travis.

The `.travis.yml` file is what directs these Travis automated builds. This includes all bootstrapping and preparation of a build environment, including all of the steps below.

These are the steps you can follow to build ace-ios locally.

1. Ensure you have Xcode installed
2. Prepare your build environment

        ./Tools/prepare.sh

3. Pull the ace-mac repo and init the submodules recursively

        git clone git@github.com:VTCSecureLLC/ace-mac.git
        cd ace-mac
        git submodule update --init --recursive

4. (re)Build the SDK

        ./prepare.py -C
        ./prepare.py -G Ninja -DENABLE_WEBRTC_AEC=ON -DENABLE_VCARD=ON -p --all-codecs
        make -j 8

5. Open the ACE.xcodeproj in Xcode and run the project

        open ACE.xcodeproj


## Customizing your build

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

First, update your local git repository:
    
        git pull && git submodule update --recursive

Usually, simply re-building using the appropriate tool corresponding to your platform (make, Visual Studio...) should be sufficient to update the build (after having updated the source code via git).

If any of the submodules are updated, you will want to clear and rebuild the Linphone SDK.

        ./prepare.py -C
        ./prepare.py -G Ninja -DENABLE_WEBRTC_AEC=ON -DENABLE_VCARD=ON -p --all-codecs
        make -j 8

Then re-build as usual.
