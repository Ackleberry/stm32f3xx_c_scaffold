require 'rake/clean'
require 'rake/loaders/makefile'

PREFIX = 'arm-none-eabi-'
TARGET = {
  name: 'stm32f3xx_c_scaffold',
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

task default: 'debug:hex'

# Tasks can be found in /rakelib
