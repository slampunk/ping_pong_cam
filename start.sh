export PATH="$PATH:/usr/osmc/bin"
SHELL=/bin/bash
source /etc/profile
sudo rm capture.h264
sudo rm cleanup.log
sudo pkill python3
sudo pkill avconv
sudo modprobe bcm2835-v4l2
sudo ruby /home/osmc/ping_pong_cleanup.rb
