all: ace-mac-transparent-1024x1024.png \
   	ace-mac-transparent-512x512.png \
	ace-mac-transparent-256x256.png \
	ace-mac-transparent-128x128.png \
	ace-mac-transparent-64x64.png \
	ace-mac-transparent-32x32.png \
	ace-mac-transparent-16x16.png

ace-mac-transparent.png: ace-mac.png
	convert ace-mac.png -transparent white ace-mac-transparent.png

ace-mac-transparent-%.png: ace-mac-transparent.png
	convert $< -resize $(shell echo $@ | sed -e 's/ace-mac-transparent-//' -e 's/\.png//') $@

