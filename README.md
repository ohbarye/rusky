# Rusky

Rusky is a lightweight library which helps you to manage Git hooks easily. Once you set up Rusky, it would be beneficial for all your team.

This library is inspired an awesome npm library, [husky](https://github.com/typicode/husky). So Rusky = Ruby + husky.

If you don't know Git hooks well, [the official document](https://git-scm.com/docs/githooks) would help you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rusky', group: :development
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install rusky
```

## Usage

1. Add the following lines into your Rakefile. It defines rake tasks to be executed on Git hook. The task names are `"rusky:#{git_hook_name}"`.

```ruby
require "rusky/task"
Rusky::Task.install
```

2. Create `.rusky` file and define what you want on Git hooks as YAML. Keys should be Git hook name. Values should be an array of shell commands. Rusky executes those commands on Git hook.

```yaml
# .rusky
pre-commit:
  - rubocop
pre-push:
  - bundle exec rspec
```

### Customizable callback rake task

You can write your own rake task as a callback of Git hook.

```ruby
# Rakefile
require "rusky/task"

namespace :rusky do
  task :pre_commit do
    # Your awesome task
  end
end

Rusky::Task.install
```

NOTE: You have to call `Rusky::Task.install` after your task definition. Otherwise, the task is defined twice. According to the current Rake spec, such a duplicated task does not overwrite a former one, both run when calling the task.  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ohbarye/rusky. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
