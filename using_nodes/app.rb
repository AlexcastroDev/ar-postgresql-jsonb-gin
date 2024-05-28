# frozen_string_literal: true
require_relative 'user'
require "logger"
require 'benchmark/ips'

# Debugging
# ActiveRecord::Base.logger = Logger.new(STDOUT)

Benchmark.ips do |x|
  # Configure the number of seconds used during
  # the warmup phase (default 2) and calculation phase (default 5)
  x.config(:time => 5, :warmup => 2)

  # These parameters can also be configured this way
  x.time = 5
  x.warmup = 2

  # Typical mode, runs the block as many times as it can
  x.report("find_by_uuid") { User.find_by_uuid("itachiuchihadekonoha") }
  
  x.compare!
end
