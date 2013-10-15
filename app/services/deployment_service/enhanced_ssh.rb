class DeploymentService::EnhancedSSH
  def initialize(ssh)
    @ssh = DeploymentService::LoggingSSH.new(ssh)
  end

  def exec!(command)
    @ssh.exec!(command)
  end

  def exec(command)
    @ssh.exec(command)
  end

  def ensure_connection! user
    output = exec!('whoami')
    raise RuntimeError.new("Unable to execute a command on ssh. Output: #{output}") unless output.strip == user
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
    @ssh.exec!("ls #{file_or_dir_path}").strip == file_or_dir_path
  end

  def to_s
    @ssh.to_s
  end
end
