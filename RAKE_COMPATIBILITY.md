# Rake 13.x Compatibility

This document outlines the changes made to support Rake 13.x in the abid gem.

## Overview

Rake 13.x introduced several changes to its internal API that required adjustments in abid. The primary goal was to maintain compatibility with both older and newer versions of Rake.

## Changes Made

### 1. Application Options

Rake 13.x changed how it handles application options. We've updated our code to accommodate these changes:

```ruby
# Added accessors for Rake 13.x compatibility
class << options
  attr_accessor :suppress_backtrace_pattern, :wait_external_task_interval,
                :wait_external_task_timeout, :disable_state
end
```

### 2. Method Definition Protection

To avoid conflicts with Rake's internal methods, we've added conditional method definitions:

```ruby
class Task
  unless method_defined?(:bind)
    def bind(params = {})
      # ...
    end
  end
end
```

### 3. Rake Module Extensions

We've updated the way we extend Rake's core functionality to avoid method redefinition warnings:

```ruby
unless Rake.singleton_methods.include?(:abid_original_application)
  class << Rake
    alias_method :abid_original_application, :application
    # ...
  end
end
```

### 4. Safe Option Access Methods

We've added helper methods to safely access options that might not exist in all Rake versions:

```ruby
def volatile?
  play.volatile || disable_state_option?
end

def disable_state_option?
  options = task.application.options
  return options.disable_state if options.respond_to?(:disable_state)
  false  # デフォルト値はfalse
end
```

### 5. Digest Library Dependency

Ruby 3.4 with Rake 13.x requires explicit loading of the Digest library:

```ruby
require 'yaml'
require 'digest/md5'  # Ruby 3.4対応: Digestライブラリを明示的に読み込む
```

## Remaining Issues

Some tests may still fail due to Rake 13.x compatibility issues. We're actively working on addressing these issues, particularly in these areas:

1. Task execution order
2. Exception handling differences
3. Thread management

## Rake Version Support

The gem now specifies `rake >= 13.0` as a dependency, indicating compatibility with all Rake 13.x versions. We recommend using the latest Rake version for the best experience.
