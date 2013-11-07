class DeploymentService::JarCompiler

  def initialize(cmd_executor, git_path, jar_path, setup_path, project)
    @setup_path = setup_path
    @cmd_executor = cmd_executor
    @git_path = git_path
    @project = project
    @compiled_jar_path = "#{mvn_path}/target/ASL-0.0.1-SNAPSHOT.jar"
    @jar_path = jar_path
  end

  def setup_jar_path
    "#{@setup_path}/setup.jar"
  end

  def setup_path
    @setup_path
  end

  def compile_jar
    raise "Jar already exists: #{@compiled_jar_path}" if File.exists? @compiled_jar_path
    @cmd_executor.exec! "cd #{mvn_path} && mvn package -Dmaven.test.skip=true"
    @cmd_executor.exec! "cd #{mvn_path} && mvn dependency:copy-dependencies -DexcludeTypes=test-jar"
    raise "Could not compile jar file: #{@compiled_jar_path}" unless File.exists? @compiled_jar_path
    FileUtils.copy @compiled_jar_path, @jar_path
    FileUtils.copy @compiled_jar_path, setup_jar_path
  end

  def mvn_path
    "#{@git_path}/code/#{@project}"
  end
end
