TARGET=./build
ARCHS=amd64
LDFLAGS="-s -w"
GCFLAGS="all=-trimpath=$(shell pwd)"
ASMFLAGS="all=-trimpath=$(shell pwd)"
SOURCE="./cmd/"
APPNAME=vulwarning

current:
	@mkdir -p ${TARGET}/
	@rm -f ./${TARGET}/${APPNAME}
	@go build -o ${TARGET}/${APPNAME} ${SOURCE}; \
	echo "Done."

fmt:
	@go fmt ./...; \
	echo "Done."

update:
	@go get -u; \
	go mod tidy -v; \
	echo "Done."

windows:
	@for GOARCH in ${ARCHS}; do \
		echo "Building for windows $${GOARCH} ..." ; \
		GOOS=windows GOARCH=$${GOARCH} GO111MODULE=on CGO_ENABLED=0 go build -ldflags=${LDFLAGS} -gcflags=${GCFLAGS} -asmflags=${ASMFLAGS} -o ${TARGET}/${APPNAME}-windows-$${GOARCH}.exe ${SOURCE}; \
	done; \
	echo "Done."

linux:
	@for GOARCH in ${ARCHS}; do \
		echo "Building for linux $${GOARCH} ..." ; \
		GOOS=linux GOARCH=$${GOARCH} GO111MODULE=on CGO_ENABLED=0 go build -ldflags=${LDFLAGS} -gcflags=${GCFLAGS} -asmflags=${ASMFLAGS} -o ${TARGET}/${APPNAME}-linux-$${GOARCH} ${SOURCE}; \
	done; \
	echo "Done."

darwin:
	@for GOARCH in ${ARCHS}; do \
		echo "Building for darwin $${GOARCH} ..." ; \
		GOOS=darwin GOARCH=$${GOARCH} GO111MODULE=on CGO_ENABLED=0 go build -ldflags=${LDFLAGS} -gcflags=${GCFLAGS} -asmflags=${ASMFLAGS} -o ${TARGET}/${APPNAME}-darwin-$${GOARCH} ${SOURCE} ; \
	done; \
	echo "Done."

all: clean fmt update lint test darwin linux windows

test:
	@go test -v -race ./... ; \
	echo "Done."

lint:
	@go get -u github.com/golangci/golangci-lint@master ; \
	golangci-lint run ./... ; \
	go mod tidy ; \
	echo Done

install: current
	cp -f ${TARGET}/${APPNAME} ${go env GOPATH}/bin/${APPNAME}

clean:
	@rm -rf ${TARGET}/* ; \
	go clean ./... ; \
	echo "Done."


archive: linux darwin
	cd ${TARGET}; \
	echo "[+] Archive ${APPNAME} ..." ; \
	sha256sum ${APPNAME}* > SHA256.txt; \
	for n in $$(ls ${APPNAME}*); do \
		zip $${n}.zip -9 $${n}; \
	done;
