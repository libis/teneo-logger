# frozen_string_literal: true

require_relative "lib/teneo/logger/version"

Gem::Specification.new do |spec|
  spec.name = "teneo-logger"
  spec.version = Teneo::Logger::VERSION
  spec.authors = ["Kris Dekeyser"]
  spec.email = ["kris.dekeyser@libis.be"]

  spec.summary = "Teneo Logging"
  spec.description = "Logging support for Teneo"
  spec.homepage = "https://github.com/LIBIS/teneo-logger"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "semantic_logger", "~> 4.11"

  spec.add_development_dependency "amazing_print", "~> 1.4"
  spec.add_development_dependency "timecop", "~> 0.9"
end
