# frozen_string_literal: true

module QuePrometheus
  module JobMiddleware
    METRICS = [
      JobWorkedTotal = Prometheus::Client::Counter.new(
        :que_job_worked_total,
        docstring: 'Counter for all jobs processed',
        labels: %i[job_class priority queue]
      ),
      JobErrorTotal = Prometheus::Client::Counter.new(
        :que_job_error_total,
        docstring: 'Counter for all jobs that were run but errored',
        labels: %i[job_class priority queue]
      ),
      JobWorkedSecondsTotal = Prometheus::Client::Counter.new(
        :que_job_worked_seconds_total,
        docstring: 'Sum of the time spent processing each job class',
        labels: %i[job_class priority queue]
      ),
      JobLatencySecondsTotal = Prometheus::Client::Counter.new(
        :que_job_latency_seconds_total,
        docstring: 'Sum of time spent waiting in queue',
        labels: %i[job_class priority queue]
      ),
    ]

    def self.call(job)
      labels = {
        job_class: job.que_attrs[:job_class],
        priority: job.que_attrs[:priority],
        queue: job.que_attrs[:queue]
      }

      JobWorkedTotal.increment(
        labels: labels
      )

      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
    ensure
      finished = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if job.que_error.present?
        JobErrorTotal.increment(
          labels: labels
        )
      end
      JobWorkedSecondsTotal.increment(
        by: finished - started,
        labels: labels
      )
    end
  end
end
