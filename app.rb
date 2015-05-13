require 'yaml'
require './helpers'
require './echo_scraper'

MODULE_INSTANCES = []
modules = YAML.load_file('modules.yml')['modules']
modules.each do |alexa_module|
  require "./modules/#{alexa_module}/module.rb"
end

class App
  class << self
    def start!
      EchoScraper.new(new).start!
    end
  end

  def call(command)
    MODULE_INSTANCES.each do |alexa_module|
      if command.scan(Regexp.new(alexa_module.wake_words.join("|"))).length > 0
        alexa_module.process_command(command)
      end
    end
  end
end

App.start!
