module WaitForAjax
  TIMEOUT = Capybara.default_max_wait_time + 4
  def wait_for_ajax
    Timeout.timeout(TIMEOUT) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    sleep 0.3
    page.evaluate_script('jQuery.active').zero?
  end
end
