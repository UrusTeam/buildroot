################################################################################
#
# psplash
#
################################################################################

PSPLASH_VERSION = 5b3c1cc28f5abdc2c33830150b48b278cc4f7bca
PSPLASH_SITE = git://git.yoctoproject.org/psplash
PSPLASH_LICENSE = GPL-2.0+
PSPLASH_LICENSE_FILES = COPYING
PSPLASH_AUTORECONF = YES
PSPLASH_DEPENDENCIES = host-gdk-pixbuf host-pkgconf

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
PSPLASH_DEPENDENCIES += systemd
PSPLASH_CONF_OPTS += --with-systemd
else
PSPLASH_CONF_OPTS += --without-systemd
endif

define PSPLASH_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 package/psplash/psplash-start.service \
		$(TARGET_DIR)/usr/lib/systemd/system/psplash-start.service

	$(INSTALL) -D -m 644 package/psplash/psplash-systemd.service \
		$(TARGET_DIR)/usr/lib/systemd/system/psplash-systemd.service
endef

$(eval $(autotools-package))
