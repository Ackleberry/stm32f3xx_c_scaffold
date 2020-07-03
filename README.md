# Getting Started

## Windows Setup Instructions:

1. Install [Ruby](https://rubyinstaller.org/)

2. Install latest Ruby Rake gem:

    `gem install rake`

3. Install [Arm GCC](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads). Ensure the path to `arm-none-eabi-gcc.exe` is added to your PATH system environment variable.

4. Verify arm-none-eabi-gcc command is recognized in command prompt:

    `arm-none-eabi-gcc --version`

5. Install [ST-LINK](https://github.com/stlink-org/stlink/releases/). Ensure the path to `st-flash.exe` is added to your PATH system environment variable.

6. Verify st-flash command is recognized in command prompt:

    `st-flash --version`

## OSX

    TBD

## Linux

    TBD


# List All Tasks:

    `rake --tasks`

# Example:

Build debug HEX image:

    `rake debug:hex`

Flash debug HEX image to target:

    `rake stlink:flash:debug`

# Porting Scaffold to Other STM32Fx Targets

While STM32F303RE is the defaulted target, you can use STMCubeMX to generage code for any other STM32Fx device. See the `.ioc` project file in the repository. After generating code with STMCubeMX, refer to the table below to copy the variable content from the generated Makefile to the variable in the Rakefile.

| Makefile | Rakefile |
|-|-|
| C_SOURCES | SOURCES |
| ASM_SOURCES | SOURCES |
| C_INCLUDES | INCLUDES |
| C_DEFS | DEFINES |
| MCU | TARGET[:mcu_args] |
| FPU | TARGET[:mcu_args] |
| FLOAT-ABI | TARGET[:mcu_args] |
| LDSCRIPT | TARGET[:ld_script] |

Once the Rakefile works you can remove the Makefile from the project.

# Licensing:

Please note this projects LICENSE does not cover:

* Anything in the `drivers` folder.
* Any code generated by STMCubeMX.

Please refer to the specific licensing of that project/driver/module.

# Acknowledgements:

ADVI.CODES - [Rake Tutorials](https://avdi.codes/tag/rake)

ElectronVector - [blog-rake-gcc-depends](https://github.com/ElectronVector/blog-rake-gcc-depends)

ThrowTheSwitch - [arduino_c_scaffold](https://github.com/ThrowTheSwitch/arduino_c_scaffold)







