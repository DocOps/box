#!/usr/bin/env ruby
# frozen_string_literal: true

# scripts/check-consistency.rb
#
# Verifies that version numbers and other duplicated values are consistent
# across source files. Intended as a pre-commit check.
#
# The README.adoc attribute header is the single source of truth.
# All other files must agree with it.
#
# Usage:
#   bundle exec ruby scripts/check-consistency.rb
#
# Exit codes:
#   0 — all checks pass
#   1 — one or more mismatches found

require 'asciisourcerer'

REPO_ROOT = File.expand_path('..', __dir__)

def passes
  @passes ||= []
end

def failures
  @failures ||= []
end

# Source readers#

def readme_attrs
  @readme_attrs ||= AsciiSourcerer::AsciiDoc.load_attributes(
    File.join(REPO_ROOT, 'README.adoc'))
end

def dockerfile_text
  @dockerfile_text ||= File.read(File.join(REPO_ROOT, 'Dockerfile'))
end

def build_matrix_text
  @build_matrix_text ||= File.read(File.join(REPO_ROOT, 'scripts', 'build-matrix.sh'))
end

# Extractors#

# Parse a bare `ARG NAME=value` or `ARG NAME="value"` from the Dockerfile.
# Returns the value string, or nil if not found.
def dockerfile_arg name
  m = dockerfile_text.match(/^ARG #{Regexp.escape(name)}="?([^"\n]+?)"?\s*$/)
  m ? m[1].strip : nil
end

# Parse a LABEL key="value" line (handles multi-line LABEL blocks).
def dockerfile_label name
  m = dockerfile_text.match(/\b#{Regexp.escape(name)}="([^"]+)"/)
  m ? m[1] : nil
end

# Parse a shell variable assignment: NAME="value" or NAME=value.
# Handles trailing inline comments (# ...) gracefully.
def build_matrix_var name
  # Prefer quoted value; fall back to unquoted (space/# terminates)
  m = build_matrix_text.match(/^#{Regexp.escape(name)}="([^"]+)"/) ||
      build_matrix_text.match(/^#{Regexp.escape(name)}=([^#"\s\n]+)/)
  m ? m[1].strip : nil
end

# Parse the RUBY_VERSIONS array from build-matrix.sh into individual elements.
def build_matrix_ruby_versions
  m = build_matrix_text.match(/^RUBY_VERSIONS=\(([^)]+)\)/)
  return [] unless m

  m[1].scan(/"([^"]+)"/).flatten
end

# Check helper#

def check label, expected, actual
  if expected == actual
    passes << "#{label}: #{actual}"
  else
    failures << <<~MSG.chomp
      #{label}
          expected (README.adoc): #{expected.inspect}
          actual:                #{actual.inspect}
    MSG
  end
end

def check_includes label, expected_member, collection
  if collection.include?(expected_member)
    passes << "#{label}: #{expected_member} in #{collection.inspect}"
  else
    failures << "#{label}\n    #{expected_member.inspect} not found in #{collection.inspect}"
  end
end

# Checks#

readme_ruby    = readme_attrs['docopslab_ruby_version']
readme_nodejs  = readme_attrs['default_nodejs_version']
readme_version = readme_attrs['this_proj_vrsn']

check 'Ruby default version (README → Dockerfile ARG RUBY_VERSION)',
      readme_ruby, dockerfile_arg('RUBY_VERSION')

check 'Ruby default version (README → build-matrix.sh PRIMARY_RUBY)',
      readme_ruby, build_matrix_var('PRIMARY_RUBY')

check_includes 'Ruby default version included in build-matrix.sh RUBY_VERSIONS array',
               readme_ruby, build_matrix_ruby_versions

check 'Node.js version (README → Dockerfile ARG NODEJS_VERSION)',
      readme_nodejs, dockerfile_arg('NODEJS_VERSION')

check 'Project version (README → Dockerfile LABEL version)',
      readme_version, dockerfile_label('version')

# Report#

puts

passes.each { |msg| puts "  \e[32m✓\e[0m  #{msg}" }

if failures.any?
  puts if passes.any?
  failures.each do |msg|
    lines = msg.split("\n")
    puts "  \e[31m✗\e[0m  #{lines.shift}"
    lines.each { |l| puts "       #{l}" }
  end
  puts
  puts "\e[31mConsistency check failed — #{failures.size} mismatch#{'es' if failures.size != 1} found.\e[0m"
  puts 'Fix the values listed above, then commit again.'
  puts
  exit 1
else
  puts
  puts "\e[32mAll consistency checks passed.\e[0m"
  puts
end
