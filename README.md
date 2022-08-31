#### que-prometheus

**Experimental**

`que-prometheus` is a "plugin" for `que-rb/que` to support collecting job, worker and queue level metrics and exposing them to a prometheus collector on `/metrics` and `/queue/metrics`.
It's designed to support the same metrics that the `gocardless/que` fork produces.

#### installation

```
$ bundle add que_prometheus
```

and add the stats view using a rails migration

```ruby
require "que_prometheus/migrations"

class AddQuePrometheusView < ActiveRecord::Migration[7.0]
  def up
    ::QuePrometheus::Migrations.migrate!(version: 1)
  end

  def down
    ::QuePrometheus::Migrations.migrate!(version: 0)
  end
end
```

#### usage

`bundle exec que ./config/environment.rb que_prometheus`

Note: order is important, if `que_prometheus` is before environment it will complain about a connection not being available.

This will expose two endpoints:

- `/metrics` which exposes metrics specific to the running `que` process
- `/queue/metrics` which exposes queue summary metrics.
