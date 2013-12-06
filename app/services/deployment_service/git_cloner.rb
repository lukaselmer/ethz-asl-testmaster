class DeploymentService::GitCloner

  def initialize(cmd_executor, local_tmp_dir)
    @cmd_executor = cmd_executor
    @local_tmp_dir = local_tmp_dir
  end

  def git_path
    "#{@local_tmp_dir}/git"
  end

  def clone_git
    #@cmd_executor.exec! "git clone -b microbenchmarks git@github.com:ganzm/AdvancedSystemsLab2013.git #{git_path}"
    @cmd_executor.exec! "git clone git@github.com:ganzm/AdvancedSystemsLab2013.git #{git_path}"
  end
end
