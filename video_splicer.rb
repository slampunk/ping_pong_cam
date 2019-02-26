require 'fileutils'
require 'open3'

class VideoSplicer

  def self.join
    current_time = Time.now.to_i
    filename = "./processed/ping-pong-#{current_time}.mp4"
    video_files = self.move_files_to_saved_folder
    # Add a callback to below to delete the ./saved files for this particular video
    puts "saving to #{filename}"
    Open3.popen3("ffmpeg -i #{video_files[0].path} -i #{video_files[1].path} -filter_complex \"[0:v] [1:v] concat=n=2:v=1 [v]\" -map \"[v]\" #{filename}") { | stdin, stdout, stderr, fd |
            stdout.each_line { | line | puts "stdout: #{line}" }
            stderr.each_line { | line | puts "stderr: #{line}" }
	    stdin.close
	    stdout.close
	    stderr.close
    }
  end

  def self.move_files_to_saved_folder
    self.wait_until_current_recording_finished
    videos_to_move = self.get_files_in_dir('./recordings')
                      .first(3)
                      .last(2)

    FileUtils.cp(videos_to_move, './saved/')
    self.get_files_in_dir('./saved')
  end

  def self.wait_until_current_recording_finished(current_files = [], current_iteration = 0)
    current_vids = get_files_in_dir('./recordings')
                     .first(2)

    if current_files.empty?
      current_files = current_vids
    end

    if current_vids != current_files && current_files.length > 1
      return true
    else
      sleep 2
      return self.wait_until_current_recording_finished(current_files, current_iteration + 1)
    end
  end

  def self.get_files_in_dir(dir = "./")
    Dir.glob("#{dir}/*")
      .select{|name| File.file?(name) }
      .map{|name| File.new(name) }
      .sort{|a,b| b.mtime <=> a.mtime }
  end
end
