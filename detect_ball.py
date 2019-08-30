import picamera
import cv2
import time

camera = picamera.PiCamera(resolution=(1296, 730), framerate=49)
stream = picamera.PiCameraCircularIO(camera, seconds=30)
camera.start_preview()

while True:
  time.sleep(1)
