xcbuildBuildPhase() {
    export DSTROOT=$out

    echo "running xcodebuild"

    xcodebuild SYMROOT=$PWD/Products OBJROOT=$PWD/Intermediates $xcbuildFlags build
}

xcbuildInstallPhase () {
    # not implemented
    # xcodebuild install
}

if [ -z "$dontUseXcbuild" ]; then
    buildPhase=xcbuildBuildPhase
    if [ -z "$installPhase" ]; then
        installPhase=xcbuildInstallPhase
    fi
fi

# if [ -d "*.xcodeproj" ]; then
#     buildPhase=xcbuildPhase
# fi
