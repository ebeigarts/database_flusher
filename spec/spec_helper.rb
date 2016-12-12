$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'database_flusher'
require 'active_record'
require 'active_record/tasks/database_tasks'
require 'mongoid'
require 'byebug'

ENV['DB'] ||= 'sqlite3'
ActiveRecord::Tasks::DatabaseTasks.root = File.expand_path("../", __FILE__)
ActiveRecord::Base.configurations = YAML.load_file(
  File.expand_path('../database.yml', __FILE__)
)
ActiveRecord::Tasks::DatabaseTasks.drop_current ENV['DB']
ActiveRecord::Tasks::DatabaseTasks.create_current ENV['DB']
ActiveRecord::Base.establish_connection ENV['DB'].to_sym

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define do
  self.verbose = false
  create_table :posts, force: true
  create_table :comments, force: true
end

Mongoid.configure do |config|
  config.connect_to 'database_flusher'
end

class ActiveRecordPost < ActiveRecord::Base
  self.table_name = 'posts'
end

class ActiveRecordComment < ActiveRecord::Base
  self.table_name = 'comments'
end

class MongoidPost
  include Mongoid::Document
  store_in collection: 'posts'
end

class MongoidComment
  include Mongoid::Document
  store_in collection: 'comments'
end
