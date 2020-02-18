module SystemTestingHelper
  def expect_no_server_error
    # Hack to make sure that the new page has loaded before checking for Puma error
    # https://github.com/teamcapybara/capybara/issues/2106
    page.server.wait_for_pending_requests
    expect(page).not_to have_content 'Puma caught this error'
  end

  def verify_visit(path)
    visit path
    expect_no_server_error
  end

  def verify_click(selector, path = nil)
    click_on(selector)
    expect(page).to have_current_path(path) if path.present?
    expect_no_server_error
  end

  def click_continue(path = nil)
    verify_click 'Continue >', path
  end

  def click_sign_up(path = nil)
    verify_click 'Sign up', path
  end
end
