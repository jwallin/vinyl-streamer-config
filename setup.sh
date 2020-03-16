#!/bin/bash

# Ensure root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Configuration
LIBRARY_DIR="/var/media"
INPUT_DEVICE="CARD=CODEC,DEV=0"
OUTPUT_PIPE="${LIBRARY_DIR}/vinylOutputPipe"
CPIPED_PATH="/usr/local/bin"
FORKED_DAAPD_CONFIG_PATH="/etc/forked-daapd.conf"
SERVICE_USER="pi"

# Add Repo
wget -q -O - http://www.gyfgafguf.dk/raspbian/forked-daapd.gpg | apt-key add -

# Add source 
echo "deb http://www.gyfgafguf.dk/raspbian/forked-daapd/ buster contrib" >> /etc/apt/sources.list
apt update

# Create library dir if it doesn't exist
mkdir -p $LIBRARY_DIR

# Install dependencies
apt-get install libasound2-dev libavahi-client-dev -y

# Install forked-daapd 
apt install forked-daapd -y

# Update config file
sed -i '/sample_rate/s/^#//g' $FORKED_DAAPD_CONFIG_PATH #uncomment
sed -i '/bit_rate/s/^#//g' $FORKED_DAAPD_CONFIG_PATH #uncomment
sed -i '/pipe_autostart/s/^#//g' $FORKED_DAAPD_CONFIG_PATH #uncomment

# Set library directory
sed -i "s/\(directories = { \"\)[^\"]*/\1${LIBRARY_DIR//\//\\/}/g" $FORKED_DAAPD_CONFIG_PATH

# Disable automatic filescan
# sed -i '/filescan_disable/s/^#//g' $FORKED_DAAPD_CONFIG_PATH #uncomment
# sed -i "s/\(filescan_disable = \)[^\"]*/\1true/g" $FORKED_DAAPD_CONFIG_PATH

# Restart service
service forked-daapd restart

# Build cpiped
rm -rf cpiped
git clone https://github.com/b-fitzpatrick/cpiped.git
cd cpiped
make
mv cpiped $CPIPED_PATH

# Take a step back
cd ..

# Create fifo pipe
rm -f $OUTPUT_PIPE
mkfifo $OUTPUT_PIPE
chown $SERVICE_USER $OUTPUT_PIPE

# Install cpiped as a service
eval "cat <<EOF
$(<cpiped.service.template)
EOF
" 2> /dev/null > /etc/systemd/system/cpiped.service


# Trigger filescan
curl -X PUT "http://localhost:3689/api/update"

# Start cpiped service
systemctl daemon-reload
systemctl start cpiped.service
