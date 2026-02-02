require 'xcodeproj'

project_path = 'TimeStop.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# File to add
file_path = 'TimeStop/Core/HapticsProvider.swift'

# Get the main group
main_group = project.main_group

# Navigate/create the Core group
core_group = main_group['TimeStop']['Core']

# Add the file to the group
file_ref = core_group.new_file(file_path)

# Add to both targets
project.targets.each do |target|
  next unless ['TimeStop', 'TimeStopWatch Watch App'].include?(target.name)
  
  # Find the build phase for this target
  build_phase = target.source_build_phase
  build_phase.add_file_reference(file_ref)
  
  puts "Added #{file_path} to target: #{target.name}"
end

# Save the project
project.save
puts "Project saved successfully"
