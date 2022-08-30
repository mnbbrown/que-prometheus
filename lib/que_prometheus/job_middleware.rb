# frozen_string_literal: true

module QuePrometheus
  module JobMiddleware
    def self.call(job)
      labels = {
        job_class: job.que_attrs[:job_class],
        priority: job.que_attrs[:priority],
        queue: job.que_attrs[:queue]
      }

      WorkerMetricsMiddleware::JobWorkedTotal.increment(
        labels: labels
      )

      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
    ensure
      finished = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if job.que_error.present?
        WorkerMetricsMiddleware::JobErrorTotal.increment(
          labels: labels
        )
      end
      WorkerMetricsMiddleware::JobWorkedSecondsTotal.increment(
        by: finished - started,
        labels: labels
      )
    end
  end
end
