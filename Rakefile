require 'rake/clean'
require 'rake/loaders/makefile'

PREFIX = 'arm-none-eabi-'
TARGET = {
  name: 'stm32f3xx_scaffold',
  mcu_args: [
    '-mcpu=cortex-m4',
    '-mthumb',
    '-mfpu=fpv4-sp-d16',
    '-mfloat-abi=hard'
  ],
  compiler: "#{PREFIX}gcc",
  debug_args: [
    '-Og',
    '-Wall',
    '-fdata-sections',
    '-ffunction-sections',
    '-g',
    '-gdwarf-2'
  ],
  release_args: [
    '-O3',
    '-Wall',
    '-fdata-sections',
    '-ffunction-sections'
  ],
  assembler: "#{PREFIX}gcc -x assembler-with-cpp",
  ld_script: 'STM32F303RETx_FLASH.ld',
  linker_args: '-specs=nano.specs -lc -lm -lnosys -Wl,--cref -Wl,--gc-sections,',
  size: "#{PREFIX}size",
  objcopy: "#{PREFIX}objcopy"
}

SOURCES = Rake::FileList[
  'Src/**/*.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_utils.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_exti.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_gpio.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_usart.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_rcc.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_dma.c',
  'startup_stm32f303xe.s',
]

INCLUDES = [
  '-IInc',
  '-IDrivers/STM32F3xx_HAL_Driver/Inc',
  '-IDrivers/CMSIS/Device/ST/STM32F3xx/Include',
  '-IDrivers/CMSIS/Include',
  '-IDrivers/CMSIS/Include'
].join(' ')

DEFINES = [
  '-DUSE_FULL_LL_DRIVER',
  '-DHSE_VALUE=8000000',
  '-DHSE_STARTUP_TIMEOUT=100',
  '-DLSE_STARTUP_TIMEOUT=5000',
  '-DLSE_VALUE=32768',
  '-DEXTERNAL_CLOCK_VALUE=8000000',
  '-DHSI_VALUE=8000000',
  '-DLSI_VALUE=40000',
  '-DVDD_VALUE=3300',
  '-DPREFETCH_ENABLE=1',
  '-DSTM32F303xE'
].join(' ')

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

task default: 'debug:hex'

namespace :debug do
  desc 'Generate the HEX image from ELF file'
  task hex: "build/debug/#{TARGET[:name]}.hex"

  desc 'Link the object files and generate an ELF file'
  task elf: "build/debug/#{TARGET[:name]}.elf"

  desc "Flash the target with the HEX image. Compatible with only an MBED enabled device. DRIVE=<mbed drive> must be provided."
  task :mbed_flash do
    rsp = `ls /mnt/#{ENV['DRIVE']}`
    if rsp['MBED.HTM']
      sh "cp ./build/debug/stm32f3xx_scaffold.hex /mnt/#{ENV['DRIVE']}"
    else
      puts "ERROR: Drive is not MBED enabled. Task cancelled."
    end
  end

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

  desc "Sends mbed enabled programmer the HEX image to flash the target, DRIVE=<mbed drive> must be provided."
  task :mbed_flash do
    #sh "sudo mkdir /mnt/#{ENV['DRIVE']}" unless File.exist?("/mnt/#{ENV['DRIVE']}")
    sh "sudo mount -t drvfs #{ENV['DRIVE']}: /mnt/#{ENV['DRIVE']}"
    rsp = `ls /mnt/#{ENV['DRIVE']}`
    if rsp['MBED.HTM']
      sh "cp ./build/release/stm32f3xx_scaffold.hex /mnt/#{ENV['DRIVE']}"
    else
      puts "ERROR: Drive is not MBED enabled. Task cancelled."
    end
  end

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
  puts "importing #{dep}"
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
