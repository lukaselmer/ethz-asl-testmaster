module MachinesHelper
  def machine_state_css_class(machine)
    return 'warning' if machine.status == 'stopped'
    return 'success' if machine.status == 'running'
    return 'error' if machine.status == 'unknown'
    'error'
  end
end
