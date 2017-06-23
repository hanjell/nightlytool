########################################################################
# This program is free software: you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation, either version 3 of the License, or    #
# (at your option) any later version.                                  #
########################################################################

#!/bin/bash

echo "Installing nightly tool"
sudo mkdir -p /usr/local/etc/nightlytool/
sudo cp nightlytool.py sbxTool.sh /usr/local/bin/
if [ ! -f /usr/local/etc/nightlytool/sandbox_conf.json ]; then
	sudo cp sandbox_conf.json /usr/local/etc/nightlytool/
fi
sudo chown -R $USER.users /usr/local/etc/nightlytool
sudo chown $USER.users /usr/local/bin/nightlytool.py /usr/local/bin/sbxTool.sh
sudo chmod +x /usr/local/bin/nightlytool.py /usr/local/bin/sbxTool.sh
export > /tmp/nightly_env
sudo mv /tmp/nightly_env /usr/local/etc/nightlytool/
sudo chown $USER.users /usr/local/etc/nightlytool/nightly_env
(crontab -l 2>/dev/null; echo "0 20 * * Sun,Mon,Tue,Wed,Thu python /usr/local/bin/nightlytool.py") | crontab -
echo "Installation successfully completed"