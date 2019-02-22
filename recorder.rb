class Recorder
  attr_accessor :do_save

  def record
    timestamp = Time.now.to_i
    IO.popen("ffmpeg -framerate 30 -t 15 -f avfoundation -i \"0\" pingpong-#{timestamp}.mp4")
    true
  end
end
