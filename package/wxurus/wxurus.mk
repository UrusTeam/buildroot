################################################################################
#
# wxurus
#
################################################################################

ifeq ($(BR2_PACKAGE_WXURUS_315),y)
WXURUS_VERSION = 0a7e42a6b51272d509d873ec6dda70989c2da728
WXURUS_SITE = https://github.com/hiro2233/wxWidgets
WXURUS_SITE_METHOD = git
WXURUS_GIT_SUBMODULES = YES
else ifeq ($(BR2_PACKAGE_WXURUS_31),y)
WXURUS_VERSION = 97461b586cef4565fb43bc9232ef4450f273af12
WXURUS_SITE = $(call github,UrusTeam,wxWidgets,$(WXURUS_VERSION))
else ifeq ($(BR2_PACKAGE_WXURUS_30),y)
WXURUS_VERSION = afee1424dabc2c568a9830a6672812f2bad5fb78
WXURUS_SITE = $(call github,UrusTeam,wxWidgets,$(WXURUS_VERSION))
else ifeq ($(BR2_PACKAGE_WXURUS_28),y)
WXURUS_VERSION = 06b5126121bf06c3f65760cc6cc96d5284ccd4d6
WXURUS_SITE = $(call github,UrusTeam,wxWidgets,$(WXURUS_VERSION))
endif

WXURUS_LICENSE = WXWINDOWS
WXURUS_LICENSE_FILES = licence.txt
WXURUS_DEPENDENCIES = host-pkgconf pango
#WXURUS_DEPENDENCIES = host-pkgconf libgl libglew libglu \
#					pango freetype libpng jpeg-turbo tiff

WXURUS_INSTALL_STAGING = YES
WXURUS_INSTALL_TARGET = YES

ifeq ($(BR2_PACKAGE_LIBGTK3),y)
WXURUS_DEPENDENCIES += libgtk3
WXURUS_CONF_OPTS += --with-gtk=3
WXURUS_CONF_OPTS += --without-gtkprint
WXURUS_CONF_OPTS += --enable-graphics_ctx
WXURUS_CONF_OPTS += --without-libnotify
ifeq ($(BR2_PACKAGE_LIBGTK3_X11)$(BR2_PACKAGE_WXURUS_30), y)
#disable display and uiactionsim stuff if X11 backend is not set on gtk3.
$(error wxUrus 3.0 need X11 backend on Gtk3)
#WXURUS_CONF_OPTS += --disable-uiactionsim
#WXURUS_CONF_OPTS += --disable-display
endif
#WXURUS_CONF_OPTS += --enable-postscript=no
ifeq ($(BR2_PACKAGE_WXURUS_315),y)
WXURUS_CONF_OPTS += --enable-glcanvasegl=yes
endif
WXURUS_CONF_OPTS += --with-cairo
WXURUS_CONF_OPTS += --with-opengl
WXURUS_PKG_FLAGS += `$(PKG_CONFIG_HOST_BINARY) gtk+-3.0 --cflags`
else ifeq ($(BR2_PACKAGE_LIBGTK2),y)
WXURUS_CONF_OPTS += --with-gtk=2
WXURUS_DEPENDENCIES += libgtk2
WXURUS_CONF_OPTS += --without-gtkprint
#WXURUS_CONF_OPTS += --disable-postscript
WXURUS_CONF_OPTS += --enable-graphics_ctx
WXURUS_CONF_OPTS += --without-libnotify
WXURUS_CONF_OPTS += --with-cairo
WXURUS_CONF_OPTS += --with-opengl
WXURUS_PKG_FLAGS += `$(PKG_CONFIG_HOST_BINARY) gtk+-2.0 --cflags`
else ifeq ($(BR2_PACKAGE_QT5),y)
WXURUS_CONF_OPTS += --with-qt
else
WXURUS_CONF_OPTS += --with-x11
WXURUS_DEPENDENCIES += xlib_libX11 libxcb libgl libglu
WXURUS_CONF_OPTS += --with-opengl
WXURUS_CONF_OPTS += --enable-glcanvasegl=yes
WXURUS_CONF_OPTS += --enable-graphics_ctx
WXURUS_CONF_OPTS += --without-gtkprint
WXURUS_CONF_OPTS += --with-cairo
endif

