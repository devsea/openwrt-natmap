include $(TOPDIR)/rules.mk

PKG_NAME:=natmap
PKG_VERSION:=20250318
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/heiher/natmap/releases/download/$(PKG_VERSION)
PKG_HASH:=7d421e918d6101a6b36e9c9ae487a8b415bc28c1e712593e192b033f888f7e51

PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/natmap
  SECTION:=net
  CATEGORY:=Network
  TITLE:=TCP/UDP port mapping tool for full cone NAT
  URL:=https://github.com/heiher/natmap
  DEPENDS:=+jq +curl +openssl-util
endef

MAKE_FLAGS += REV_ID="$(PKG_VERSION)"

define Package/${PKG_NAME}/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/natmap $(1)/usr/bin/
endef

$(eval $(call BuildPackage,natmap))
