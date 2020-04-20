#!/bin/bash
inotifywait -r -m -e close_write --format '%w%f' /mnt/pihole /mnt/dnsmasq.d/ | while read MODFILE
do
    sudo bash -c "rsync --exclude 'pihole-FTL.db' /mnt/pihole/ $CLIENTDIR1 --delete"
    sudo bash -c "rsync -aP /mnt/dnsmasq.d/ $CLIENTDIR2 --delete"
done
