require 'rake/clean'
require 'rake/loaders/makefile'

######################################
# Project settings
######################################
PROJECT = {
  :name => 'stm32f3xx_scaffold',
}
######################################
# target settings
######################################
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
    
  ],
  :release_args => [
    
  ],
  :assembler => "#{PREFIX}gcc -x assembler-with-cpp",
  :linker => '',
  :linker_args => [

  ],
  :hex_file_args => [],
  :size => "#{PREFIX}size",
  :objcopy => "#{PREFIX}objcopy",
  :objcopy_args => [
    
  ],
}

######################################
# building variables
######################################
# debug build?
DEBUG = true
# optimization
OPT = '-Og'

#######################################
# paths
#######################################
# Build path
BUILD_DIR = 'build'

DEBUG_DIR = 'debug'
RELEASE_DIR = 'release'
DEP_DIR = 'dep'


C_SOURCES = Rake::FileList[
  'Src/**/*.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_utils.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_exti.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_gpio.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_usart.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_rcc.c',
  'Drivers/STM32F3xx_HAL_Driver/Src/stm32f3xx_ll_dma.c',
]

ASM_SOURCES =  Rake::FileList[
  'startup_stm32f303xe.s',
]

CC = "#{PREFIX}gcc"
AS = "#{PREFIX}gcc -x assembler-with-cpp"
CP = "#{PREFIX}objcopy"
SZ = "#{PREFIX}size"
HEX = "#{CP} -O ihex"
 
# cpu
CPU = "-mcpu=cortex-m4"
# fpu
FPU = "-mfpu=fpv4-sp-d16"
# float-abi
FLOAT_ABI = "-mfloat-abi=hard"
# mcu
MCU = "#{CPU} -mthumb #{FPU} #{FLOAT_ABI}"

# macros for gcc
# AS defines
AS_DEFS = ""

