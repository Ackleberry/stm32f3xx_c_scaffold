# Windows Instructions:

1. Install [Ruby](https://rubyinstaller.org/)

2. Install latest Ruby Rake gem:

    `gem install rake`

3. Install [Arm GCC](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads). Ensure the path to ..\9 2020-q2-update\bin is added to your PATH system environment variable.

4. Verify arm-none-eabi-gcc command is recognized:

    `arm-none-eabi-gcc --version`

5. Install [ST-LINK](https://github.com/stlink-org/stlink/releases/). Ensure the path to ..\stlink-1.6.1-x86_64-w64-mingw32\bin is added to your PATH system environment variable.

6. Verify st-flash command is recognized:

    `st-flash --version`

## List All Tasks:

`rake --tasks`



