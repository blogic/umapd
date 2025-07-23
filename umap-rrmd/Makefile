include $(TOPDIR)/rules.mk

PKG_NAME:=umap-rrmd
PKG_RELEASE:=1

PKG_MAINTAINER:=John Crispin <john@phrozen.org>

include $(INCLUDE_DIR)/package.mk

define Package/umap-rrmd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=umap-rrmd
endef

define Package/umap-rrmd/description
	umap RRM daemon
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/umap-rrmd/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,umap-rrmd))
