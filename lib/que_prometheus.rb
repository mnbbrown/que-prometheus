# frozen_string_literal: true

require 'active_support/core_ext/module'
require 'que_prometheus/job_middleware'
require 'que_prometheus/worker_metrics_middleware'
require 'que_prometheus/queue_metrics_middleware'

require 'prometheus/middleware/exporter'
require 'webrick'
require 'rack'
require 'que'

module QuePrometheus
  class << self
    def run
      # metrics collector
      # Thread.new do
      #   Listener.subscribe do |event|
      #     next if event["current_state"] != "nonexistent"

      #     latency = Time.parse(event["time"]).to_i - Time.parse(event["run_at"]).to_i
      #     labels = {
      #       job_class: event["job_class"],
      #       queue: event["queue"],
      #       latency: latency,
      #       priority: NOT_AVAILABLE,
      #     }
      #     # set metrics
      #   end
      # end

      # add job middleware
      Que.job_middleware.push JobMiddleware

      # web server
      Thread.new do
        health_check = ->(_) { [200, {}, ['healthy']] }

        app = Rack::URLMap.new(
          '/' => Rack::Builder.new do
            use WorkerMetricsMiddleware
            use Prometheus::Middleware::Exporter

            run health_check
          end
          # "/queue" => Rack::Builder.new do
          #   registry = Prometheus::Client::Registry.new

          #   use QuePrometheus::QueueMetricsMiddleware, registry: registry
          #   use Prometheus::Middleware::Exporter, registry: registry

          #   run health_check
          # end,
        )

        port = ENV['METRICS_PORT'] || '8081'

        Rack::Handler::WEBrick.run(
          app,
          Host: '0.0.0.0',
          Port: port.to_i
          # Logger: WEBrick::Log.new("/dev/null"),
          # AccessLog: [],
        )
      end
    end
  end
end

QuePrometheus.run
