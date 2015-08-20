# Optionally print debug info.
echo "original flags to @prog@:" >>$NIX_BUILD_TOP/massive-debug-hack.log
for i in "${params[@]}"; do
    echo "  $i" >>$NIX_BUILD_TOP/massive-debug-hack.log
done
echo "extraBefore flags to @prog@:" >>$NIX_BUILD_TOP/massive-debug-hack.log
for i in ${extraBefore[@]}; do
    echo "  $i" >>$NIX_BUILD_TOP/massive-debug-hack.log
done
echo "extraAfter flags to @prog@:" >>$NIX_BUILD_TOP/massive-debug-hack.log
for i in ${extraAfter[@]}; do
    echo "  $i" >>$NIX_BUILD_TOP/massive-debug-hack.log
done
echo '--------------' >>$NIX_BUILD_TOP/massive-debug-hack.log
