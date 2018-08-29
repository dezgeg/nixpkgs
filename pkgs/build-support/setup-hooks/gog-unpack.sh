unpackPhase="unpackGog"

unpackGog() {
    commonPhaseImpl unpackGog --default defaultUnpackGog --pre-hook preUnpackGog --post-hook postUnpackGog
}

defaultUnpackGog() {
    innoextract --silent --extract --exclude-temp "${src}"

    find . -depth -print -execdir rename -f 'y/A-Z/a-z/' '{}' \;
}
