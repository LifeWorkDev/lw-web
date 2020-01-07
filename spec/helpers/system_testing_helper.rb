module SystemTestingHelper
  def expect_no_server_error
    expect(page).not_to have_content 'Puma caught this error'
  end

  def verify_visit(path)
    visit path
    expect_no_server_error
  end

  def verify_click(selector)
    click_on(selector)
    expect_no_server_error
  end

  def click_continue
    verify_click 'Continue >'
  end

  def click_sign_up
    verify_click 'Sign up'
  end
end
