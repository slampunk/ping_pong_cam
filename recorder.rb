require 'open3'

class Recorder
  attr_accessor :do_save

  def auto_clean_up
    IO.popen("while true; do find ./recordings/rubyvid* -maxdepth 1 -mmin +1 -type f -exec rm -fv {} \\; 2> /dev/null ; sleep 5; done")
  end

  def record
    timestamp = Time.now.to_i
    ffmpeg_cmd = [
      "ffmpeg",
      "-framerate 30",
      "-f avfoundation",
      '-i "0"',
      "-map 0",
      "-b:v 3000k",
      "-minrate 3000k",
      "-maxrate 3000k",
      "-quality realtime",
      "-crf 18",
      "-f segment -segment_time 10",
      "-segment_format mp4",
      "-strftime 1",
      "-loglevel quiet",
      '"./recordings/rubyvid-%s.mp4"'
    ];
    IO.popen(ffmpeg_cmd.join ' ')
    auto_clean_up
    true
  end
end
