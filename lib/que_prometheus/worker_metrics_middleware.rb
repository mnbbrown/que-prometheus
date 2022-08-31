# frozen_string_literal: true

require 'prometheus/client'

module QuePrometheus
  class WorkerMetricsMiddleware
    METRICS = [
      # these metrics are currently not supported
      # but support is planned.
      # RunningSecondsTotal = Prometheus::Client::Counter.new(
      #   :que_worker_running_seconds_total,
      #   docstring: 'Time since starting to work jobs',
      #   labels: %i[queue worker]
      # ),
      # SleepingSecondsTotal = Prometheus::Client::Counter.new(
      #   :que_worker_sleeping_seconds_total,
      #   docstring: 'Time spent sleeping due to no jobs',
      #   labels: %i[queue worker]
      # ),
      ActiveWorkersCount = Prometheus::Client::Gauge.new(
        :que_worker_group_active_workers_count,
        docstring: 'Number of active workers'
      ),
      ExpectedWorkersCount = Prometheus::Client::Gauge.new(
        :que_worker_group_expected_workers_count,
        docstring: 'Number of configured workers'
      ),
    ].freeze

    def initialize(app, config = {})
      @app = app
      @registry = config.fetch(:registry, Prometheus::Client.registry)
      register(*METRICS)
      register(*JobMiddleware::METRICS)
    end

    def call(env)
      update_worker_guages
      @app.call(env)
    end

    private

    def update_worker_guages
      active_threads = Que.locker.workers.map(&:thread).reject do |t|
        t.status.nil?
      end
      ActiveWorkersCount.set(active_threads.count)
      ExpectedWorkersCount.set(Que.locker.workers.count)
    end

    def register(*metrics)
      metrics.each do |metric|
        @registry.register(metric)
      end
    rescue Prometheus::Client::Registry::AlreadyRegisteredError
    end
  end
end
