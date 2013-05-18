require "exif-date-sorter/version"
require "exifr"
require "fileutils"

class ExifDateSorter
  def initialize(source, target)
    @source = source
    @target = target
    @video_dir = "#{@target}/Videos"
    @unsortable_dir = #{@target}/Unsortable"
    FileUtils.mkdir_p(@video_dir)
    FileUtils.mkdir_p(@unsortable_dir)
  end

  def move
    puts "Starting Photo Organization..."
    Dir[@source + '/**/*.{jpg,JPG,jpeg,JPEG}'].each do |image|
      target_dir = dir(image)
      if target_dir
        puts "  Sorting #{image}"
        FileUtils.mkdir_p(target_dir) unless File.directory? target_dir
        FileUtils.move image, target_dir
      else
        puts "  Unsortable #{image}"
        FileUtils.move image, @unsortable_dir
      end
    end


    Dir[@source + '/**/*.{mov,MOV,avi,AVI,mp4,MP4}'].each do |video|
      FileUtils.move video, @video_dir
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
