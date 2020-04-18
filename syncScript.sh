#!/bin/bash
inotifywait -r -m -e close_write --format '%w%f' /mnt/pihole /mnt/dnsmasq.d/ | while read MODFILE
do
    bash -c "rsync -aP /mnt/pihole/ $CLIENTDIR1 --delete"
    bash -c "rsync -aP /mnt/dnsmasq.d/ $CLIENTDIR2 --delete"
done
