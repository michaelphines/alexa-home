require 'watir-webdriver'

class EchoScraper
  attr_reader :browser
  attr_reader :callback

  REFRESH_TIME_IN_MINUTES = 30
  URL = "http://echo.amazon.com/spa/index.html"
  USER_AGENT = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36"

  def initialize(callback)
    capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => USER_AGENT)
    driver = Selenium::WebDriver.for :phantomjs, :desired_capabilities => capabilities
    @browser = ::Watir::Browser.new driver
    @callback = callback
  end

  def kill
    browser.close
  end

  def login!
    browser.text_field(id: 'ap_email').when_present.set ENV['AMAZON_EMAIL']
    browser.text_field(id: 'ap_password').set ENV['AMAZON_PASSWORD']
    browser.button(id: "signInSubmit-input").click
  end

  def poll_todos
    browser.element(css: "nav").when_present.click
    browser.element(id: "iTodos").when_present.click
    while true
      item = browser.element(css: ".to-do-item:not(.complete)")
      if item.present?
        fork { callback.call(item.element(css: ".text").text) }
        item.element(css: ".mark-done").click
      end
      sleep(1)
    end
  end

  def start!
    browser.goto URL
    login!
    Timeout::timeout(REFRESH_TIME_IN_MINUTES * 60) { poll_todos }
  rescue Timeout::Error
    retry
  end
end
