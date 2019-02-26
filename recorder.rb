require 'open3'

class Recorder
  attr_accessor :do_save

  def auto_clean_up
    IO.popen("while true; do find ./recordings/rubyvid* -maxdepth 1 -mmin +1 -type f -exec rm -fv {} \\; 2> /dev/null ; sleep 5; done")
  end

  def record
    timestamp = Time.now.to_i
    ffmpeg_cmd = []
    ffmpeg_cmd << "ffmpeg"
    ffmpeg_cmd << "-framerate 30"
    ffmpeg_cmd << "-f avfoundation" if RUBY_PLATFORM.include?('darwin')
    ffmpeg_cmd << "-f video4linux2" if RUBY_PLATFORM.include?('linux')
    ffmpeg_cmd << '-i "0"' if RUBY_PLATFORM.include?('darwin')
    ffmpeg_cmd << '-i /dev/video0' if RUBY_PLATFORM.include?('linux')
    ffmpeg_cmd << "-map 0"
    ffmpeg_cmd << "-b:v 3000k"
    ffmpeg_cmd << "-minrate 3000k"
    ffmpeg_cmd << "-maxrate 3000k"
    ffmpeg_cmd << "-quality realtime"
    ffmpeg_cmd << "-crf 18"
    ffmpeg_cmd << "-f segment -segment_time 10"
    ffmpeg_cmd << "-segment_format mp4"
    ffmpeg_cmd << "-strftime 1"
    ffmpeg_cmd << "-loglevel quiet"
    ffmpeg_cmd << '"./recordings/rubyvid-%s.mp4"'
    IO.popen(ffmpeg_cmd.join ' ')
    auto_clean_up
    true
  end
end
