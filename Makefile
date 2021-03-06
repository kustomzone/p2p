CC=go
PACK=goupx
VERSION=$(shell git describe)
OS=$(shell uname -s)
ARCH=$(shell uname -m)
NAME_PREFIX=p2p
NAME_BASE=p2p
sinclude config.make
APP=$(NAME_BASE)

build: $(APP)
ifdef UPX_BIN
release: pack
endif

linux: $(APP)
windows: $(APP).exe
macos: $(APP)_osx

all: linux windows macos

$(APP): help.go instance.go main.go
	@if [ ! -d "$(GOPATH)/src/github.com/subutai-io/p2p" ]; then mkdir -p $(GOPATH)/src/github.com/subutai-io/; ln -s $(shell pwd) $(GOPATH)/src/github.com/subutai-io/p2p; fi
	$(CC) build -ldflags="-w -s -X main.AppVersion=$(VERSION)" -o $@ -v $^

$(APP).exe:
	@if [ ! -d "$(GOPATH)/src/github.com/subutai-io/p2p" ]; then mkdir -p $(GOPATH)/src/github.com/subutai-io/; ln -s $(shell pwd) $(GOPATH)/src/github.com/subutai-io/p2p; fi
	GOOS=windows $(CC) build -ldflags="-w -s -X main.AppVersion=$(VERSION)" -o $@ -v $^
	
$(APP)_osx:
	@if [ ! -d "$(GOPATH)/src/github.com/subutai-io/p2p" ]; then mkdir -p $(GOPATH)/src/github.com/subutai-io/; ln -s $(shell pwd) $(GOPATH)/src/github.com/subutai-io/p2p; fi
	GOOS=darwin $(CC) build -ldflags="-w -s -X main.AppVersion=$(VERSION)" -o $@ -v $^

ifdef UPX_BIN
pack: $(APP)
	$(PACK) $(APP)
endif

clean:
	-rm -f $(APP)
	-rm -f $(APP)_osx
	-rm -f $(APP).exe
	-rm -f $(APP)-$(OS)*
	-rm -f $(NAME_PREFIX)
	-rm -f $(NAME_PREFIX)_osx
	-rm -f $(NAME_PREFIX).exe
	-rm -f $(NAME_PREFIX)-$(OS)*

mrproper: clean
mrproper:
	-rm -f config.make

ifeq ($(BUILD_DEB), 1)
test:  $(APP)
	go test ./...
else
test: skip-test
endif

skip-test: $(APP)
	@echo "Test skipped"

release: build
release:
	-mv $(APP) $(APP)-$(OS)-$(ARCH)-$(VERSION)

install: 
	@mkdir -p $(DESTDIR)/opt/subutai/bin
	@cp $(APP) $(DESTDIR)/opt/subutai/bin/$(NAME_PREFIX)

uninstall:
	@rm -f $(DESTDIR)/bin/$(NAME_PREFIX)

ifeq ($(BUILD_DEB), 1)
debian: *.deb

*.deb:
	debuild --preserve-env -B -d

debian-source: *.changes

*.changes:
	debuild --preserve-env -S -d
endif

snapcraft: help.go instance.go main.go
	$(eval export GOPATH=$(shell pwd)/../go)
	$(eval export GOBIN=$(shell pwd)/../go/bin)
	@if [ ! -d "$(GOPATH)/src/github.com/subutai-io/p2p" ]; then mkdir -p $(GOPATH)/src/github.com/subutai-io/; ln -s $(shell pwd) $(GOPATH)/src/github.com/subutai-io/p2p; fi
	$(CC) get -d
	$(CC) build -ldflags="-r /apps/subutai/current/lib -w -s -X main.AppVersion=$(VERSION)" -o $(APP) -v $^
