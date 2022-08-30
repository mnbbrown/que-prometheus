# frozen_string_literal: true

require 'json'

module QuePrometheus
  class Listener
    def subscribe
      connection.execute('LISTEN que_state')
      loop do
        connection.raw_connection.wait_for_notify do |_event, _id, data|
          yield JSON.parse(data)
        end
      end
    ensure
      connection.execute 'UNLISTEN que_state'
    end

    private

    def connection
      ActiveRecord::Base.connection
    end
  end
end
