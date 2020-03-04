{
    --------------------------------------------
    Filename: MLX90614-Demo.spin
    Author: Jesse Burt
    Description: Demo for the MLX90614 driver
    Copyright (c) 2020
    Started Mar 17, 2019
    Updated Mar 4, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

    LED         = cfg#LED1
    SER_RX      = 31
    SER_TX      = 30
    SER_BAUD    = 115_200

    I2C_SCL     = 28
    I2C_SDA     = 29
    I2C_HZ      = 100_000

    K           = 0
    C           = 1
    F           = 2

    TEMP_SCALE  = C

OBJ

    cfg     : "core.con.boardcfg.flip"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    io      : "io"
    mlx     : "sensor.temperature.mlx90614.i2c"
    int     : "string.integer"

VAR

    byte _ser_cog

PUB Main | Tobj, Tamb

    Setup

    repeat
        Tobj := mlx.ObjTemp (1, TEMP_SCALE)
        Tamb := mlx.AmbientTemp (TEMP_SCALE)

        ser.Position (0, 5)
        ser.str(string("Tobj: "))
        Decimal(Tobj, 100)
        ser.Newline

        ser.str(string("Ta: "))
        Decimal(Tamb, 100)

        time.MSleep (100)

PUB Decimal(scaled, divisor) | whole[4], part[4], places, tmp
' Display a fixed-point scaled up number in decimal-dot notation - scale it back down by divisor
'   e.g., Decimal (314159, 100000) would display 3.14159 on the termainl
'   scaled: Fixed-point scaled up number
'   divisor: Divide scaled-up number by this amount
    whole := scaled / divisor
    tmp := divisor
    places := 0

    repeat
        tmp /= 10
        places++
    until tmp == 1
    part := int.DecZeroed(||(scaled // divisor), places)

    ser.Dec (whole)
    ser.Char (".")
    ser.Str (part)

PUB Setup

    repeat until _ser_cog := ser.StartRXTX (SER_RX, SER_TX, 0, SER_BAUD)
    time.Sleep(30)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#CR, ser#LF))
    if mlx.Start
        ser.Str (string("MLX90614 driver started", ser#CR, ser#LF))
    else
        ser.Str (string("MLX90614 driver failed to start - halting", ser#CR, ser#LF))
        mlx.Stop
        time.MSleep (30)
        ser.Stop
        FlashLED(LED, 500)

#include "lib.utility.spin"

DAT
{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
