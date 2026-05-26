#!/usr/bin/env bash
#
# Symlinks `games` -> `~/dosgames` and `game_launchers` to `~/Desktop/DOS Games`

set -eui pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GAMES_SOURCE_DIR="${SCRIPT_DIR}/dosgames"
GAMES_LINK_LOC="${HOME}/dosgames"

LAUNCHERS_SOURCE_DIR="${SCRIPT_DIR}/game_launchers"
LAUNCHERS_LINK_LOC="${HOME}/Desktop/DOS Games"

echo "Games Source directory: ${GAMES_SOURCE_DIR}"
echo "Games Symlink: ${GAMES_LINK_LOC}"

echo "Launchers Source directory: ${LAUNCHERS_SOURCE_DIR}"
echo "Launchers Symlink: ${LAUNCHERS_LINK_LOC}"

CREATE_GAME_LINK=0
CREATE_LAUNCHER_LINK=0

if [[ ! -d "${GAMES_SOURCE_DIR}" ]]; then
    echo "ERR: Games source directory does not exist"
    echo "  ${GAMES_SOURCE_DIR}"
    exit 1
fi

if [[ ! -d "${LAUNCHERS_SOURCE_DIR}" ]]; then
    echo "ERR: Launcher source directory does not exist"
    echo "  ${LAUNCHERS_SOURCE_DIR}"
    exit 1
fi

if [[ ! -d "${HOME}/Desktop" ]]; then
    echo "ERR: Desktop directory does not exist"
    echo "  ${HOME}/Desktop"
    exit 1
fi

if [[ -L "${GAMES_LINK_LOC}" ]]; then
    CURRENT_TARGET="$(readlink "${GAMES_LINK_LOC}")"
    EXPECTED_TARGET="${GAMES_SOURCE_DIR}"

    if [[ "${CURRENT_TARGET}" == "${EXPECTED_TARGET}" ]]; then
        echo "Games symlink already correctly configured."
    else
        echo "Existing games symlink points elsewhere:"
        echo "  ${GAMES_LINK_LOC} -> ${CURRENT_TARGET}"
        read -r -p "Replace it? [y/N] " REPLY

        case "${REPLY}" in
            [yY][eE][sS]|[yY])
                rm -- "${GAMES_LINK_LOC}"
                CREATE_GAME_LINK=1
                ;;
            *)
                echo "Will not overwrite games symlink"
                ;;
        esac
    fi
elif [[ -e "${GAMES_LINK_LOC}" ]]; then
    echo "ERR: Target already exists and is not a symlink:"
    echo "  ${GAMES_LINK_LOC}"
    echo
    echo "Refusing to overwrite"
else
    CREATE_GAME_LINK=1
fi

if [[ -L "${LAUNCHERS_LINK_LOC}" ]]; then
    CURRENT_TARGET="$(readlink "${LAUNCHERS_LINK_LOC}")"
    EXPECTED_TARGET="${LAUNCHERS_SOURCE_DIR}"

    if [[ "${CURRENT_TARGET}" == "${EXPECTED_TARGET}" ]]; then
        echo "Launchers symlink already correctly configured."
    else
        echo "Existing launchers symlink points elsewhere:"
        echo "  ${LAUNCHERS_LINK_LOC} -> ${CURRENT_TARGET}"
        read -r -p "Replace it? [y/N] " REPLY

        case "${REPLY}" in
            [yY][eE][sS]|[yY])
                rm -- "${LAUNCHERS_LINK_LOC}"
                CREATE_LAUNCHER_LINK=1
                ;;
            *)
                echo "Will not overwrite launchers symlink"
                ;;
        esac
    fi
elif [[ -e "${LAUNCHERS_LINK_LOC}" ]]; then
    echo "ERR: Target already exists and is not a symlink:"
    echo "  ${LAUNCHERS_LINK_LOC}"
    echo
    echo "Refusing to overwrite"
else
    CREATE_LAUNCHER_LINK=1
fi

if [[ $CREATE_GAME_LINK -eq 1 ]]; then
    ln -s -- "${GAMES_SOURCE_DIR}" "${GAMES_LINK_LOC}"
    echo "Created ${GAMES_LINK_LOC} -> ${GAMES_SOURCE_DIR}"
fi

if [[ $CREATE_LAUNCHER_LINK -eq 1 ]]; then
    ln -s -- "${LAUNCHERS_SOURCE_DIR}" "${LAUNCHERS_LINK_LOC}"
    echo "Created ${LAUNCHERS_LINK_LOC} -> ${LAUNCHERS_SOURCE_DIR}"
fi
echo "Done."

