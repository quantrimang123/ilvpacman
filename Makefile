export GO111MODULE=on
GOPROXY ?= https://proxy.golang.org,direct
export GOPROXY

BUILD_TAG = devel
ARCH ?= $(shell uname -m)
BIN := ilvpacman
DESTDIR :=
GO ?= go
PKGNAME := ilvpacman
PREFIX := /usr/local

MAJORVERSION := 0
MINORVERSION := 0
PATCHVERSION := 1
VERSION ?= ${MAJORVERSION}.${MINORVERSION}.${PATCHVERSION}

LOCALEDIR := po
SYSTEMLOCALEPATH := $(PREFIX)/share/locale/

# ls -1 po | sed -e 's/\.po$//' | paste -sd " "
LANGS := ca ca_ES cs da da_DK de en es eu fi fr fr_FR he he_IL hu id it_IT ja ko nl pl pl_PL pt pt_BR ru ru_RU sk sv tr uk vi vi_VN zh_CN zh_TW
POTFILE := default.pot
POFILES := $(addprefix $(LOCALEDIR)/,$(addsuffix .po,$(LANGS)))
MOFILES := $(POFILES:.po=.mo)

FLAGS ?= -trimpath -mod=readonly -modcacherw
EXTRA_FLAGS ?= -buildmode=pie
LDFLAGS := -X "main.ilvVersion=${VERSION}" -X "main.localePath=${SYSTEMLOCALEPATH}" -linkmode=external -compressdwarf=false

RELEASE_DIR := ${PKGNAME}_${VERSION}_${ARCH}
PACKAGE := $(RELEASE_DIR).tar.gz
SOURCES ?= $(shell find . -name "*.go" -type f)

.PRECIOUS: ${LOCALEDIR}/%.po

.PHONY: default
default: build

.PHONY: all
all: | clean release

.PHONY: clean
clean:
	$(GO) clean $(FLAGS) -i ./...
	rm -rf $(BIN) $(PKGNAME)_*

.PHONY: test_lint
test_lint: test lint

.PHONY: test
test:
	$(GO) test -race -covermode=atomic $(FLAGS) ./...

.PHONY: test-integration
test-integration:
	$(GO) test -tags=integration $(FLAGS) ./...

.PHONY: build
build: $(BIN)
	@echo "Đang build phiên bản $(VERSION) cho $(ARCH)..."
$(BIN): $(SOURCES)
	$(GO) build $(FLAGS) -ldflags '$(LDFLAGS)' $(EXTRA_FLAGS) -o $@

.PHONY: release
release: $(PACKAGE)

.PHONY: docker-build
docker-build:
	-docker rm -f ilvpacman-$(ARCH) 2>/dev/null
	docker build -t ilvpacman:${ARCH} .
	docker run --name ilvpacman-$(ARCH) ilvpacman:${ARCH} make release VERSION=${VERSION} PREFIX=${PREFIX} ARCH=${ARCH}
	docker cp ilvpacman-$(ARCH):/app/${BIN} ./${BIN}
.PHONY: docker-release
docker-release: docker-build
	@echo "Đang lấy file $(PACKAGE) từ container..."
	mkdir -p ./dist
	docker cp ilvpacman-$(ARCH):/app/$(PACKAGE) ./dist/
	docker rm -f ilvpacman-$(ARCH)
	cp ./dist/$(PACKAGE) ./
.PHONY: docker-release-all
docker-release-all:
	$(MAKE) docker-release ARCH=armv7h
	$(MAKE) docker-release ARCH=x86_64
	$(MAKE) docker-release ARCH=aarch64

.PHONY: lint
lint:
	GOFLAGS="$(FLAGS)" golangci-lint run ./...

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: install
install: build ${MOFILES}
	install -Dm755 ${BIN} $(DESTDIR)$(PREFIX)/bin/${BIN}
	install -Dm644 doc/${PKGNAME}.8 $(DESTDIR)$(PREFIX)/share/man/man8/${PKGNAME}.8
	install -Dm644 completions/bash $(DESTDIR)$(PREFIX)/share/bash-completion/completions/${PKGNAME}
	install -Dm644 completions/zsh $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_${PKGNAME}
	install -Dm644 completions/fish $(DESTDIR)$(PREFIX)/share/fish/vendor_completions.d/${PKGNAME}.fish
	install -Dm644 meta/ilvpacman.d.lua $(DESTDIR)$(PREFIX)/share/${PKGNAME}/meta/ilvpacman.d.lua
	for lang in ${LANGS}; do \
		install -Dm644 ${LOCALEDIR}/$${lang}.mo $(DESTDIR)$(PREFIX)/share/locale/$$lang/LC_MESSAGES/${PKGNAME}.mo; \
	done

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/${BIN}
	rm -f $(DESTDIR)$(PREFIX)/share/man/man8/${PKGNAME}.8
	rm -f $(DESTDIR)$(PREFIX)/share/bash-completion/completions/${PKGNAME}
	rm -f $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_${PKGNAME}
	rm -f $(DESTDIR)$(PREFIX)/share/fish/vendor_completions.d/${PKGNAME}.fish
	rm -f $(DESTDIR)$(PREFIX)/share/${PKGNAME}/meta/ilvpacman.d.lua
	for lang in ${LANGS}; do \
		rm -f $(DESTDIR)$(PREFIX)/share/locale/$$lang/LC_MESSAGES/${PKGNAME}.mo; \
	done

.PHONY: package
package: build
	@echo "Đang chuẩn bị gói hàng..."
	mkdir -p $(RELEASE_DIR)$(PREFIX)/bin
	cp $(BIN) $(RELEASE_DIR)$(PREFIX)/bin/
    tar -czvf $(PACKAGE) -C $(RELEASE_DIR) .
    rm -rf $(RELEASE_DIR)
	@echo "Đã đóng gói xong thành: $(PACKAGE)"

locale:
	xgotext -in . -out po
	mv po/default.pot po/en.po
	for lang in ${LANGS}; do \
		test -f po/$$lang.po || msginit --no-translator -l po/$$lang.po -i po/${POTFILE} -o po/$$lang.po; \
		msgmerge -U po/$$lang.po po/${POTFILE}; \
		touch po/$$lang.po; \
	done

${LOCALEDIR}/%.mo: ${LOCALEDIR}/%.po
	msgfmt -o $@ $<
