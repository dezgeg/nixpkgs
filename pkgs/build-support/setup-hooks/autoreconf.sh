preConfigurePhases+=" autoreconfPhase"

autoreconfPhase() {
    commonPhaseImpl autoreconfPhase --default defaultAutoreconfPhase --pre-hook preAutoreconf --post-hook postAutoreconf
}

defaultAutoreconfPhase() {
    autoreconf ${autoreconfFlags:---install --force --verbose}
}
