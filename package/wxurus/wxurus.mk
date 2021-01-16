################################################################################
#
# wxurus
#
################################################################################

WXURUS_VERSION = afee1424dabc2c568a9830a6672812f2bad5fb78
WXURUS_SITE = $(call github,UrusTeam,wxWidgets,$(WXURUS_VERSION))
WXURUS_LICENSE = WXWINDOWS
WXURUS_LICENSE_FILES = licence.txt
WXURUS_DEPENDENCIES = host-pkgconf libgl libglu pango
#WXURUS_DEPENDENCIES = host-pkgconf libgl libglew libglu \
#					pango freetype libpng jpeg-turbo tiff

WXURUS_INSTALL_STAGING = YES
WXURUS_INSTALL_TARGET = YES

ifeq ($(BR2_PACKAGE_LIBGTK3),y)
WXURUS_CONF_OPTS += --with-gtk=3
else ifeq ($(BR2_PACKAGE_LIBGTK2),y)
WXURUS_CONF_OPTS += --with-gtk=2
else
WXURUS_CONF_OPTS += --with-x11
WXURUS_DEPENDENCIES += xlib_libX11 libxcb
#WXURUS_DEPENDENCIES += xlib_libX11
endif

WXURUS_CONF_OPTS += --enable-monolithic
WXURUS_CONF_OPTS += --enable-shared
WXURUS_CONF_OPTS += --disable-static
WXURUS_CONF_OPTS += --with-opengl
WXURUS_CONF_OPTS += --enable-threads
WXURUS_CONF_OPTS += --disable-debug_flag
WXURUS_CONF_OPTS += --disable-precomp-headers
WXURUS_CONF_OPTS += --enable-unicode
WXURUS_CONF_OPTS += --with-flavour=urus
WXURUS_CONF_OPTS += --enable-vendor=urus
WXURUS_CONF_OPTS += --enable-no_exceptions
#WXURUS_CONF_OPTS += OPENGL_LIBS="$(pkg-config gl --libs)"
WXURUS_CONF_OPTS += --prefix=/usr
WXURUS_CONF_OPTS += --disable-compat28
#WXURUS_CONF_OPTS += --with-libpng=sys
#WXURUS_CONF_OPTS += --with-regex=sys
#WXURUS_CONF_OPTS += --with-libjpeg=sys
#WXURUS_CONF_OPTS += --with-libtiff=sys
#WXURUS_CONF_OPTS += --with-expat=sys

WXURUS_PKG_FLAGS += `$(PKG_CONFIG_HOST_BINARY) cairo pango freetype2 --cflags`
WXURUS_CFLAGS += $(TARGET_CFLAGS) -Wall -Wno-unused-local-typedefs -Wno-narrowing -Os -funroll-loops -fdata-sections -ffunction-sections
WXURUS_CXXFLAGS += $(TARGET_CXXFLAGS) -Wall -Wno-unused-local-typedefs -Wno-narrowing -Wno-literal-suffix -fpermissive -Os -funroll-loops -fdata-sections -ffunction-sections
WXURUS_LDFLAGS += $(TARGET_LDFLAGS) -Wl,--gc-sections
WXURUS_CONF_ENV += "CFLAGS=$(WXURUS_CFLAGS)"
WXURUS_CONF_ENV += "CXXFLAGS=$(WXURUS_CXXFLAGS)"
WXURUS_CONF_ENV += "LDFLAGS=$(WXURUS_LDFLAGS)"
#WXURUS_CONF_ENV += LDFLAGS="$(TARGET_LDFLAGS) $(pkg-config gl glew glu --libs)"

define WXURUS_CONFIGURE_CMDS
	( cd $(WXURUS_SRCDIR) && rm -rf config.cache &&\
	$(TARGET_CONFIGURE_OPTS) \
	$(TARGET_CONFIGURE_ARGS) \
	./configure \
		--host="$(BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX)" \
		--target="$(BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX)" \
		PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
		$(WXURUS_CONF_ENV) \
		$(WXURUS_CONF_OPTS))
endef

define WXURUS_BUILD_CMDS
	( cd $(WXURUS_SRCDIR) && \
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) $(WXURUS_BUILD_TARGETS) \
	CFLAGS+="$(WXURUS_CFLAGS) `./wx-config --cflags` $(WXURUS_PKG_FLAGS)" \
	CXXFLAGS+="$(WXURUS_CXXFLAGS) `./wx-config --cflags` $(WXURUS_PKG_FLAGS)" \
	LDFLAGS+="$(WXURUS_LDFLAGS)")
endef

define WXURUS_INSTALL_TARGET_CMDS
	( cd $(WXURUS_SRCDIR) && \
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) \
		DESTDIR=$(TARGET_DIR) \
		$(WXURUS_INSTALL_TARGETS) install)
endef

$(eval $(generic-package))
