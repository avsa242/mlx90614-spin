# mlx90614-spin 
---------------

This is a P8X32A/Propeller 1, P2X8C4M64P/Propeller 2 driver object for the Melexis MLX90614 IR thermometer

## Salient Features

* I2C connection at up to 100kHz
* Reads IR channels 1 and 2 (availability dependent on device package)
* Reads ambient temperature sensor
* Returns temperature in centi-degrees (hundreths) Kelvin, Celsius or Fahrenheit

## Requirements

* P1/SPIN1: 1 extra core/cog for the PASM I2C driver
* P2/SPIN2: N/A

## Compiler compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* P2/SPIN2: FastSpin (tested with 4.0.3-beta)

## Limitations

* Very early in development - may malfunction or outright fail to build
* Doesn't support changing the device's slave address
* Doesn't support PWM mode (unplanned)

## TODO

- [ ] Support alternate slave addresses
