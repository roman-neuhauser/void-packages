# vim: set ts=4 sw=4 et:

show_avail() {
    check_pkg_arch "$XBPS_CROSS_BUILD" 2>/dev/null
}

show_pkg_build_depends() {
    local f x _pkgname _srcpkg found result
    local _deps="$1"

    result=$(mktemp) || exit 1

    # build time deps
    for f in ${_deps}; do
        if [ -z "$CROSS_BUILD" ]; then
            # ignore dependency on itself
            [[ $f == $sourcepkg ]] && continue
        fi
        if [ ! -f $XBPS_SRCPKGDIR/$f/template ]; then
            msg_error "$pkgver: dependency '$f' does not exist!\n"
        fi
        # ignore virtual dependencies
        [[ ${f%\?*} != ${f#*\?} ]] && f=${f#*\?}
        unset found
        # check for subpkgs
        for x in ${subpackages}; do
            [[ $f == $x ]] && found=1 && break
        done
        [[ $found ]] && continue
        _pkgname=${f/-32bit}
        _srcpkg=$(readlink -f ${XBPS_SRCPKGDIR}/${_pkgname})
        _srcpkg=${_srcpkg##*/}
        echo "${_srcpkg}" >> $result
    done
    sort -u $result
    rm -f $result
}

show_pkg_build_options() {
    local f opt desc

    [ -z "$PKG_BUILD_OPTIONS" ] && return 0

    source $XBPS_COMMONDIR/options.description
    msg_normal "$pkgver: the following build options are set:\n"
    for f in ${PKG_BUILD_OPTIONS}; do
        opt="${f#\~}"
        eval desc="\${desc_option_${opt}}"
        if [[ ${f:0:1} == '~' ]]; then
            echo "   $opt: $desc (OFF)"
        else
            printf "   "
            msg_normal_append "$opt: "
            printf "$desc (ON)\n"
        fi
    done
}
