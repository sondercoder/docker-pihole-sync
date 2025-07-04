#!/bin/bash
inotifywait -r -m -e close_write --exclude 'pihole-FTL.db*' --format '%w%f' /mnt/pihole /mnt/dnsmasq.d/ | while read MODFILE
do
    sudo bash -c "rsync -aP --exclude pihole-FTL.db* --exclude gravity*.* --exclude ./listsCache/list* /mnt/pihole/ $CLIENTDIR1 --delete"
    sudo bash -c "rsync -aP /mnt/dnsmasq.d/ $CLIENTDIR2 --delete"
done
