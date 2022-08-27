#### que-prometheus

**Experimental and broken**

`que-prometheus` is a "plugin" for `que-rb/que` to support collecting job, worker and queue level metrics and exposing them to a prometheus collector on `/metrics` and `/queue/metrics`.

#### usage

`bundle exec que ./config/environment.rb que_prometheus`

Note: order is important, if `que_prometheus` is before environment it will complain about a connection not being available.
