class AwsService
  def resolve_db_url
    @@cache ||= init_db_url
  end

  def init_db_url
    ENV['MLMQ_DB_URL'].gsub('#{host}', ip_for_aws_db)
  end

  def ip_for_aws_db
    MachineService.new.resolve_instance_ip_address ENV['MLMQ_DB_AWS_ID']
  end
end
