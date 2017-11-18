#IO.popen('sudo modprobe bcm2835-v4l2;cd /home/osmc && /usr/local/bin/ffmpeg -f video4linux2 -framerate 30 -video_size 1280X720 -i /dev/video0 capture.mpeg')
IO.popen('cd /home/osmc && /usr/bin/avconv -f video4linux2 -video_size 1280x720 -framerate 30 -i /dev/video0 /home/osmc/capture.h264')

