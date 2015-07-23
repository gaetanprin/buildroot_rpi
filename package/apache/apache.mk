################################################################################
#
# apache
#
################################################################################

APACHE_VERSION = 2.4.12
APACHE_SOURCE = httpd-$(APACHE_VERSION).tar.bz2
APACHE_SITE = http://archive.apache.org/dist/httpd
APACHE_LICENSE = Apache-2.0
APACHE_LICENSE_FILES = LICENSE
# Needed for mod_php
APACHE_INSTALL_STAGING = YES
# We have a patch touching configure.in and Makefile.in,
# so we need to autoreconf:
APACHE_AUTORECONF = YES
APACHE_DEPENDENCIES = apr apr-util pcre

APACHE_CONF_ENV= \
	ac_cv_file__dev_zero=yes \
	ac_cv_func_setpgrp_void=yes \
	apr_cv_tcp_nodelay_with_cork=yes \
	ac_cv_sizeof_struct_iovec=8 \
	apr_cv_process_shared_works=yes \
	apr_cv_mutex_robust_shared=no \
	ac_cv_struct_rlimit=yes \
	ap_cv_void_ptr_lt_long=no \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PCRE_CONFIG=$(STAGING_DIR)/usr/bin/pcre-config

APACHE_CONF_OPTS = \
	--sysconfdir=/etc/apache2 \
	--with-apr=$(STAGING_DIR)/usr \
	--with-apr-util=$(STAGING_DIR)/usr \
	--with-pcre=$(STAGING_DIR)/usr/bin/pcre-config \
	--enable-http \
	--enable-dbd \
	--enable-proxy \
	--enable-mime-magic \
	--without-suexec-bin \
	--enable-mods-shared=all \
	--enable-so \
	--enable-module=all \
	--with-mpm=worker \
	--enable-rewrite \
	--disable-lua \
	--disable-luajit

ifeq ($(BR2_ARCH_HAS_ATOMICS),y)
APACHE_CONF_OPTS += --enable-nonportable-atomics=yes
endif

ifeq ($(BR2_PACKAGE_LIBXML2),y)
APACHE_DEPENDENCIES += libxml2
# Apache wants the path to the header file, where it can find
# <libxml/parser.h>.
APACHE_CONF_OPTS += \
	--enable-xml2enc \
	--enable-proxy-html \
	--with-libxml2=$(STAGING_DIR)/usr/include/libxml2
else
APACHE_CONF_OPTS += \
	--disable-xml2enc \
	--disable-proxy-html
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
APACHE_DEPENDENCIES += openssl
APACHE_CONF_OPTS += \
	--enable-ssl \
	--with-ssl=$(STAGING_DIR)/usr
else
APACHE_CONF_OPTS += --disable-ssl
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
APACHE_DEPENDENCIES += zlib
APACHE_CONF_OPTS += \
	--enable-deflate \
	--with-z=$(STAGING_DIR)/usr
else
APACHE_CONF_OPTS += --disable-deflate
endif

define APACHE_FIX_STAGING_APACHE_CONFIG
	$(SED) 's%/usr/build%$(STAGING_DIR)/usr/build%' $(STAGING_DIR)/usr/bin/apxs
	$(SED) 's%^prefix =.*%prefix = $(STAGING_DIR)/usr%' $(STAGING_DIR)/usr/build/config_vars.mk
endef
APACHE_POST_INSTALL_STAGING_HOOKS += APACHE_FIX_STAGING_APACHE_CONFIG

define APACHE_CLEANUP_TARGET
	$(RM) -rf $(TARGET_DIR)/usr/manual $(TARGET_DIR)/usr/build
	# Installation du service S90apache
	$(INSTALL) -m 0755 package/apache/FilesSystem/S90apache $(TARGET_DIR)/etc/init.d/S90apache
	# Copie du fichier de configuration d'apache
	cp package/apache/FilesSystem/httpd.conf $(TARGET_DIR)/etc/apache2/httpd.conf
	# Inscription des droits admin pour l'utilisateur daemon
	cp package/apache/FilesSystem/sudoers $(TARGET_DIR)/etc/sudoers
	# Copie des fichiers WWW
	cp -rf package/apache/HTML/www $(TARGET_DIR)/var/www
endef
APACHE_POST_INSTALL_TARGET_HOOKS += APACHE_CLEANUP_TARGET

$(eval $(autotools-package))
