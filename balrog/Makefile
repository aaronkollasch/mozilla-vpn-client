all:
	make clean install build
build:
	/usr/local/go/bin/go build -buildmode c-archive -v
install:
	go install
clean:
	git clean -x -f
