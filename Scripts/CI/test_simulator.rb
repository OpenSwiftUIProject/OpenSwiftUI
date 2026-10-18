#!/usr/bin/env ruby

require 'json'
require 'open3'
require 'securerandom'

def simctl(*arguments)
  output, error, status = Open3.capture3('xcrun', 'simctl', *arguments)
  abort("::error::simctl #{arguments.join(' ')} failed: #{error}") unless status.success?
  output
end

command, state_path, destination = ARGV
case command
when 'create'
  abort('::error::Simulator state already exists.') if File.exist?(state_path)
  fields = destination.split(',').to_h { |field| field.strip.split('=', 2) }
  unless fields.keys.sort == %w[OS name platform] && fields['platform'] == 'iOS Simulator' && fields['OS'].match?(/\A\d+(?:\.\d+){1,2}\z/)
    abort('::error::Expected an iOS Simulator destination with an explicit OS version and device name.')
  end
  version = ->(value) { value.split('.').map(&:to_i).values_at(0, 1, 2).map { |part| part || 0 } }
  runtimes = JSON.parse(simctl('list', 'runtimes', '--json')).fetch('runtimes')
  runtime = runtimes.find do |item|
    item['isAvailable'] && item['identifier'].start_with?('com.apple.CoreSimulator.SimRuntime.iOS-') && version.call(item['version']) == version.call(fields['OS'])
  end
  abort("::error::No available iOS #{fields['OS']} runtime.") unless runtime
  device_type = runtime.fetch('supportedDeviceTypes').find { |item| item['name'] == fields['name'] }
  abort("::error::#{fields['name']} is not supported by iOS #{fields['OS']}.") unless device_type

  # Persist ownership before creation so cleanup also handles partial failures.
  state = { 'name' => "OpenSwiftUI-#{SecureRandom.uuid}", 'runtime' => runtime.fetch('identifier') }
  File.write(state_path, JSON.generate(state), mode: 'wx')
  udid = simctl('create', state.fetch('name'), device_type.fetch('identifier'), state.fetch('runtime')).strip
  abort('::error::simctl returned an invalid device UDID.') unless udid.match?(/\A[0-9A-Fa-f-]{36}\z/)
  warn "Created test simulator #{state.fetch('name')} (#{udid})."
  # Do not boot the source: Xcode must clone it before Spotlight creates protected data.
  puts "platform=iOS Simulator,id=#{udid}"
when 'cleanup'
  exit unless File.exist?(state_path)
  state = JSON.parse(File.read(state_path))
  name = state.fetch('name')
  abort('::error::Invalid simulator ownership state.') unless name.match?(/\AOpenSwiftUI-[0-9a-f-]{36}\z/)
  owned_name = /\A(?:Clone \d+ of )?#{Regexp.escape(name)}\z/
  failures = []
  # Xcode keeps parallel workers in a separate device set.
  [['--set', 'testing'], []].each do |device_set|
    arguments = [*device_set, 'list', 'devices', '--json']
    output, error, status = Open3.capture3('xcrun', 'simctl', *arguments)
    unless status.success?
      # Serial tests on a fresh runner do not create the parallel device set.
      if device_set == ['--set', 'testing'] && error.lines.any? { |line| line.start_with?('Provided set path does not exist: ') }
        warn 'Skipping absent testing device set.'
      else
        failures << "simctl #{arguments.join(' ')} failed: #{error}"
      end
      next
    end
    devices = JSON.parse(output).fetch('devices')
    devices.fetch(state.fetch('runtime'), []).each do |device|
      next unless owned_name.match?(device.fetch('name'))
      udid = device.fetch('udid')
      Open3.capture3('xcrun', 'simctl', *device_set, 'shutdown', udid) unless device['state'] == 'Shutdown'
      _, error, status = Open3.capture3('xcrun', 'simctl', *device_set, 'delete', udid)
      failures << "#{udid}: #{error}" unless status.success?
      warn "Removed test simulator #{device.fetch('name')} (#{udid})." if status.success?
    end
  end
  abort("::error::Simulator cleanup failed: #{failures.join('; ')}") unless failures.empty?
  File.delete(state_path)
else
  abort('Usage: test_simulator.rb create|cleanup STATE_PATH [DESTINATION]')
end
