# Create a mapping from all dependencies to their source files.
DEP_HASH = {
  debug: {
    obj_path: SOURCES.pathmap('build/debug/obj/%n.o').zip(SOURCES).to_h,
    mf_path: SOURCES.pathmap('build/debug/dep/%n.mf').zip(SOURCES).to_h
  },
  release: {
    obj_path: SOURCES.pathmap('build/release/obj/%n.o').zip(SOURCES).to_h,
    mf_path: SOURCES.pathmap('build/release/dep/%n.mf').zip(SOURCES).to_h
  }
}

namespace :debug do
  desc 'Generate the HEX image from ELF file'
  task hex: "build/debug/#{TARGET[:name]}.hex"

  desc 'Link the object files and generate an ELF file'
  task elf: "build/debug/#{TARGET[:name]}.elf"

  file "build/debug/#{TARGET[:name]}.hex": "build/debug/#{TARGET[:name]}.elf" do |task|
    sh "#{TARGET[:objcopy]} -O ihex #{task.source} #{task.name}"
  end

  file "build/debug/#{TARGET[:name]}.elf": DEP_HASH[:debug][:obj_path].keys do |task|
    obj_files = task.prerequisites.join(' ')
    mcu_args = TARGET[:mcu_args].join(' ')
    map_file_path = '-Map=' + task.name.pathmap('%X.map')
    sh "#{TARGET[:compiler]} #{obj_files} #{mcu_args} -T#{TARGET[:ld_script]} #{TARGET[:linker_args]}#{map_file_path} -o #{task.name}"
    sh "#{TARGET[:size]} #{task.name}"
  end
end

namespace :release do
  desc 'Generate the HEX image from ELF file'
  task hex: "build/release/#{TARGET[:name]}.hex"

  desc 'Link the object files and generate an ELF file'
  task elf: "build/release/#{TARGET[:name]}.elf"

  file "build/release/#{TARGET[:name]}.hex": "build/release/#{TARGET[:name]}.elf" do |task|
    sh "#{TARGET[:objcopy]} -O ihex #{task.source} #{task.name}"
  end

  file "build/release/#{TARGET[:name]}.elf": DEP_HASH[:release][:obj_path].keys do |task|
    obj_files = task.prerequisites.join(' ')
    mcu_args = TARGET[:mcu_args].join(' ')
    map_file_path = '-Map=' + task.name.pathmap('%X.map')
    sh "#{TARGET[:compiler]} #{obj_files} #{mcu_args} -T#{TARGET[:ld_script]} #{TARGET[:linker_args]}#{map_file_path} -o #{task.name}"
    sh "#{TARGET[:size]} #{task.name}"
  end
end

get_src_path = lambda do |task_name|
  obj = task_name.pathmap('build/debug/obj/%n.o')
  DEP_HASH[:debug][:obj_path][obj]
end

rule %r{/obj/\w+\.o} => get_src_path do |task|
  mkdir_p File.dirname(task.name) unless File.exist?(File.dirname(task.name))
  mcu_args = TARGET[:mcu_args].join(' ')
  compiler_args = (task.name['/release/'] ? TARGET[:release_args] : TARGET[:debug_args]).join(' ')
  compiler = File.extname(task.source) == '.s' ? TARGET[:assembler] : TARGET[:compiler]
  sh "#{compiler} -c #{mcu_args} #{DEFINES} #{INCLUDES} #{compiler_args} #{task.source} -o #{task.name}"
end

# Gets GCC to output each obj files dependencies. This allows incremental builds.
rule %r{/dep/\w+\.mf} => get_src_path do |task|
  mkdir_p File.dirname(task.name) unless File.exist?(File.dirname(task.name))
  obj_path = task.name.pathmap('%{/dep/,/obj/}X.o')
  mcu_args = TARGET[:mcu_args].join(' ')
  compiler_args = (task.name['/release/'] ? TARGET[:release_args] : TARGET[:debug_args]).join(' ')
  compiler = File.extname(task.source) == '.s' ? TARGET[:assembler] : TARGET[:compiler]
  mf_args = "-MM -MP -MG -MT #{task.name} -MT #{obj_path}"
  sh "#{compiler} #{mcu_args} #{DEFINES} #{INCLUDES} #{compiler_args} #{mf_args} #{task.source} > #{task.name}"
end

# Declare an file task for each dep file. This will invoke the .mf rule above and is needed to create the file, if it
# does not exist, before importing. Recall importing occurrs after the rakefile is loaded, but before tasks are run.
all_mf_files = DEP_HASH[:debug][:mf_path].keys + DEP_HASH[:release][:mf_path].keys
all_mf_files.each do |dep|
  file dep
  import dep
end

CLEAN.include(
  DEP_HASH[:debug][:mf_path].keys,
  DEP_HASH[:release][:mf_path].keys,
  DEP_HASH[:debug][:obj_path].keys,
  DEP_HASH[:release][:obj_path].keys
)

CLOBBER.include(
  "build/debug/#{TARGET[:name]}.*",
  "build/release/#{TARGET[:name]}.*"
)