# C defines
C_DEFS =  [
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

# AS includes
AS_INCLUDES = ""

# C includes
C_INCLUDES = [
  '-IInc',
  '-IDrivers/STM32F3xx_HAL_Driver/Inc',
  '-IDrivers/CMSIS/Device/ST/STM32F3xx/Include',
  '-IDrivers/CMSIS/Include',
  '-IDrivers/CMSIS/Include',
].join(" ")

# compile gcc flags
ASFLAGS = "#{MCU} #{AS_DEFS} #{AS_INCLUDES} #{OPT} -Wall -fdata-sections -ffunction-sections"

CFLAGS = "#{MCU} #{C_DEFS} #{C_INCLUDES} #{OPT} -Wall -fdata-sections -ffunction-sections"

if DEBUG
  CFLAGS + ' -g -gdwarf-2'
end

#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = 'STM32F303RETx_FLASH.ld'

# libraries
LIBS = '-lc -lm -lnosys'
LIBDIR = ''
LDFLAGS = "#{MCU} -specs=nano.specs -T#{LDSCRIPT} #{LIBDIR} #{LIBS} -Wl,-Map=build/#{DEBUG_DIR}/#{PROJECT[:name]}.map,--cref -Wl,--gc-sections"
LDFLAGS_rlse = "#{MCU} -specs=nano.specs -T#{LDSCRIPT} #{LIBDIR} #{LIBS} -Wl,-Map=build/#{RELEASE_DIR}/#{PROJECT[:name]}.map,--cref -Wl,--gc-sections"
SOURCE_FILES = C_SOURCES + ASM_SOURCES

# Create a mapping from objects to source files.
OBJ_DEBUG_HASH = SOURCE_FILES.inject({}) do |cont, src_path|
  obj_path = src_path.pathmap("build/debug/obj/%n.o")
  cont[obj_path] = src_path
  cont
end

# DEP_HASH = {
#   :debug => {
#     [SOURCE_FILES.pathmap("build/debug/obj/%n.o").zip(SOURCE_FILES)]
#   },
#   :release => {
#     [SOURCE_FILES.pathmap("build/release/obj/%n.o").zip(SOURCE_FILES)]
#   },
# }

# DEP_HASH[:debug][SOURCE_FILES.pathmap("build/debug/obj/%n.o")] = SOURCE_FILES
# DEP_HASH[:release][SOURCE_FILES.pathmap("build/release/obj/%n.o")] = SOURCE_FILES
# DEP_HASH[:debug][SOURCE_FILES.pathmap("build/debug/dep/%n.mf")] = SOURCE_FILES
# DEP_HASH[:release][SOURCE_FILES.pathmap("build/release/dep/%n.mf")] = SOURCE_FILES

# DEP_HASH = SOURCE_FILES.inject() do |cont, src_path|
#   debug_dep_path = src_path.pathmap("build/debug/dep/%n.mf")
#   debug_obj_path = src_path.pathmap("build/debug/obj/%n.o")
#   release_dep_path = src_path.pathmap("build/release/dep/%n.mf")
#   release_obj_path = src_path.pathmap("build/release/obj/%n.o")

#   cont[:debug][debug_obj_path] = src_path
#   cont[:release][release_obj_path] = src_path
#   cont[:debug][debug_dep_path] = src_path
#   cont[:release][release_dep_path] = src_path
# end

# puts DEP_HASH

OBJ_RELEASE_HASH = SOURCE_FILES.inject({}) do |cont, src_path|
  obj_path = src_path.pathmap("build/release/obj/%n.o")
  cont[obj_path] = src_path
  cont
end

# Create a mapping from dependencies to source files.
DEP_DEBUG_HASH = SOURCE_FILES.inject({}) do |cont, src_path|
  dep_path = src_path.pathmap("build/debug/dep/%n.mf")
  cont[dep_path] = src_path
  cont
end

DEP_RELEASE_HASH = SOURCE_FILES.inject({}) do |cont, src_path|
  dep_path = src_path.pathmap("build/release/dep/%n.mf")
  cont[dep_path] = src_path
  cont
end

get_src_path_dbg = lambda do |task_name|
  puts task_name
  if File.extname(task_name) == '.o'
    OBJ_DEBUG_HASH[task_name]
  elsif File.extname(task_name) == '.mf'
    DEP_DEBUG_HASH[task_name]
  end
end

get_src_path_rlse = lambda do |task_name| 
  if File.extname(task_name) == '.o'
    OBJ_RELEASE_HASH[task_name]
  elsif File.extname(task_name) == '.mf'
    DEP_RELEASE_HASH[task_name]
  end
end

task :default => ['debug:image']

namespace :debug do

  desc "Generates the flash image from ELF format"
  task :image => :link do |task|
    sh "#{HEX} build/#{DEBUG_DIR}/#{PROJECT[:name]}.elf build/#{DEBUG_DIR}/#{PROJECT[:name]}.hex"
  end

  desc "Link the object files"
  task :link => OBJ_DEBUG_HASH.keys do |task|
    obj = OBJ_DEBUG_HASH.keys.join(' ')
    sh "#{CC} #{obj} #{LDFLAGS} -o build/#{DEBUG_DIR}/#{PROJECT[:name]}.elf"
    sh "#{SZ} build/#{DEBUG_DIR}/#{PROJECT[:name]}.elf"
  end

  rule %r{/debug\/obj\/\w+\.o} => get_src_path_dbg do |task|
    mkdir_p File.dirname(task.name)
    if File.extname(task.source) == '.c'
      sh "#{CC} -c #{CFLAGS} #{task.source} -o #{task.name}"
    elsif File.extname(task.source) == '.s'
      sh "#{AS} -c #{ASFLAGS} #{task.source} -o #{task.name}"
    end
  end

  # Use GCC to output dependencies. Read and append .mf dependencies.
  # This ensures our dep files are regenerated when necessary.
  rule %r{/debug/dep/\w+\.mf} => get_src_path_dbg do |task|
    mkdir_p File.dirname(task.name)
    obj_path = task.name.pathmap("build/debug/obj/%n.o")
    if File.extname(task.source) == '.c'
      sh "#{CC} #{CFLAGS} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    elsif File.extname(task.source) == '.s'
      sh "#{AS} #{ASFLAGS} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    end
  end

end

namespace :release do

  desc "Generates the flash image from ELF format"
  task :image => :link do |task|
    sh "#{HEX} build/#{RELEASE_DIR}/#{PROJECT[:name]}.elf build/#{RELEASE_DIR}/#{PROJECT[:name]}.hex"
  end

  desc "Link the object files"
  task :link => OBJ_RELEASE_HASH.keys do |task|
    obj = OBJ_RELEASE_HASH.keys.join(' ')
    sh "#{CC} #{obj} #{LDFLAGS_rlse} -o build/#{RELEASE_DIR}/#{PROJECT[:name]}.elf"
    sh "#{SZ} build/#{RELEASE_DIR}/#{PROJECT[:name]}.elf"
  end

  rule %r{\/release\/obj\/\w+\.o} => get_src_path_rlse do |task|
    mkdir_p File.dirname(task.name)
    if File.extname(task.source) == '.c'
      sh "#{CC} -c #{CFLAGS} #{task.source} -o #{task.name}"
    elsif File.extname(task.source) == '.s'
      sh "#{AS} -c #{ASFLAGS} #{task.source} -o #{task.name}"
    end
  end

  rule %r{/release/dep/\w+\.mf} => get_src_path_rlse do |task|
    mkdir_p File.dirname(task.name)
    obj_path = task.name.pathmap("build/release/obj/%n.o")
    if File.extname(task.source) == '.c'
      sh "#{CC} #{CFLAGS} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    elsif File.extname(task.source) == '.s'
      sh "#{AS} #{ASFLAGS} -MF #{task.name} -MM -MP -MG -MT #{task.name} -MT #{obj_path} #{task.source}"
    end
  end

end

# Declare an explict file task for each dependency file. This will
# use the rule defined to create .mf files defined earlier. This
# is necessary because it assures that the .mf file exists before
# importing then import each dependency file. If the file doesn't
# exist, then the file task to create it is invoked.
DEP_DEBUG_HASH.each_key do |dep|
  file dep 
  puts "importing #{dep}"
  import dep #dependency file is imported after the Rakefile is loaded, but before and tasks are run
end

DEP_RELEASE_HASH.each_key do |dep|
  file dep 
  puts "importing #{dep}"
  import dep
end

CLEAN.include(
  DEP_DEBUG_HASH.keys, 
  DEP_RELEASE_HASH.keys, 
  OBJ_DEBUG_HASH.keys, 
  OBJ_RELEASE_HASH.keys, 
  "build/#{DEBUG_DIR}/#{PROJECT[:name]}.*", 
  "build/#{RELEASE_DIR}/#{PROJECT[:name]}.*"
)