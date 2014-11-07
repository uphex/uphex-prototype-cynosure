require "bundler/gem_tasks"

# Import tasks from task directory.
Dir[File.join %w{lib uphex tasks ** *.rake}].each do |f|
  import f
end

def rake_ignore_errors(*errors, &block)
  begin
    yield block
  rescue *errors => e
    warn "! ignored #{e.class} ⇒ #{e}"
  end
end

def environment_guard(&block)
  target_env = ENV['RACK_ENV']
  raise ArgumentError, "won't run this task without an environment specified" unless target_env

  legal_environments = %w{development test}

  unless legal_environments.include? target_env
    raise RuntimeError, "environment is \"#{target_env}\", but will only run this task in #{legal_environments}"
  end

  block.call
end

namespace :uphex do
  rake_ignore_errors(LoadError) do
    require 'rspec/core/rake_task'
    desc 'run specs'
    RSpec::Core::RakeTask.new(:spec)

    require 'rubocop/rake_task'
    desc 'run Rubocop'
    RuboCop::RakeTask.new(:rubocop) do |task|
      style_cops = [
        'CaseIndentation',
        'ConstantName',
        'EmptyLines',
        'IndentationWidth',
        'SpaceAroundOperators',
        'Tab',
        'TrailingWhitespace',
        'CyclomaticComplexity',
        'LineLength',
        'ParameterLists',
        'PerceivedComplexity',
      ].join(',')

      task.options = [
        '-D',
        '--lint',
        "--only", style_cops,
      ]
      task.formatters = ['fuubar']

      directories = %w[
        lib
        spec
      ]
      task.patterns = directories.map { |prefix| "#{prefix}/**/*.rb" }
    end

    task :test => [:spec, :rubocop]
  end
end