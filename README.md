# Teensy 4.0 Bare-Metal C++ Example

This is a bare-metal example for the [Teensy](https://www.pjrc.com/teensy/) 4.0 board. It's intended to be used with the free GCC ARM toolchain.

It contains support for C++17 STL and fast assmebly implementations of essential `memset()` and `memcpy()` functions.

The generated HEX file is compatible with the [Teensy Loader](https://www.pjrc.com/teensy/loader.html).

# Build Instructions (macOS)

1. Install the ARM GCC Toolchain for Embedded Processors
```
brew tap ArmMbed/homebrew-formulae
brew install arm-none-eabi-gcc
```

2. Compile the source
```
make
````

3. Flash the binary
```
make flash
```

# Build Instructions (linux)

1. Install the ARM GCC Toolchain for Embedded Processors

Fedora or RHL-based Distro
```
sudo dnf install arm-none-eabi-gcc
```
Ubuntu or Debian-based Distro
```
sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi
```

2. Compile the source
```
make
```

3. Flash the binary
```
make flash
```

# Credits

Linker files and startup code are based on the [Teensy Core Libraries for Arduino](https://github.com/PaulStoffregen/cores) by Paul Stoffregen.


