require 'active_record/tasks/database_tasks'
require_relative 'postgis_database_tasks'

module ActiveRecord
  module Tasks
    module DatabaseTasks
      register_task(/postgis/, ActiveRecord::Tasks::PostGISDatabaseTasks)
    end
  end
end
