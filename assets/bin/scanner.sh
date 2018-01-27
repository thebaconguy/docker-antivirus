#!/bin/bash
files=$(shopt -s nullglob dotglob; echo /data/av/queue/*)
if (( ${#files} ))
then
    printf "Found files to process\n"
    for file in "/data/av/queue"/* ; do
        filename=`basename $file`
        # Copy the file instead of moving it
        # mv -f $file "/data/av/scan/${filename}"
        cp -f $file "/data/av/scan/${filename}"
        printf "Processing /data/av/scan/${filename}\n"
        /usr/local/bin/scanfile.sh > /data/av/scan/info 2>&1
        if [ -e "/data/av/scan/${filename}" ]
        then
            printf "  --> File ok\n"
            # Leave the original and delete the copy
            # mv -f "/data/av/scan/${filename}" "/data/av/ok/${filename}"
            rm -f "/data/av/scan/${filename}"
            printf "  --> Copied file deleted /data/av/ok/${filename}\n"
            rm -f /data/av/scan/info
        elif [ -e "/data/av/quarantine/${filename}" ]
        then
            printf "  --> File quarantined / nok\n"
            # Delete the original and save the scan log
            rm -f $file
            mv -f "/data/av/scan/info" "/data/av/nok/${filename}.info"
            printf "  --> Scan report moved to /data/av/nok/${filename}.info\n"
        fi
    done
    printf "Done with processing\n"
fi
