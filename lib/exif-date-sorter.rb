require "exif-date-sorter/version"
require "exifr"
require "fileutils"
require "securerandom"

class ExifDateSorter
  def initialize(source, target)
    @source = source
    @target = target
    @video_dir = "#{@target}/Videos"
    @unsortable_dir = "#{@target}/Unsortable"
    FileUtils.mkdir_p(@video_dir)
    FileUtils.mkdir_p(@unsortable_dir)
  end

  def move
    STDOUT.sync = true
    puts "Starting Photo Organization..."
    Dir[@source + '/*/'].each do |subdir|
      subdir = File.expand_path subdir
      puts "  DIR => #{subdir}"
      Dir[subdir + '/**/*.{jpg,JPG,jpeg,JPEG}'].each do |image|
        target_dir = dir(image)
        if target_dir
          puts "    Image #{File.basename(image)} to #{target_dir}"
          FileUtils.mkdir_p(target_dir) unless File.directory? target_dir
          if !File.file? File.join(target_dir, File.basename(image))
            FileUtils.move image, target_dir
          else
            FileUtils.move image, File.join(target_dir, SecureRandom.hex(4) + File.basename(image))
          end
        end
      end

      Dir[subdir + '/**/*.{mov,MOV,avi,AVI,mp4,MP4}'].each do |video|
        puts "    Image #{File.basename(video)} to #{@video_dir}"
        if !File.file? File.join(@video_dir, File.basename(video))
          FileUtils.move video, @video_dir
        else
          FileUtils.move video, File.join(@video_dir, SecureRandom.hex(4) + File.basename(video))
        end
      end

      if Dir.entries(subdir).size
        if !File.directory? File.join(@unsortable_dir, File.basename(subdir))
          FileUtils.move subdir, @unsortable_dir
        else
          FileUtils.move subdir, File.join(@unsortable_dir, SecureRandom.hex(4) + File.basename(subdir))
        end
      end
    end
  end

  def date(image)
    EXIFR::JPEG.new(image).date_time_original
  end

  def dir(image)
    date = date(image)
    if date
      return "#{@target}/#{date.year}/#{'%02d' % date.month}"
    else
      return false
    end
  end
end
