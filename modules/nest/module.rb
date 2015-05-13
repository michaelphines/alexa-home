require 'nest_thermostat'

class AlexaNest

  NEST_CLIENT = NestThermostat::Nest.new(email: ENV['NEST_EMAIL'], password: ENV['NEST_PASS'])

  def wake_words
    ["temperature", "nest"]
  end

  def process_command(command)
    temp = command.gsub(/.*\sto\s/, "").in_numbers

    NEST_CLIENT.temp = temp
    NEST_CLIENT.temp_low = temp
    NEST_CLIENT.temp_high = temp
  end

end

MODULE_INSTANCES.push(AlexaNest.new)
