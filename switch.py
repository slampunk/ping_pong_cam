#!/usr/bin/env python

import RPi.GPIO as GPIO
import time
import os
import sys
import picamera
import subprocess
import asyncio


GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.IN, pull_up_down=GPIO.PUD_UP)

camera = None
stream = None

def initCam():
  global camera, stream
  camera = picamera.PiCamera(resolution=(1296, 730), framerate=49)
  stream = picamera.PiCameraCircularIO(camera, seconds=30)
  camera.start_recording(stream, format='h264')
  print("Warming camera up...")
  time.sleep(3)
  camera.wait_recording(1)
  print("Camera ready, recording started")
  print("ready to accept events for video saving")

async def button_events():
  track_button_pressed = False
  starting_camera = False
  button_press_timestamp = 0

  while True:
    is_input_open = GPIO.input(18)

    if is_input_open == False and camera == None and track_button_pressed == False:
      track_button_pressed = True
      initCam()
    elif not starting_camera:
      if is_input_open == False and track_button_pressed == False:
        track_button_pressed = True
        print('Button Pressed')
        button_press_timestamp = int(time.time())
        timestamp = str(button_press_timestamp)
        filename = 'testvideo-' + timestamp
        stream.copy_to(filename + '.h264')
        subprocess.Popen('MP4Box -quiet -fps 50 -add %s.h264 %s.mp4 && ffmpeg -loglevel quiet -sseof -15 -i %s.mp4 -c copy pingpong-%s.mp4 && rm %s.h264' %(filename, filename, filename, timestamp, filename), shell=True)
        print("saved at %s" %timestamp)
      elif is_input_open == False and button_press_timestamp > 0 and time.time() - button_press_timestamp > 3.0:
        camera.stop_recording()
        button_press_timestamp = 0
        camera.close()
        camera = None
        track_button_pressed = True
        print("stopping recording")

    elif is_input_open and track_button_pressed:
      track_button_pressed = False
      starting_camera = False
      button_press_timestamp = 0

    await asyncio.sleep(0.001)

async def main():
  initCam()
  await asyncio.wait( [
      button_events(),
      run_camera()
    ] )

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
loop.close()
