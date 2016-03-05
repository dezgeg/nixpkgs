preConfigurePhases+=" updateAutotoolsGnuConfigScriptsPhase"

updateAutotoolsGnuConfigScriptsPhase() {
    for f in config.sub config.guess; do
        find . -name "$f" -exec cp "@gnu_config@/$f" '{}' \;
    done
}