#WXURUS_DEPENDENCIES += xlib_lib
WXURUS_CONF_OPTS += --enable-monolithic
WXURUS_CONF_OPTS += --enable-shared
WXURUS_CONF_OPTS += --enable-threads
WXURUS_CONF_OPTS += --disable-debug_flag
#WXURUS_CONF_OPTS += --disable-precomp-headers
WXURUS_CONF_OPTS += --enable-unicode
WXURUS_CONF_OPTS += --with-flavour=urus
WXURUS_CONF_OPTS += --enable-vendor=urus
#WXURUS_CONF_OPTS += --enable-no_exceptions
WXURUS_CONF_OPTS += --disable-exceptions
#WXURUS_CONF_OPTS += OPENGL_LIBS="$(pkg-config gl --libs)"
WXURUS_CONF_OPTS += --prefix=/usr
ifeq ($(BR2_PACKAGE_WXURUS_30),y)
WXURUS_CONF_OPTS += --disable-compat28
endif
ifeq ($(BR2_PACKAGE_WXURUS_31),y)
WXURUS_CONF_OPTS += --disable-compat30
endif
ifeq ($(BR2_PACKAGE_WXURUS_315),y)
WXURUS_CONF_OPTS += --disable-compat30
endif
WXURUS_CONF_OPTS += --enable-cmdline
#WXURUS_CONF_OPTS += --disable-gtktest
#WXURUS_CONF_OPTS += --with-libpng=sys
#WXURUS_CONF_OPTS += --with-regex=sys
#WXURUS_CONF_OPTS += --with-libjpeg=sys
#WXURUS_CONF_OPTS += --with-libtiff=sys
#WXURUS_CONF_OPTS += --with-expat=sys

WXURUS_PKG_FLAGS += `$(PKG_CONFIG_HOST_BINARY) cairo pango freetype2 --cflags`
WXURUS_CFLAGS += $(TARGET_CFLAGS) -Wall -Wno-unused-local-typedefs -Wno-narrowing -Os -funroll-loops -fdata-sections -ffunction-sections
WXURUS_CXXFLAGS += $(TARGET_CXXFLAGS) -Wall -Wno-unused-local-typedefs -Wno-narrowing -Wno-literal-suffix -fpermissive -Os -funroll-loops -fdata-sections -ffunction-sections -fexceptions
WXURUS_LDFLAGS += $(TARGET_LDFLAGS) -Wl,--gc-sections
WXURUS_CONF_ENV += "CFLAGS=$(WXURUS_CFLAGS)"
WXURUS_CONF_ENV += "CXXFLAGS=$(WXURUS_CXXFLAGS)"
WXURUS_CONF_ENV += "LDFLAGS=$(WXURUS_LDFLAGS)"
#WXURUS_CONF_ENV += LDFLAGS="$(TARGET_LDFLAGS) $(pkg-config gl glew glu --libs)"

define WXURUS_CONFIGURE_CMDS
	( cd $(WXURUS_SRCDIR) && \
	rm -rf config.cache && \
	$(TARGET_CONFIGURE_OPTS) \
	$(TARGET_CONFIGURE_ARGS) \
	PKG_CONFIG_PATH=$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig \
	./configure \
		--host="$(BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX)" \
		--target="$(BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX)" \
		CFLAGS="$(WXURUS_CFLAGS) $(WXURUS_PKG_FLAGS)" \
		CXXFLAGS="$(WXURUS_CXXFLAGS) $(WXURUS_PKG_FLAGS)" \
		PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
		$(WXURUS_CONF_ENV) \
		$(WXURUS_CONF_OPTS))
endef

define WXURUS_BUILD_CMDS
	( cd $(WXURUS_SRCDIR) && \
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) $(WXURUS_BUILD_TARGETS) \
	CFLAGS+="`./wx-config --cflags` $(WXURUS_PKG_FLAGS)" \
	CXXFLAGS+="`./wx-config --cflags` $(WXURUS_PKG_FLAGS)" \
	LDFLAGS+="$(WXURUS_LDFLAGS)" && \
	cd samples/opengl/cube && $(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) $(WXURUS_BUILD_TARGETS) \
	CFLAGS+="`../../../wx-config --cflags` $(WXURUS_PKG_FLAGS)" \
	CXXFLAGS+="`../../../wx-config --cflags` $(WXURUS_PKG_FLAGS)" \
	LDFLAGS+="$(WXURUS_LDFLAGS)")
endef

define WXURUS_INSTALL_TARGET_CMDS
	( cd $(WXURUS_SRCDIR) && \
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) \
		DESTDIR="$(TARGET_DIR)" PREFIX=/usr install)
endef

define WXURUS_INSTALL_STAGING_CMDS
	( cd $(WXURUS_SRCDIR) && \
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) $(WXURUS_MAKE_OPTS) \
		DESTDIR="$(STAGING_DIR)" PREFIX=/usr install )
endef

$(eval $(generic-package))
