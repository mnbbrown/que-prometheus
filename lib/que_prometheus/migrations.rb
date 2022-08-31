# frozen_string_literal: true

module QuePrometheus
  module Migrations
    # In order to ship a schema change, add the relevant up and down sql files
    # to the migrations directory, and bump the version here.
    CURRENT_VERSION = 1

    class << self
      def migrate!(version:)
        Que.transaction do
          current = db_version

          if current == version
            return
          elsif current < version
            direction = :up
            steps = ((current + 1)..version).to_a
          elsif current > version
            direction = :down
            steps = ((version + 1)..current).to_a.reverse
          end

          steps.each do |step|
            filename = [
              File.dirname(__FILE__),
              "migrations",
              step,
              direction,
            ].join("/") << ".sql"
            Que.execute(File.read(filename))
          end

          self.db_version = version
        end
      end

      def db_version
        result =
          Que.execute <<-SQL
            SELECT relname, description
            FROM pg_class
            LEFT JOIN pg_description ON pg_description.objoid = pg_class.oid
            WHERE relname = 'que_jobs_summary'
          SQL

        if result.none?
          # No view in the database at all.
          0
        elsif (d = result.first[:description]).nil?
          # There's a view, it was just created before the migration system
          # existed.
          1
        else
          d.to_i
        end
      end

      def db_version=(version)
        i = version.to_i
        if !i.zero?
          Que.execute "COMMENT ON MATERIALIZED VIEW que_jobs_summary IS '#{i}'"
        end
      end
    end
  end
end
