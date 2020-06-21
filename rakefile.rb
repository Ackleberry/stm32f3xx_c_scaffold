require 'rake/clean'
require 'rake/loaders/makefile'

PROJECT = {
  :name => 'stm32f3xx_scaffold',
}

PREFIX = 'arm-none-eabi-'
TARGET = {
  :mcu_args => [
    '-mcpu=cortex-m4',
    '-mthumb',
    '-mfpu=fpv4-sp-d16',
    '-mfloat-abi=hard',
  ],
  :compiler => "#{PREFIX}gcc",
  :debug_args => [
    '-Og',
    '-Wall',
    '-fdata-sections',
    '-ffunction-sections',
    '-g',
    '-gdwarf-2',
  ],
  :release_args => [
    '-Og',
    '-Wall',
    '-fdata-sections',
    '-ffunction-sections',
  ],
  :assembler => "#{PREFIX}gcc -x assembler-with-cpp",
  :linker => '',
  :ld_script => 'STM32F303RETx_FLASH.ld',
  :linker_args => [

  ],
  :hex_file_args => [],
  :size => "#{PREFIX}size",
  :objcopy => "#{PREFIX}objcopy",
  :objcopy_args => [
    
  ],
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
  '-IDrivers/CMSIS/Include',
].join(" ")

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
  '-DSTM32F303xE',
].join(" ")

# libraries
LIBS = '-lc -lm -lnosys'
LIBDIR = ''
LDFLAGS = "-specs=nano.specs -T#{TARGET[:ld_script]} #{LIBDIR} #{LIBS} -Wl,-Map=build/debug/#{PROJECT[:name]}.map,--cref -Wl,--gc-sections"
LDFLAGS_rlse = "-specs=nano.specs -T#{TARGET[:ld_script]} #{LIBDIR} #{LIBS} -Wl,-Map=build/release/#{PROJECT[:name]}.map,--cref -Wl,--gc-sections"

# Create a mapping from all dependencies to their source files.
DEP_HASH = {
  :debug => {
    :obj_path => SOURCES.pathmap("build/debug/obj/%n.o").zip(SOURCES).to_h,
    :mf_path => SOURCES.pathmap("build/debug/dep/%n.mf").zip(SOURCES).to_h
  },
  :release => {
    :obj_path => SOURCES.pathmap("build/release/obj/%n.o").zip(SOURCES).to_h,
    :mf_path => SOURCES.pathmap("build/release/dep/%n.mf").zip(SOURCES).to_h
  },
}

get_src_path = lambda do |task_name|
  obj = task_name.pathmap("build/debug/obj/%n.o")
  DEP_HASH[:debug][:obj_path][obj]
end

task :default => ['debug:image']

namespace :debug do

  desc "Generates the flash image from ELF format"
  task :image => :link do |task|
    sh "#{TARGET[:objcopy]} -O ihex build/debug/#{PROJECT[:name]}.elf build/debug/#{PROJECT[:name]}.hex"
  end

  desc "Link the object files"
  task :link => DEP_HASH[:debug][:obj_path].keys do |task|
    obj = DEP_HASH[:debug][:obj_path].keys.join(' ')
    mcu_args = TARGET[:mcu_args].join(' ')
    sh "#{TARGET[:compiler]} #{obj} #{mcu_args} #{LDFLAGS} -o build/debug/#{PROJECT[:name]}.elf"
    sh "#{TARGET[:size]} build/debug/#{PROJECT[:name]}.elf"
  end

  rule %r{/debug/obj/\w+\.o} => get_src_path do |task|
    mkdir_p File.dirname(task.name)
    mcu_args = TARGET[:mcu_args].join(' ')
    debug_args = TARGET[:debug_args].join(' ')
    if File.extname(task.source) == '.c'
      sh "#{TARGET[:compiler]} -c #{mcu_args} #{DEFINES} #{INCLUDES} #{debug_args} #{task.source} -o #{task.name}"
    elsif File.extname(task.source) == '.s'
      sh "#{TARGET[:assembler]} -c #{mcu_args} #{DEFINES} #{INCLUDES} #{debug_args} #{task.source} -o #{task.name}"
    end
  end

  # Use GCC to output dependencies. Read and append .mf dependencies.
  # This ensures our dep files are regenerated when necessary.
  rule %r{/debug/dep/\w+\.mf} => get_src_path do |task|
    mkdir_p File.dirname(task.name)
    obj_path = task.name.pathmap("build/debug/obj/%n.o")
    mcu_args = TARGET[:mcu_args].join(' ')
    debug_args = TARGET[:debug_args].join(' ')
    if File.extname(task.source) == '.c'
      sh "#{TARGET[:compiler]} #{mcu_args} #{DEFINES} #{INCLUDES} #{debug_args} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    elsif File.extname(task.source) == '.s'
      sh "#{TARGET[:assembler]} #{mcu_args} #{DEFINES} #{INCLUDES} #{debug_args} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    end
  end

