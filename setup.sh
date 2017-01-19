#!/bin/bash
cd /home/vagrant/NAO
chmod +x get_sdks.sh

if [ -e /home/vagrant/NAO/get_sdks.sh ]; then 
    /home/vagrant/NAO/get_sdks.sh
else
    echo "SDK acquisition script missing.\nPlease download the SDKs online and place them in the /NAO/NAOSDKs directory in the archived format, then run: sudo sh NAO/finalize_install.sh"
fi

