Gem::Specification.new do |s|
  s.name        = "que-prometheus"
  s.version     = "0.0.1"
  s.summary     = "que-prometheus adds prometheus metric support to que-rb/que"
  s.description = "que-prometheus"
  s.authors     = ["GoCardless Engineering"]
  s.email       = "engineering@gocardless.com"

  files_to_exclude = [
    /\A\.circleci/,
    /\AGemfile/,
    /\Aspec/,
    /\Atasks/,
    /spec\.rb\z/,
  ]

  s.files = `git ls-files`.split($/).reject do |file|
    files_to_exclude.any? { |r| r === file }
  end
  s.require_paths = ['lib']
  s.homepage    = "https://github.com/mnbbrown/que-prometheus"
  s.license       = "MIT"
end
