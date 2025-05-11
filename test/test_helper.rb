require 'abid'
require 'concurrent/configuration'
require 'minitest/autorun'

Abid::Config.search_path.unshift File.expand_path('../abid.yml', __FILE__)
Concurrent.use_stdlib_logger(Logger::DEBUG)

class AbidTest < Minitest::Test
  attr_reader :env

  def self.history
    @history ||= []
  end

  def run(*args, &block)
    Abid.global = Abid::Environment.new
    @env = Abid.global
    init_app

    AbidTest.history.clear
    @env.state_manager.db[:states].delete

    load File.expand_path('../Abidfile.rb', __FILE__)
    super
  ensure
    @env.engine.kill(RuntimeError.new('premature end of test'))
  end

  def init_app
    @env.application.init
    @env.application.options.logging = false
    @env.application.options.summary = false
    
    # Rake 13.x compatibility - suppress backtrace pattern
    if @env.application.options.respond_to?(:suppress_backtrace_pattern=)
      @env.application.options.suppress_backtrace_pattern = nil
    end
  end

  def mock_state(name, params = {})
    s = env.state_manager.state(name, params).find
    t = Time.now
    s.set(state: Abid::StateManager::State::SUCCESSED,
          start_time: t, end_time: t)
    yield s if block_given?
    s.tap(&:save)
  end

  def mock_fail_state(name, params = {})
    mock_state(name, params) do |s|
      s.state = Abid::StateManager::State::FAILED
      yield s if block_given?
    end
  end

  def mock_running_state(name, params = {})
    mock_state(name, params) do |s|
      s.state = Abid::StateManager::State::RUNNING
      yield s if block_given?
    end
  end

  def invoke(*args)
    env.engine.invoke(*args)
  end

  def find_process(name, params = {})
    job = env.application.job_manager[name, params]
    env.engine.process_manager[job]
  end

  def in_options(opts)
    return yield if opts.nil? || opts.empty?  # Rake 13.x対応: nilや空のハッシュの場合は何もせずにブロックを実行
    
    orig = {}
    # Rake 13.x対応: optionsオブジェクトの変更が必要な場合は既存のキーを保存
    opts.each do |k, _|
      orig[k] = env.application.options.respond_to?(k) ? env.application.options.send(k) : nil
    end
    
    # オプションを設定
    opts.each do |k, v|
      if env.application.options.respond_to?(:"#{k}=")
        env.application.options.send(:"#{k}=", v)
      end
    end
    
    yield
  ensure
    # 元の値に戻す
    if orig && !orig.empty?
      orig.each do |k, v|
        if env.application.options.respond_to?(:"#{k}=")
          env.application.options.send(:"#{k}=", v)
        end
      end
    end
  end

  # empty Rake::TaskArguments
  def empty_args
    Rake::TaskArguments.new([], [])
  end
end
