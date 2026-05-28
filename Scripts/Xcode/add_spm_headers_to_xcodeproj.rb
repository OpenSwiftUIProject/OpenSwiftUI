#!/usr/bin/env ruby

require "digest"

script_dir = File.expand_path(__dir__)
repo_root = File.expand_path("../..", script_dir)
project_path = File.expand_path(ARGV[0] || File.join(repo_root, "OpenSwiftUI.xcodeproj"))
headers_root = File.expand_path(ARGV[1] || File.join(repo_root, "Sources/OpenSwiftUI_SPI"))
target_group_name = ARGV[2] || "OpenSwiftUI_SPI"

pbxproj_path = File.join(project_path, "project.pbxproj")
abort "error: #{pbxproj_path} does not exist" unless File.file?(pbxproj_path)
abort "error: #{headers_root} does not exist" unless Dir.exist?(headers_root)

def pbx_string(value)
  %("#{value.gsub("\\", "\\\\\\").gsub('"', '\"')}")
end

def generated_pbx_id(seed)
  Digest::MD5.hexdigest(seed)[0, 24].upcase
end

headers = Dir
  .glob(File.join(headers_root, "**/*.h"))
  .map { |path| path.delete_prefix("#{headers_root}/") }
  .sort

abort "error: no headers found under #{headers_root}" if headers.empty?

pbxproj = File.read(pbxproj_path)
header_group_id = generated_pbx_id("#{target_group_name}:generated-header-group")
header_file_ids = headers.to_h { |path| [path, generated_pbx_id("#{target_group_name}:header:#{path}")] }

file_references = headers.map do |path|
  id = header_file_ids.fetch(path)
  next if pbxproj.include?("#{id} /*")

  name = File.basename(path)
  "\t\t#{id} /* #{name} */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; name = #{pbx_string(name)}; path = #{pbx_string(path)}; sourceTree = \"<group>\"; };"
end.compact.join("\n")

unless file_references.empty?
  pbxproj.sub!(
    "/* End PBXFileReference section */",
    "#{file_references}\n/* End PBXFileReference section */"
  )
end

children = headers.map do |path|
  "\t\t\t\t#{header_file_ids.fetch(path)} /* #{File.basename(path)} */,"
end.join("\n")

header_group = <<~PBX.chomp
\t\t#{header_group_id} /* Headers */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
#{children}
\t\t\t);
\t\t\tname = Headers;
\t\t\tpath = ".";
\t\t\tsourceTree = "<group>";
\t\t};
PBX

header_group_regex = /^\t\t#{header_group_id} \/\* Headers \*\/ = \{.*?^\t\t\};\n/m
if pbxproj.match?(header_group_regex)
  pbxproj.sub!(header_group_regex, "#{header_group}\n")
else
  pbxproj.sub!(
    "/* End PBXGroup section */",
    "#{header_group}\n/* End PBXGroup section */"
  )
end

target_group_regex = /
  ^\t\t(?<id>[A-F0-9]{24})\ \/\*\ #{Regexp.escape(target_group_name)}\ \*\/\ =\ \{\n
  \t\t\tisa\ =\ PBXGroup;\n
  \t\t\tchildren\ =\ \(\n
  (?<children>.*?)
  \t\t\t\);\n
  \t\t\tpath\ =\ #{Regexp.escape(target_group_name)};\n
  \t\t\tsourceTree\ =\ "<group>";\n
  \t\t\};
/mx

match = pbxproj.match(target_group_regex)
abort "error: could not find PBXGroup for #{target_group_name}" unless match

unless match[:children].include?(header_group_id)
  replacement = match[0].sub(
    "\t\t\t);\n",
    "\t\t\t\t#{header_group_id} /* Headers */,\n\t\t\t);\n"
  )
  pbxproj.sub!(target_group_regex, replacement)
end

File.write(pbxproj_path, pbxproj)
puts "Ensured #{headers.count} #{target_group_name} headers are visible in #{project_path}"
