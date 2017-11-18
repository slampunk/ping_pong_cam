def chop_seconds(seconds)
  #`ffmpeg -sseof -#{seconds} -i /home/osmc/capture.mpeg /home/osmc/Movies/deliver-#{Time.now.to_i}.mpeg`
  `avconv -i /home/osmc/capture.h264 /home/osmc/Movies/deliver-#{Time.now.to_i}.h264`
end

def cleanup_capture
  `sudo rm capture.h264`
end

def start_recording
  `sudo ruby ping_pong_cleanup.rb`
end

puts 'Killing all ffmpeg processes'
`pidof avconv`.split(' ').each do |pid|
  `sudo kill -INT -#{pid}`
end
sleep(1)
puts "Grabbing the last 30 seconds"
chop_seconds(30)
sleep(1)
puts 'Removing the raw video file'
cleanup_capture
sleep(1)
puts 'recording...'
start_recording
