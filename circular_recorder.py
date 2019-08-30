import RPi.GPIO as GPIO
import time
import os
import sys
import picamera
import subprocess


GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.IN, pull_up_down=GPIO.PUD_UP)
track_button_pressed = False
button_press_timestamp = 0

camera = None
stream = None

# Probably not necessary, but lets keep track of the fps as time goes on
# Just in case fps is variable
fps_rolling_average = 0
fps_rolling_stddev = 0
last_frame_index = 0
current_frame_index = 0
last_frame_timestamp = 0
current_frame_timestamp = 0
initial_frame_timestamp = 0
initial_frame_index = 0

def initCam():
  global camera, stream
  camera = picamera.PiCamera(resolution=(1296, 730), framerate=49)
  stream = picamera.PiCameraCircularIO(camera, seconds=30)
  camera.start_recording(stream, format='h264')
  print("Warming camera up...")
  time.sleep(3)
  print("Camera ready, recording started")
  print("ready to accept events for video saving")

initCam()

try:
  while True:
    if camera != None and camera.recording:
      camera.wait_recording(1)
      frame = camera.frame
      if frame != None and frame.timestamp > 0 and initial_frame_index > 0:
#        deltaFPS = (frame.index - last_frame_index - initial_frame_index) / (frame.timestamp - last_frame_timestamp - initial_frame_timestamp)
#      fps_rolling_stddev = 
        fps_rolling_average = 1000000 * frame.index / frame.timestamp #(frame.index - initial_frame_index) / (frame.timestamp - initial_frame_timestamp)
      else:
        initial_frame_timestamp = last_frame_timestamp = frame.timestamp
        initial_frame_index = last_frame_index = frame.index

      sys.stdout.write('\r%ifps' %int(fps_rolling_average))# + str(int(fps_rolling_average)) + 'fps', end='\r')
      sys.stdout.flush()
    else:
      time.sleep(0.3)

#    last_frame_index = currewent_frame_index
#    last_frame_timestamp = current_frame_timestamp
##    current_frame_timestamp = frame.timestamp
#    current_frame_index = frame.index
#    print(str(current_frame_index - last_frame_index) + ' frames in ' + str(current_frame_timestamp - last_frame_timestamp) + ' microseconds')
    is_input_open = GPIO.input(18)
    if is_input_open == False and camera == None and track_button_pressed == False:
      track_button_pressed = True
      initCam()
      initial_frame_index = initial_frame_timestamp = 0
    elif is_input_open == False and track_button_pressed == False:
      track_button_pressed = True
      print('Button Pressed')
      button_press_timestamp = int(time.time())
      timestamp = str(button_press_timestamp)
      filename = 'testvideo-' + timestamp
      stream.copy_to(filename + '.h264')
#      subprocess.Popen(f'MP4Box -fps 50 -add {filename}.h264 {filename}.mp4 && ffmpeg -sseof -15 -i ${filename}.mp4 -c copy pingpong-{timestamp}.mp4')
      subprocess.Popen('MP4Box -quiet -fps 50 -add %s.h264 %s.mp4 && ffmpeg -loglevel quiet -sseof -15 -i %s.mp4 -c copy pingpong-%s.mp4 && rm %s.h264' %(filename, filename, filename, timestamp, filename), shell=True)
#      save_cmd = 'MP4Box -fps 50 -add ./' + filename + '.h264 ./' + filename + '.mp4 && ffmpeg -sseof -15 -i'
#      save_vid_cmd = subprocess.Popen(save_cmd, shell=True)
      print "saved at %s" %timestamp
    elif is_input_open == False and button_press_timestamp > 0 and time.time() - button_press_timestamp > 3.0:
      camera.stop_recording()
      button_press_timestamp = 0
      camera.close()
      camera = None
      track_button_pressed = True
      print "stopping recording"
    elif is_input_open and track_button_pressed:
      track_button_pressed = False
finally:
  print("stopping...")
  if camera != None and camera.recording:
    camera.stop_recording()
  print("done")
