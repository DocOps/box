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

def dxbx_text
  @dxbx_text ||= File.read(File.join(REPO_ROOT, 'bin', 'dxbx'))
end

# Extractors#

# Parse a bare `ARG NAME=value` or `ARG NAME="value"` from the Dockerfile.
# Returns the value string, or nil if not found.
def dockerfile_arg name
  m = dockerfile_text.match(/^ARG #{Regexp.escape(name)}="?([^"\n]+?)"?\s*$/)
  m ? m[1].strip : nil
end

# Parse a LABEL key="value" or key=$VAR line (handles multi-line LABEL blocks).
# For $VAR references, resolves the value by looking up the ARG of the same name.
def dockerfile_label name
  # Quoted literal: version="1.2.3"
  m = dockerfile_text.match(/\b#{Regexp.escape(name)}="([^"]+)"/)
  return m[1] if m

  # Unquoted variable reference: version=$VARNAME — resolve via ARG
  m = dockerfile_text.match(/\b#{Regexp.escape(name)}=\$([A-Z_]+)/)
  return dockerfile_arg(m[1]) if m

  nil
end

# Parse a shell variable assignment: NAME="value" or NAME=value.
# Handles trailing inline comments (# ...) gracefully.
def build_matrix_var name
  # Prefer quoted value; fall back to unquoted (space/# terminates)
  m = build_matrix_text.match(/^#{Regexp.escape(name)}="([^"]+)"/) ||
      build_matrix_text.match(/^#{Regexp.escape(name)}=([^#"\s\n]+)/)
  m ? m[1].strip : nil
end

# Parse a shell variable assignment from bin/dxbx: NAME="value" or NAME=value.
# Handles trailing inline comments (# ...) gracefully.
def dxbx_var name
  m = dxbx_text.match(/^#{Regexp.escape(name)}="([^"]+)"/) ||
      dxbx_text.match(/^#{Regexp.escape(name)}=([^#"\s\n]+)/)
  m ? m[1].strip : nil
end

# Parse the DXBX_RUBY_VERSIONS array from bin/dxbx into individual elements.
def dxbx_ruby_versions
  m = dxbx_text.match(/^DXBX_RUBY_VERSIONS=\(([^)]+)\)/)
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

check 'Ruby default version (README → bin/dxbx DXBX_PRIMARY_RUBY)',
      readme_ruby, dxbx_var('DXBX_PRIMARY_RUBY')

check_includes 'Ruby default version included in bin/dxbx DXBX_RUBY_VERSIONS array',
               readme_ruby, dxbx_ruby_versions

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
