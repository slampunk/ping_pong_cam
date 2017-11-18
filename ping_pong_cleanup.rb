def capture_older_than_5min?
  (Time.now.to_i - File.mtime('ping_pong_capture.rb').to_i) / 60.0 > 5
rescue
  false
end

if File.exist?('capture.h264') 
  if  (File.size('capture.h264') / 1024.0 / 1024.0) > 500
  `pidof avconv`.split(' ').each do |pid|
     `sudo kill -INT -#{pid}`
   end
    #`sudo pkill avconv`
    `sudo rm capture.h264`
    `sudo ruby ping_pong_capture.rb`
  end
else
  `sudo ruby ping_pong_capture.rb`
end
  
if File.exist?('cleanup.log') && (File.size('cleanup.log') / 1024.0 / 1024.0 > 100)
  `sudo rm cleanup.log`
end

`sudo pkill python3`
`sudo python3 switch.py &`

