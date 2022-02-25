
export PATH := "venv/bin:/usr/local/go/bin:qt/qt/bin:.rbenv/shims:/usr/local/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/Apple/usr/bin"
export RBENV_VERSION := "3.0.2"
export QT_MACOS_BIN := "qt/qt/bin"
export VIRTUAL_ENV := "venv"

make-initial:
	#!/usr/bin/env bash
	set -euxo pipefail
	rbenv shell 3.0.2
	gem install bundler
	gem install "xcodeproj"
	curl -L https://download.qt.io/archive/qt/5.15/5.15.1/single/qt-everywhere-src-5.15.1.tar.xz --output qt-everywhere-src-5.15.1.tar.xz
	tar vxf qt-everywhere-src-5.15.1.tar.xz
	mv qt-everywhere-src-5.15.1 qt
	bash scripts/qt5_compile.sh `pwd`/qt qt
	export QT_MACOS_BIN=`pwd`/qt/qt/bin
	sudo ln -s /opt/homebrew/bin/go /Applications/Xcode.app/Contents/Developer/usr/bin/go
	git submodule init
	git submodule update
	source venv/bin/activate
	pip3 install -r requirements.txt
	cp xcode.xconfig.template xcode.xconfig
	vi xcode.xconfig
	export PATH=$QT_MACOS_BIN:$PATH
	export PATH=/usr/local/go/bin:$PATH
	./scripts/apple_compile.sh macos --webextension
	read -p "Disable warning message about deprecated build in bottom of File -> Project Settings dialog"

	cd balrog
	make clean install build
	vi Makefile

	cd MozillaVPN.xcodeproj
	xcodebuild -scheme MozillaVPN -workspace project.xcworkspace -configuration Release clean build CODE_SIGNING_ALLOWED=NO

	codesign --force --deep -s "Personal Code Signing Certificate" Release/Mozilla\ VPN.app


update-git:
	# git pull --shallow-since 2021-11-04
	git submodule init
	git submodule update

rebuild:
	./scripts/apple_compile.sh macos --webextension
	read -p "Disable warning message about deprecated build in bottom of File -> Project Settings dialog"
	cd MozillaVPN.xcodeproj && xcodebuild -scheme MozillaVPN -workspace project.xcworkspace -configuration Release clean build CODE_SIGNING_ALLOWED=NO
	codesign --force --deep -s "Personal Code Signing Certificate" Release/Mozilla\ VPN.app

