# mlx90614-spin 
---------------

This is a P8X32A/Propeller 1, P2X8C4M64P/Propeller 2 driver object for the Melexis MLX90614 IR thermometer

## Salient Features

* Operates at up to 100kHz
* Reads IR channels 1 and 2 (availability dependent on device package)
* Reads ambient temperature sensor
* Returns temperature in centi-degrees (hundreths) Kelvin, Celsius or Fahrenheit

## Requirements

* Requires 1 extra core/cog for the PASM I2C driver (spin1)
* N/A (spin2)

## Compiler compatibility

* FastSpin (tested with 4.0.3-beta)

## Limitations

* Doesn't support changing the device's slave address
* Doesn't support PWM mode (unplanned)
* Early in development - may malfunction or outright fail to build

## TODO

* Support alternate slave addresses