end

namespace :release do

  desc "Generates the flash image from ELF format"
  task :image => :link do |task|
    sh "#{TARGET[:objcopy]} -O ihex build/release/#{PROJECT[:name]}.elf build/release/#{PROJECT[:name]}.hex"
  end

  desc "Link the object files"
  task :link => DEP_HASH[:release][:obj_path].keys do |task|
    obj = DEP_HASH[:release][:obj_path].keys.join(' ')
    mcu_args = TARGET[:mcu_args].join(' ')
    sh "#{TARGET[:compiler]} #{obj} #{mcu_args} #{LDFLAGS_rlse} -o build/release/#{PROJECT[:name]}.elf"
    sh "#{TARGET[:size]} build/release/#{PROJECT[:name]}.elf"
  end

  rule %r{/release/obj/\w+\.o} => get_src_path do |task|
    mkdir_p File.dirname(task.name)
    mcu_args = TARGET[:mcu_args].join(' ')
    release_args = TARGET[:release_args].join(' ')
    if File.extname(task.source) == '.c'
      sh "#{TARGET[:compiler]} -c #{mcu_args} #{DEFINES} #{INCLUDES} #{release_args} #{task.source} -o #{task.name}"
    elsif File.extname(task.source) == '.s'
      sh "#{TARGET[:assembler]} -c #{mcu_args} #{DEFINES} #{INCLUDES} #{release_args} #{task.source} -o #{task.name}"
    end
  end

  rule %r{/release/dep/\w+\.mf} => get_src_path do |task|
    mkdir_p File.dirname(task.name)
    obj_path = task.name.pathmap("build/release/obj/%n.o")
    mcu_args = TARGET[:mcu_args].join(' ')
    release_args = TARGET[:release_args].join(' ')
    if File.extname(task.source) == '.c'
      sh "#{TARGET[:compiler]} #{mcu_args} #{DEFINES} #{INCLUDES} #{release_args} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    elsif File.extname(task.source) == '.s'
      sh "#{TARGET[:assembler]} #{mcu_args} #{DEFINES} #{INCLUDES} #{release_args} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    end
  end

end

# Declare an explict file task for each dependency file. This will
# use the rule defined to create .mf files defined earlier. This
# is necessary because it assures that the .mf file exists before
# importing then import each dependency file. If the file doesn't
# exist, then the file task to create it is invoked.
all_mf_files = DEP_HASH[:debug][:mf_path].keys + DEP_HASH[:release][:mf_path].keys
all_mf_files.each do |dep|
  file dep 
  puts "importing #{dep}"
  import dep #dependency file is imported after the Rakefile is loaded, but before and tasks are run
end

CLEAN.include(
  DEP_HASH[:debug][:mf_path].keys, 
  DEP_HASH[:release][:mf_path].keys, 
  DEP_HASH[:debug][:obj_path].keys, 
  DEP_HASH[:release][:obj_path].keys, 
  "build/debug/#{PROJECT[:name]}.*", 
  "build/release/#{PROJECT[:name]}.*"
)