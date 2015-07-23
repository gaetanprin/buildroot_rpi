################################################################################
# Linux Adeos/Xenomai extensions
#
# Patch the linux kernel with xenomai extension
################################################################################

LINUX_EXTENSIONS += xenomai

# Adeos patch version
XENOMAI_ADEOS_PATCH = $(call qstrip,$(BR2_LINUX_KERNEL_EXT_XENOMAI_ADEOS_PATCH))
ifeq ($(XENOMAI_ADEOS_PATCH),)
XENOMAI_ADEOS_OPTS = --default
else
XENOMAI_ADEOS_OPTS = --ipipe=$(XENOMAI_ADEOS_PATCH)
endif

# Adeos patch version
XENOMAI_KERNEL_POST_PATCH_DIR = $(call qstrip,$(BR2_LINUX_KERNEL_EXT_XENOMAI_KPOST_PATCH_DIR))
ifeq ($(XENOMAI_KERNEL_POST_PATCH_DIR),)
KERNEL_POST_PATCH_DIR = /dev/null
else
KERNEL_POST_PATCH_DIR = $(XENOMAI_KERNEL_POST_PATCH_DIR)
endif

# Prepare kernel patch + Apply post patch
define XENOMAI_PREPARE_KERNEL
	$(XENOMAI_DIR)/scripts/prepare-kernel.sh \
		--linux=$(LINUX_DIR) \
		--arch=$(KERNEL_ARCH) \
		$(XENOMAI_ADEOS_OPTS) \
		--verbose
	patch -p1 --directory=$(LINUX_DIR) --verbose < $(shell ls $(KERNEL_POST_PATCH_DIR)/*.patch)
endef
