# frozen_string_literal: true

require 'prometheus/client'

module QuePrometheus
  class WorkerMetricsMiddleware
    METRICS = [
      RunningSecondsTotal = Prometheus::Client::Counter.new(
        :que_worker_running_seconds_total,
        docstring: "Time since starting to work jobs",
        labels: %i[queue worker],
      ),
      SleepingSecondsTotal = Prometheus::Client::Counter.new(
        :que_worker_sleeping_seconds_total,
        docstring: "Time spent sleeping due to no jobs",
        labels: %i[queue worker],
      ),
      JobWorkedTotal = Prometheus::Client::Counter.new(
        :que_job_worked_total,
        docstring: "Counter for all jobs processed",
        labels: %i[job_class priority queue],
      ),
      JobErrorTotal = Prometheus::Client::Counter.new(
        :que_job_error_total,
        docstring: "Counter for all jobs that were run but errored",
        labels: %i[job_class priority queue],
      ),
      JobWorkedSecondsTotal = Prometheus::Client::Counter.new(
        :que_job_worked_seconds_total,
        docstring: "Sum of the time spent processing each job class",
        labels: %i[job_class priority queue],
      ),
      JobLatencySecondsTotal = Prometheus::Client::Counter.new(
        :que_job_latency_seconds_total,
        docstring: "Sum of time spent waiting in queue",
        labels: %i[job_class priority queue],
      ),

      ActiveWorkersCount = Prometheus::Client::Gauge.new(
        :que_worker_group_active_workers_count,
        docstring: "Number of active workers",
      ),
      ExpectedWorkersCount = Prometheus::Client::Gauge.new(
        :que_worker_group_expected_workers_count,
        docstring: "Number of configured workers",
      ),
    ].freeze

    def initialize(app, config = {})
      @app = app
      @registry = config.fetch(:registry, Prometheus::Client.registry)
      register(*METRICS)
    end

    def call(env)
      update_worker_guages
      @app.call(env)
    end

    private

    def update_worker_guages
      active_threads = Thread.list.select{ |t|
        t.name == "que_worker" && !t.status.nil?
      }
      ActiveWorkersCount.set(active_threads.count)
      # ExpectedWorkersCount.set(workers.count)
    end

    def register(*metrics)
      metrics.each do |metric|
        @registry.register(metric)
      end
    rescue Prometheus::Client::Registry::AlreadyRegisteredError
    end
  end
end
