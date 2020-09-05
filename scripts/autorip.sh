#!/bin/bash

set -euo pipefail

CD_DEV=${CD_DEV:-/dev/cdrom}

__isoinfo_value() {
    grep "$1" | cut -d: -f 2- | xargs
}

__rip_cd() {
    local cd_dev=$1
    local info=$(isoinfo -d -i $cd_dev)
    local label=$(echo "$info" | __isoinfo_value "Volume id")
    local bs=$(echo "$info" | __isoinfo_value "Logical block size")
    local bc=$(echo "$info" | __isoinfo_value "Volume size is")
    local outfile="${label}.iso"

    if [ -f "$outfile" ]; then
        echo "$outfile already exists. Aborting."
        return
    fi

    echo "$info" | tee "${outfile}.isoinfo.txt"
    dd if=$cd_dev of="$outfile" bs=$bs count=$bc status=progress
}

echo "Imaging CDs from ${CD_DEV}"

laststat=""

while true; do
    traystat=$(./cdstat.sh "${CD_DEV}")
    case "$traystat" in
        ready)
            __rip_cd $CD_DEV
            eject $CD_DEV
            ;;
        no_disc)
            echo "Ejecting the tray..."
            eject $CD_DEV
            sleep 2
            ;;
        *)
            if [ "$laststat" != "$traystat" ]; then
                echo "Waiting for CD. Drive is $traystat"
            fi
            sleep 3
            ;;
    esac
    laststat=$traystat
done
