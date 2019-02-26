require_relative 'recorder.rb'
require_relative 'video_splicer.rb'

class Supervisor
  def initialize
    @recorder = Recorder.new
    @is_joining = false
    File.delete('/tmp/event.log') unless !File.exists?('/tmp/event.log')
  end

  def record_video
    @is_recording = @recorder.record
  end

  def listen_for_messages
    loop do
      begin
        contents = File.read('/tmp/event.log')
        if !@is_joining
          @is_joining = true
          VideoSplicer.join
	  @is_joining = false
          File.delete('/tmp/event.log') unless !File.exists?('/tmp/event.log')
	end
      rescue
      ensure
        sleep 5
      end
    end
  end

  def start
    record_video
    listen_for_messages
  end
end

supervisor = Supervisor.new

begin
  supervisor.start
rescue Interrupt => e
end
