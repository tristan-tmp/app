require_relative 'app'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: assignment2.rb [options]'

  options[:instances] = 1
  opts.on('--instances NUMBER', Integer, 'Number of Instances \
    (default #{options[:instances]})') do |instances|
    options[:instances] = instances
  end
  options[:type] = 't2.micro'
  opts.on('--instance-type STRING', String, 'Name of flavour \
    (default #{options[:type]})') do |type|
    options[:type] = type
  end
  options[:ipaddress] = '0.0.0.0/0'
  opts.on('--allow-ssh-from STRING', String, 'CIDR notation of \
    allowed IP address (default #{options[:ipaddress]})') do |ipaddress|
    options[:ipaddress] = ipaddress
  end
end.parse!

@aws = Aws.new

output = @aws.generate_json_data(
  options[:instances],
  options[:type],
  options[:ipaddress])

puts JSON.pretty_generate(output)
