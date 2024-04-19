require_relative '../libraries/RcbuBackupWrapper.rb'

property :label, String, name_attribute: true
property :rackspace_username, String, required: true
property :rackspace_api_key, String, required: true
property :rackspace_api_region, String, required: true
property :inclusions, Array, required: true
property :exclusions, Array
property :is_active, [TrueClass, FalseClass], default: true
property :version_retention, Integer, required: true
property :frequency, String
property :start_time_hour, Integer
property :start_time_minute, Integer
property :start_time_am_pm, String
property :day_of_week_id, Integer
property :hour_interval, Integer
property :time_zone_id, String, default: 'UTC'
property :notify_recipients, String, required: true
property :notify_success, [TrueClass, FalseClass], default: false
property :notify_failure, [TrueClass, FalseClass], default: true
property :backup_prescript, String
property :backup_postscript, String
property :missed_backup_action_id, Integer, default: 1 # See http://docs.rackspace.com/rcbu/api/v1.0/rcbu-devguide/content/createConfig.html
property :mock, [TrueClass, FalseClass], default: false
property :rcbu_bootstrap_file, String, default: '/etc/driveclient/bootstrap.json'

action :create do
  new_resource.updated_by_last_action(
    api_obj.update(
      inclusions:        new_resource.inclusions,
      exclusions:        new_resource.exclusions,
      is_active:         new_resource.is_active,
      version_retention: new_resource.version_retention,
      frequency:         new_resource.frequency,
      start_time_hour:   new_resource.start_time_hour,
      start_time_minute: new_resource.start_time_minute,
      start_time_am_pm:  new_resource.start_time_am_pm,
      day_of_week_id:    new_resource.day_of_week_id,
      hour_interval:     new_resource.hour_interval,
      time_zone_id:      new_resource.time_zone_id,
      notify_recipients: new_resource.notify_recipients,
      notify_success:    new_resource.notify_success,
      notify_failure:    new_resource.notify_failure,
      backup_prescript:  new_resource.backup_prescript,
      backup_postscript: new_resource.backup_postscript,
      missed_backup_action_id: new_resource.missed_backup_action_id
    )
  )
end

action :create_if_missing do
  if new_resource.api_obj.backup_obj.BackupConfigurationId.nil?
    action_create
  else
    new_resource.updated_by_last_action(false)
  end
end

action_class.class_eval do
  def api_obj
    @api_obj ||= Opscode::Rackspace::CloudBackup::RcbuBackupWrapper.new(
      new_resource.rackspace_username,
      new_resource.rackspace_api_key,
      new_resource.rackspace_api_region,
      new_resource.label,
      new_resource.mock,
      new_resource.rcbu_bootstrap_file,
    )
  end
end
