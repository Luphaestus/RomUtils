GENERATE_LPMAKE_OPT()
{
    local OPT
    local GROUP_NAME="group_basic"
    local HAS_SYSTEM=false
    local HAS_VENDOR=false
    local HAS_PRODUCT=false
    local HAS_SYSTEM_EXT=false
    local HAS_ODM=false
    local HAS_VENDOR_DLKM=false
    local HAS_ODM_DLKM=false
    local HAS_SYSTEM_DLKM=false
    TMP_DIR=./"rom"

    [ -f "$TMP_DIR/system.img" ] && HAS_SYSTEM=true
    [ -f "$TMP_DIR/vendor.img" ] && HAS_VENDOR=true
    [ -f "$TMP_DIR/product.img" ] && HAS_PRODUCT=true
    [ -f "$TMP_DIR/system_ext.img" ] && HAS_SYSTEM_EXT=true
    [ -f "$TMP_DIR/odm.img" ] && HAS_ODM=true
    [ -f "$TMP_DIR/vendor_dlkm.img" ] && HAS_VENDOR_DLKM=true
    [ -f "$TMP_DIR/odm_dlkm.img" ] && HAS_ODM_DLKM=true
    [ -f "$TMP_DIR/system_dlkm.img" ] && HAS_SYSTEM_DLKM=true

    OPT+="--sparse"
    OPT+=" -o $TMP_DIR/super.img"
    OPT+=" --device-size 10276044800"
    OPT+=" --metadata-size 65536 --metadata-slots 2"
    OPT+=" -g $GROUP_NAME:10271850496"


    if $HAS_SYSTEM; then
        OPT+=" -p system:readonly:$(wc -c "$TMP_DIR/system.img" | cut -d " " -f 1):$GROUP_NAME"
    fi
    if $HAS_VENDOR; then
        OPT+=" -p vendor:readonly:$(wc -c "$TMP_DIR/vendor.img" | cut -d " " -f 1):$GROUP_NAME"
    fi
    if $HAS_PRODUCT; then
        OPT+=" -p product:readonly:$(wc -c "$TMP_DIR/product.img" | cut -d " " -f 1):$GROUP_NAME"
    fi
    if $HAS_SYSTEM_EXT; then
        OPT+=" -p system_ext:readonly:$(wc -c "$TMP_DIR/system_ext.img" | cut -d " " -f 1):$GROUP_NAME"
    fi
    if $HAS_ODM; then
        OPT+=" -p odm:readonly:$(wc -c "$TMP_DIR/odm.img" | cut -d " " -f 1):$GROUP_NAME"
    fi
    if $HAS_VENDOR_DLKM; then
        OPT+=" -p vendor_dlkm:readonly:$(wc -c "$TMP_DIR/vendor_dlkm.img" | cut -d " " -f 1):$GROUP_NAME"
    fi
    if $HAS_ODM_DLKM; then
        OPT+=" -p odm_dlkm:readonly:$(wc -c "$TMP_DIR/odm_dlkm.img" | cut -d " " -f 1):$GROUP_NAME"
    fi
    if $HAS_SYSTEM_DLKM; then
        OPT+=" -p system_dlkm:readonly:$(wc -c "$TMP_DIR/system_dlkm.img" | cut -d " " -f 1):$GROUP_NAME"
    fi

    if $HAS_SYSTEM; then
        OPT+=" -i system=$TMP_DIR/system.img"
    fi
    if $HAS_VENDOR; then
        OPT+=" -i vendor=$TMP_DIR/vendor.img"
    fi
    if $HAS_PRODUCT; then
        OPT+=" -i product=$TMP_DIR/product.img"
    fi
    if $HAS_SYSTEM_EXT; then
        OPT+=" -i system_ext=$TMP_DIR/system_ext.img"
    fi
    if $HAS_ODM; then
        OPT+=" -i odm=$TMP_DIR/odm.img"
    fi
    if $HAS_VENDOR_DLKM; then
        OPT+=" -i vendor_dlkm=$TMP_DIR/vendor_dlkm.img"
    fi
    if $HAS_ODM_DLKM; then
        OPT+=" -i odm_dlkm=$TMP_DIR/odm_dlkm.img"
    fi
    if $HAS_SYSTEM_DLKM; then
        OPT+=" -i system_dlkm=$TMP_DIR/system_dlkm.img"
    fi

    echo "$OPT"
}

CMD="lpmake $(GENERATE_LPMAKE_OPT)"
$CMD
cd rom
rm -f super.img.lz4
rm -f VulcanV
lz4 -B6 --content-size super.img super.img.lz4
tar -c --format=gnu -f VulcanV2.tar super.img.lz4 cache.img.lz4
cd -
