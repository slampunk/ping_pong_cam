require 'fileutils'

class VideoSplicer

  def self.join
    current_time = Time.now
    time_range = (current_time.to_i - 15)..current_time
    video_files = self.move_files_to_saved_folder
  end

  def self.move_files_to_saved_folder
    videos_to_move =
       Dir.glob('./recordings/*')
        .select{|name| File.file?(name) }
        .map{|name| File.new(name) }
        .sort{|a,b| b.mtime <=> a.mtime }
        .first(2)

    FileUtils.cp(videos_to_move, './saved/')
    Dir.glob('./saved/*')
      .select{|name| File.file?(name) }
      .map{|name| File.new(name) }

  end
end
