require 'net/ssh'

class DeploymentService::EnhancedSSH
  def initialize(ssh)
    @ssh = DeploymentService::LoggingSSH.new(ssh)
  end

  def self.start(host, user)
    Net::SSH.start(host, user, keys: [ENV['AWS_SSH_KEY_PATH']]) do |ssh_raw|
      enhanced_ssh = new(ssh_raw)
      enhanced_ssh.ensure_connection!(user)
      yield(enhanced_ssh)
    end
  end

  def ensure_connection! user
    output = exec!('whoami')
    raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == user
  end

  def exec!(command)
    @ssh.exec!(command)
  end

  def exec(command)
    @ssh.exec(command)
  end

  def delete(file)
    @ssh.exec!("rm #{file}")
    check_deleted file
  end

  def check_deleted(file_or_dir_path)
    raise RuntimeError.new("File or directory #{file_or_dir_path} should exist!") if exists?(file_or_dir_path)
  end

  def check_existence(file_or_dir_path)
    raise RuntimeError.new("File or directory #{file_or_dir_path} should exist!") unless exists?(file_or_dir_path)
  end

  def exists?(file_or_dir_path)
    @ssh.exec!("ls #{file_or_dir_path}").to_s.strip == file_or_dir_path
  end

  def to_s
    @ssh.to_s
  end
end
