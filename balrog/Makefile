all:
	make clean install build
build:
	GOARCH=amd64 go build -buildmode c-archive -v
install:
	go install
clean:
	git clean -x -f
