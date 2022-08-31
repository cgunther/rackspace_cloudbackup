require_relative '../libraries/gather_bootstrap_data.rb'

property :label, String, name_attribute: true
property :rackspace_username, String, required: true
property :rackspace_api_key, String, required: true
property :bootstrap_file_path, String, default: '/etc/driveclient/bootstrap.json'
property :mock, [TrueClass, FalseClass], default: false

action :register do
  case agent_config['IsRegistered']
  when false
    if new_resource.mock
      # Mocking, don't register
      Chef::Log.warn('WARNING: Skipping registration due to mock = true')
      new_resource.updated_by_last_action(true)
    else
      cmd_str = "driveclient -c -k '#{new_resource.rackspace_api_key}' -u '#{new_resource.rackspace_username}'"
      # This is a class instance variable to expose it for testing.  It allows Mixlib::ShellOut to be mocked and then probed via a getter
      @shell_cmd = Mixlib::ShellOut.new(cmd_str)
      @shell_cmd.run_command
      if @shell_cmd.status.exitstatus == 0
        new_resource.updated_by_last_action(true)
      else
        fail "Failed to register the agent! 'driveclient -c' returned #{@shell_cmd.status.exitstatus}"
      end
    end

  when true
    new_resource.updated_by_last_action(false)
  else
    fail "Rackspace CloudBackup Agent registration in unknown state: #{agent_config['IsRegistered']}"
  end
end

# action :nothing do
#
# end

action_class.class_eval do
  def agent_config
    @agent_config ||= Opscode::Rackspace::CloudBackup.gather_bootstrap_data(new_resource.bootstrap_file_path) || fail('Failed to read agent configuration')
  end
end
