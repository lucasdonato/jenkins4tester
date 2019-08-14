require "report_builder"

Before do
  @login_page = LoginPage.new
  @movie_page = MoviePage.new
  @sidebar = SideBarView.new

  page.current_window.resize_to(1920, 1080)
end

Before("@login") do
  user = CONFIG["users"]["cat_manager"]
  @login_page.go
  @login_page.with(user["email"], user["pass"])
  expect(page).to have_text user["name"]
end

After do |scenario|
  screenshot = page.save_screenshot("log/screenshots/#{scenario.__id__}.png")
  embed(screenshot, "image/png", "Screenshot")
end

at_exit do
  @infos = {
    "Autor" => "Lucas Donato",
    "environment" => "Dev",
    "Data do Teste" => Time.now.to_s,
  }

  ReportBuilder.configure do |config|
    config.input_path = "log/report.json"
    config.report_path = "log/report"
    config.report_types = [:html]
    config.report_title = "Jenkins4testers"
    config.additional_info = @infos
    config.color = "indigo"
  end
  ReportBuilder.build_report
end
