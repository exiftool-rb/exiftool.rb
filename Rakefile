# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'README.md']
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.libs.push 'test'
  t.test_files = FileList['test/test_helper.rb', 'test/**/*_test.rb']
  t.verbose = true
end

task default: :test
