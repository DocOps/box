# frozen_string_literal: true

begin
  require 'docopslab/dev'
  require 'asciisourcerer/'
rescue LoadError
  # docopslab-dev is an internal DocOps Lab gem used for contributor tasks.
  # See the Gemfile for install instructions.
end

desc 'Default: show this help message' do
  puts <<~HELP
    Available tasks:
    - help: Show this message.
    - build: Build the container images.
    - shell: Open a shell in the main container.
    - ex [tool]: Run a tool in the container (e.g., `rake ex pandoc`).
  HELP
end
task :help

desc 'Write a copy of the ./bin/dxbx help output to ephemeral local path.'
task :gen_dxbx_help do
  # quietly make docs/built if it doesn't exist
  FileUtils.mkdir_p('docs/built')
  output = `NO_COLOR=1 ./bin/dxbx --help`
  File.write('docs/built/dxbx_help.txt', output)
  puts 'Generated docs/built/dxbx_help.txt'
end

desc 'Use asciisourcerer to generate Markdown output for agents (main guide + prerequisite guides).'
task gen_agent_docs: :gen_dxbx_help do
  # Shared markdown converter for all skill conversions
  markdown_converter = proc do |html, markdown_options|
    Sourcerer::MarkDownGrade.bootstrap! unless @setup_complete
    # Replace the TablePassthrough with ReverseMarkdown's default converter
    ReverseMarkdown::Converters.register :table, ReverseMarkdown::Converters::Table.new
    @setup_complete = true
    Sourcerer::MarkDownGrade.convert_html(html, markdown_options || {})
  end

  # Define skills to convert (source .adoc → output .md in docs/agent/)
  skills = [
    { src: 'README.adoc', dest: 'docs/agent/readme.md', skim: true, skim_pattern: %r{^.*?/docs/agent/readme\.md$},
skim_key: 'docs/agent/readme.md' },
    { src: 'docs/skills/agent-guide.adoc', dest: 'docs/agent/user-guidance/SKILL.md', skim: true,
skim_pattern: %r{^.*?/docs/agent/user-guidance/SKILL\.md$}, skim_key: 'docs/agent/user-guidance/SKILL.md' },
    { src: 'docs/skills/host-prerequisites-macos.adoc', dest: 'docs/agent/host-prerequisites-macos/SKILL.md',
skim: false },
    { src: 'docs/skills/host-prerequisites-windows.adoc', dest: 'docs/agent/host-prerequisites-windows/SKILL.md',
skim: false }
  ]

  require 'json'

  skills.each do |skill|
    next unless File.exist?(skill[:src])

    # Ensure output directory exists
    FileUtils.mkdir_p(File.dirname(skill[:dest]))

    # Convert AsciiDoc to Markdown using MarkDownGrade
    Sourcerer::AsciiDoc.mark_down_grade(
      skill[:src],
      skill[:dest],
      markdown_converter: markdown_converter,
      html_output_path: "docs/built/#{File.basename(skill[:src], '.adoc')}-temp.html",
      backend: 'asciidoctor-html5s',
      include_frontmatter: true,
      markdown_options: { github_flavored: true })

    puts "Generated skill: #{skill[:dest]}"

    # Generate skim only for marked skills
    next unless skill[:skim]

    skim_json_raw = `rake labdev:skim[#{skill[:dest]},flat,json]`
    skim_data = JSON.parse(skim_json_raw)

    # Normalize paths: use custom pattern if provided, otherwise default
    skim_pattern = skill[:skim_pattern] || %r{^.*?/docs/agent/user-guidance/}
    skim_key = skill[:skim_key]

    fixed_skim = skim_data.transform_keys do |key|
      key.sub(skim_pattern, skim_key)
    end

    # For README, output as readme-skim.json; for skills, use skill-skim.json
    skim_filename = skill[:dest].include?('readme') ? 'readme-skim.json' : 'skill-skim.json'
    skim_file = File.join(File.dirname(skill[:dest]), skim_filename)
    File.write(skim_file, JSON.pretty_generate(fixed_skim))
    puts "Generated skim: #{skim_file}"
  end
end
