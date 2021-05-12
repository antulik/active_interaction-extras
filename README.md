# ActiveInteraction::Extras

[![Gem Version](https://badge.fury.io/rb/active_interaction-extras.svg)](https://badge.fury.io/rb/active_interaction-extras) ![CI build](https://github.com/antulik/active_interaction-extras/actions/workflows/ci.yml/badge.svg)

This gem contains the collection of useful extensions to [active_interaction](https://github.com/AaronLasseigne/active_interaction) gem.

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Filters](#filters)
    - [Anything](#anything)
    - [UUID](#uuid)
- [Filter Extensions](#filter-extensions)
    - [Hash: auto strip](#hash-auto-strip)
    - [Object: multiple classes](#object-multiple-classes)
- [Extensions](#extensions)
  - [Filter alias](#filter-alias)
  - [Halt](#halt)
  - [ModelFields](#modelfields)
  - [RunCallback](#runcallback)
  - [StrongParams](#strongparams)
  - [Transaction](#transaction)
- [Jobs](#jobs)
  - [ActiveJob](#activejob)
  - [Sidekiq](#sidekiq)
- [RSpec](#rspec)

## Installation

```ruby
gem 'active_interaction-extras'
```

## Basic Usage

```ruby
# app/services/application_interaction.rb
class ApplicationInteraction < ActiveInteraction::Base
  include ActiveInteraction::Extras::All
end
```

## Filters

These new filters are added automatically when gem is loaded.

### Anything

Anything filter accepts as you guest it - anything.

```ruby
class Service < ActiveInteraction::Base
  anything :model
end
```

### UUID

```ruby
class Service < ActiveInteraction::Base
  uuid :id
end
```

## Filter Extensions

You can load all filter extensions with:

```ruby
# config/initializers/active_interaction.rb
require 'active_interaction/extras/filter_extensions'
```

### Hash: auto strip

This small extensions allows to accept full hashes without explicit `strip` option.

```ruby
class Service < ActiveInteraction::Base
  hash :options_a, strip: false # (Before) Accept all keys
  
  hash :options_b # (After) Accept all keys
  
  hash :options_c do # (Before and After) Accept only specified keys
    string :name
  end
end
```

### Object: multiple classes

This extension allows using `object` filter with multiple classes.

```ruby
class Service < ActiveInteraction::Base
  object :user, class: [User, AdminUser]
end
```


## Extensions

### Filter Alias

```ruby
class Service < ActiveInteraction::Base
  include ActiveInteraction::Extras::FilterAlias
  
  hash :params, as: :user_attributes

  def execute
    user_attributes == params # => true
  end
end
```

### Halt

```ruby
class Service < ActiveInteraction::Base
  include ActiveInteraction::Extras::Halt

  def execute
    other_method
    puts('finished') # this won't be called
  end

  def other_method
    errors.add :base, :invalid
    halt! if errors.any?
    # or
    halt_if_errors!
  end
end
```

### ModelFields

```ruby
class UserForm < ActiveInteraction::Base
  include ActiveInteraction::Extras::ModelFields

  anything :user

  model_fields(:user) do
    string :first_name
    string :last_name
  end

  def execute
    model_fields(:user)                   # => {:first_name=>"Albert", :last_name=>"Balk"}
    any_changed?(:first_name, :last_name) # => true
    given_model_fields(:user)             # => {:first_name=>"Albert"}
    changed_model_fields(:user)           # => {:first_name=>"Albert"}
  end
end

user = OpenStruct.new(first_name: 'Sam', last_name: 'Balk')

UserForm.new(user: user).first_name # => 'Sam'
UserForm.run!(user: user, first_name: 'Albert')
```

### RunCallback

```ruby
class Service < ActiveInteraction::Base
  include ActiveInteraction::Extras::RunCallback

  after_run do
    # LogAttempt.log
  end

  after_successful_run do
    # Email.deliver
  end

  after_failed_run do
    # NotifyAdminEmail.deliver
  end

  def execute
  end
end
```

### StrongParams

```ruby
class UpdateUserForm < ActiveInteraction::Base
  include ActiveInteraction::Extras::StrongParams

  string :first_name, default: nil, permit: true
  string :last_name, default: nil

  def execute
    first_name # => 'Allowed'
    last_name  # => nil
  end
end

UpdateUserForm.new.to_model.model_name.param_key # => 'update_user_form'

form_params = ActionController::Parameters.new(
  update_user_form: {
    first_name: 'Allowed',
    last_name: 'Not allowed',
  },
)

Service.run(params: form_params)

# OR
form_params = ActionController::Parameters.new(
  first_name: 'Allowed',
  last_name: 'Not allowed',
)

Service.run(form_params: form_params)
```

### Transaction

```ruby
class UpdateUserForm < ActiveInteraction::Base
  include ActiveInteraction::Extras::Transaction

  run_in_transaction!

  def execute
    Comment.create! # succeeds

    errors.add(:base, :invalid)
  end
end

UpdateUserForm.run
Comment.count # => 0
```

## Jobs

You no longer need to create a separate Job class for the each interaction. This Job extension automatically converts interactions to background jobs. By convention each interaction will have a nested `Job` class which will be inherited from the parent interaction `Job` class (e.g. `ApplicationInteraction::Job`). 

### ActiveJob

```ruby
class ApplicationInteraction < ActiveInteraction::Base
  include ActiveInteraction::Extras::ActiveJob

  class Job < ActiveJob::Base
    include ActiveInteraction::Extras::ActiveJob::Perform
  end
end

class DoubleService < ApplicationInteraction
  integer :x

  def execute
    x + x
  end
end

DoubleService.delay.run(x: 2) # queues to run in background
DoubleService.delay(queue: 'low_priority', wait: 1.minute).run(x: 2)
```

In ActiveJob mode `delay` method accepts anything ActiveJob `set` [method](https://edgeapi.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set) does. (`wait`, `wait_until`, `queue`, `priority`)

### Sidekiq

You can use sidekiq directly if you need more control. Sidekiq integration comes with default GlobalID support.

```ruby
class ApplicationInteraction < ActiveInteraction::Base
  include ActiveInteraction::Extras::Sidekiq

  class Job
    include Sidekiq::Worker
    include ActiveInteraction::Extras::Sidekiq::Perform
  end
end

class DoubleService < ApplicationInteraction
  job do
    sidekiq_options retry: 1 # configure sidekiq options
  end

  integer :x

  def execute
    x + x
  end
end

DoubleService.delay.run(x: 2) # queues to run in background
DoubleService.delay(queue: 'low_priority', wait: 1.minute).run(x: 2)
```

In Sidekiq mode `delay` method accepts anything sidekiq `set` [method](https://github.com/mperham/sidekiq/wiki/Advanced-Options#workers) does (`queue`, `retry`, `backtrace`, etc). Plus two additional `wait` and `wait_until`.

```ruby
# Advance usage: retry based on given params
class DoubleService < ApplicationInteraction
  job do
    sidekiq_options(retry: ->(job) {
      params = deserialize_active_job_args(job)
      params[:x]
    })
  end

  integer :x

  def execute
    x + x
  end
end
```

```ruby
# Advance usage: Rescue the job but not service
class DoubleService < ApplicationInteraction
  job do
    def perform(*args)
      super
    rescue StandardError => e
      params = deserialize_active_job_args(args)
      params[:x]
    end
  end

  integer :x

  def execute
    raise
  end
end

DoubleService.run # => RuntimeError
DoubleService.delay.perform_now(x: 2) # => returns 2
```

## Rspec

```ruby
class SomeService < ActiveInteraction::Base
  integer :x
end

RSpec.describe SomeService do
  include ActiveInteraction::Extras::Rspec

  it 'works' do
    expect_to_execute(SomeService,
      with: [{ x: 1 }]
      return: :asd
    )

    result = SomeService.run! x: 1

    expect(result).to eq :asd
  end

  it 'lists all mocks' do
    # allow_to_run
    # allow_to_execute
    # allow_to_delay_run
    # allow_to_delay_execute

    # expect_to_run / expect_not_to_run / expect_to_not_run
    # expect_to_execute
    # expect_to_delay_run / expect_not_to_run_delayed / expect_to_not_run_delayed
    # expect_to_delay_execute
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/antulik/active_interaction-extras. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

ActiveInteraction::Extras is brought to you by [Anton Katunin](https://github.com/antulik) and was originally built at [CarNextDoor](https://www.carnextdoor.com.au/).

## Code of Conduct

Everyone interacting in the ActiveInteraction::Extras project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/antulik/active_interaction-extras/blob/master/CODE_OF_CONDUCT.md).
