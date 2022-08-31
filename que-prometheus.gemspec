# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "que_prometheus/version"

Gem::Specification.new do |s|
  s.name        = "que-prometheus"
  s.version     = QuePrometheus::VERSION
  s.summary     = "que-prometheus adds prometheus metric support to que-rb/que"
  s.description = "que-prometheus"
  s.authors     = ["GoCardless Engineering"]
  s.email       = "engineering@gocardless.com"
  s.metadata["rubygems_mfa_required"] = "true"
  s.required_ruby_version = ">= 3.0"

  files_to_exclude = [
    /\A\.circleci/,
    /\AGemfile/,
    /\Aspec/,
    /\Atasks/,
    /spec\.rb\z/,
  ]

  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR).reject do |file|
    files_to_exclude.any? { |r| r.match?(file) }
  end
  s.require_paths = ["lib"]
  s.homepage = "https://github.com/mnbbrown/que-prometheus"
  s.license = "MIT"

  s.add_development_dependency "gc_ruboconfig", "~> 3.3.0"
end
