# mlx90614-spin 
---------------

This is a P8X32A/Propeller 1, P2X8C4M64P/Propeller 2 driver object for the Melexis MLX90614 IR thermometer

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* I2C connection at up to 100kHz
* Reads IR channels 1 and 2 (ch2 availability dependent on device package)
* Reads ambient temperature sensor
* Returns temperature in centi-degrees (hundredths) Kelvin, Celsius or Fahrenheit

## Requirements

P1/SPIN1:
* spin-standard-library
* 1 extra core/cog for the PASM I2C engine (none if the bytecode-based engine is used)
* sensor.temp.common.spinh (source: spin-standard-library)

P2/SPIN2:
* p2-spin-standard-library
* sensor.temp.common.spin2h (source: p2-spin-standard-library)

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Bytecode    | OK                    |
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Native code | OK                    |
| P1        | SPIN1    | OpenSpin (1.00.81)     | Bytecode    | Untested (deprecated) |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | NuCode      | FTBFS                 |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | Native code | OK                    |
| P1        | SPIN1    | Brad's Spin Tool (any) | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | Propeller Tool (any)   | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | PNut (any)             | Bytecode    | Unsupported           |

## Limitations

* Doesn't support changing the device's slave address
* Doesn't support PWM mode (unplanned)

