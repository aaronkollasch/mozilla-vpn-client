
export PATH := "venv/bin:"+env_var('HOME')+"/.cargo/bin:qt/qt/bin:.rbenv/shims:/usr/local/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/Apple/usr/bin"
export RBENV_VERSION := "3.0.2"
export QT_MACOS_BIN := "qt/qt/bin"
export VIRTUAL_ENV := "venv"

make-initial:
	#!/usr/bin/env bash
	set -euxo pipefail
	export PATH=/usr/local/go/bin:$PATH
	eval "$(rbenv init - bash)"
	rbenv shell 3.0.2
	gem install bundler
	gem install "xcodeproj"
	[[ ! -f qt-everywhere-src-5.15.1.tar.xz ]] && curl -L https://download.qt.io/archive/qt/5.15/5.15.1/single/qt-everywhere-src-5.15.1.tar.xz --output qt-everywhere-src-5.15.1.tar.xz
	tar vxf qt-everywhere-src-5.15.1.tar.xz
	mv qt-everywhere-src-5.15.1 qt
	sed -i '' 's%QT_BEGIN_NAMESPACE%#include <CoreGraphics/CGColorSpace.h>\nQT_BEGIN_NAMESPACE%g' qt/qtbase/src/plugins/platforms/cocoa/qiosurfacegraphicsbuffer.h
	bash scripts/qt5_compile.sh `pwd`/qt qt
	export QT_MACOS_BIN=`pwd`/qt/qt/bin
	sudo ln -s /usr/local/go/bin/go /Applications/Xcode.app/Contents/Developer/usr/bin/go
	git submodule init
	git submodule update
	source venv/bin/activate
	pip3 install -r requirements.txt
	cp xcode.xconfig.template xcode.xconfig
	vi xcode.xconfig
	export PATH=$QT_MACOS_BIN:$PATH
	export PATH=/usr/local/go/bin:$PATH
	./scripts/macos/apple_compile.sh macos
	read -p "Disable warning message about deprecated build in bottom of File -> Project Settings dialog"

	cd balrog
	make clean install build
	vi Makefile

	#cd Mozilla\ VPN.xcodeproj
	#xcodebuild -scheme MozillaVPN -workspace project.xcworkspace -configuration Release clean build CODE_SIGNING_ALLOWED=NO
	xcodebuild build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project "Mozilla VPN.xcodeproj"

	codesign --force --deep -s "Personal Code Signing Certificate" Release/Mozilla\ VPN.app


update-git:
	# git pull --shallow-since 2021-11-04
	git fetch upstream --shallow-since 2022-01-01
	git submodule init
	git submodule update

rebuild:
	#!/usr/bin/env bash
	set -euxo pipefail
	export PATH=/usr/local/go/bin:$PATH
	./scripts/macos/apple_compile.sh macos
	read -p "Disable warning message about deprecated build in bottom of File -> Project Settings dialog"
	#cd Mozilla\ VPN.xcodeproj && xcodebuild -scheme MozillaVPN -workspace project.xcworkspace -configuration Release clean build CODE_SIGNING_ALLOWED=NO
	xcodebuild build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -project "Mozilla VPN.xcodeproj"
	codesign --force --deep -s "Personal Code Signing Certificate" Release/Mozilla\ VPN.app

build-cmake-macos:
	#!/usr/bin/env bash
	set -euxo pipefail
	export PATH=/usr/local/go/bin:$PATH
	mkdir -p build && cmake -S . -B build -DCMAKE_PREFIX_PATH=qt/qt/lib/cmake -DCMAKE_PROGRAM_PATH=$PATH -DCMAKE_BUILD_TYPE=Release \
		-DPython3_EXECUTABLE=$(realpath --no-symlinks $(which python3)) \
		-DCARGO_BIN_PATH=$HOME/.cargo/bin -DCARGO_HOME=$HOME/.cargo
	cmake --build build -j$(sysctl -n hw.ncpu)
	codesign --force --deep -s "Personal Code Signing Certificate" build/src/Mozilla\ VPN.app

build-cmake-linux:
	#!/usr/bin/env bash
	set -euxo pipefail
	export PATH=/usr/local/sbin:$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin
	mkdir build && cmake -S . -B build -DCMAKE_PREFIX_PATH=qt/qt/lib/cmake/ -DCMAKE_BUILD_TYPE=Release \
		-DPython3_EXECUTABLE=$(realpath --no-symlinks $(which python3)) \
		-DCARGO_BIN_PATH=$HOME/.cargo/bin -DCARGO_HOME=$HOME/.cargo
	cmake --build build -j$(nproc)

clean:
	rm -rf build
