NAME = carbon-c-relay
VERSION = 3.2
RELEASE = 1
GIT_REPO = https://github.com/grobian/carbon-c-relay
PKG_HOME_ROOT = /opt

build-bin:
	if [ ! -d "build" ]; then \
		git clone $(GIT_REPO) build; \
	fi
	cd build && \
	git co tags/v$(VERSION) && \
	autoreconf -f -i && \
	./configure --prefix=/opt/$(NAME) && \
	make && \
	mkdir dist && \
	DESTDIR=./dist make install

build-deb:
	rm -rf $(NAME)-$(VERSION)
	cp -a deb-root $(NAME)-$(VERSION)
	cp -Rp build/dist/* $(NAME)-$(VERSION)/
	sed -e "s#%VERSION%#$(VERSION)#" \
	        -e "s#%NAME%#$(NAME)#" \
	        -e "s#%RELEASE%#$(RELEASE)#" deb-root/DEBIAN/control.in > $(NAME)-$(VERSION)/DEBIAN/control

	mkdir -p $(NAME)-$(VERSION)/$(PKG_HOME_ROOT)/$(NAME)
	if [ ! -e "build/dist"  ]; then \
		echo "Error: build/dist not found. run 'make build' first"; \
		exit 1; \
	fi
	fakeroot dpkg-deb --build $(NAME)-$(VERSION) && mv $(NAME)-$(VERSION).deb $(NAME)_$(VERSION)-$(RELEASE)_all.deb

all: build-bin build-deb

clean-build:
	@rm -rf build

clean-deb:
	@rm -rf $(NAME)-$(VERSION) *.deb

clean: clean-deb clean-build


