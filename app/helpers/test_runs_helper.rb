module TestRunsHelper
  def test_run_state_css_class(test_run)
    return 'warning' if test_run.ended?
    return 'success' if test_run.stopped?
    return 'error' if test_run.started?
    'info'
  end
end
