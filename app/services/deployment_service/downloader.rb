module DeploymentService::Downloader
  require 'open-uri'

  def download_from_uri(dest, source)
    File.open(dest, 'w') do |f|
      open(source).readlines.each do |line|
        f << line
      end
      yield(f) if block_given?
    end
  end
end
