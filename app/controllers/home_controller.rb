class HomeController < ApplicationController
  def index
  end

  def logs
    lines = params[:lines].to_i
    lines = 10 if lines.zero?
    logfile = "#{Rails.root}/log/#{Rails.env}.log"
    logfile_tail = "#{Rails.root}/log/#{Rails.env}_tail.log"

    %x{tail -n #{lines} #{logfile} > #{logfile_tail}}

    send_file logfile_tail and return unless params[:show]

    @logs = IO.readlines(logfile_tail).reverse
  end

  def build_log_analyzer
    LogAnalyzerService.new.build
    redirect_to '/', notice: "Log analizer built!"
  end
end
