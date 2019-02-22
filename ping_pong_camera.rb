require_relative 'recorder.rb'
require_relative 'video_splicer.rb'

class Supervisor
  def initialize
    @recorder = Recorder.new
  end

  def record_video
    @is_recording = @recorder.record
    sleep 15
    @is_recording = false
    record_video
  end

  def listen_for_messages
    loop do
      begin
        contents = File.read('/tmp/event.log')
	VideoSplicer.join
	File.delete('/tmp/event.log')
      rescue
      ensure
        sleep 1
        listen_for_messages
      end
    end
  end

  def start
    record_video
    listen_for_messages
  end
end

supervisor = Supervisor.new
supervisor.start
