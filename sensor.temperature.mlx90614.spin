{
    --------------------------------------------
    Filename: sensor.temperature.mlx90614.spin
    Author: Jesse Burt
    Description: Driver for the Melexis MLX90614 IR thermometer
    Copyright (c) 2022
    Started Mar 17, 2019
    Updated Dec 27, 2022
    See end of file for terms of use.
    --------------------------------------------
}
{ pull in methods common to all Temp drivers }
#include "sensor.temp.common.spinh"

CON

    { I2C }
    SLAVE_WR    = core#SLAVE_ADDR
    SLAVE_RD    = core#SLAVE_ADDR | 1
    DEF_SCL     = 28
    DEF_SDA     = 29
    DEF_HZ      = 100_000

    MSB         = 0
    LSB         = 1
    PEC         = 2

OBJ

{ decide: Bytecode I2C engine, or PASM? Default is PASM if BC isn't specified }
#ifdef MLX90614_I2C_BC
    i2c : "com.i2c.nocog"                       ' BC I2C engine
#else
    i2c : "com.i2c"                             ' PASM I2C engine
#endif
    core: "core.con.mlx90614"                   ' HW-specific constants
    time: "time"                                ' timekeeping methods

VAR

    byte _temp_ch                               ' temp. sensor channel #

PUB null{}
' This is not a top-level object

PUB start{}: status
' Start using "standard" Propeller I2C pins and 100kHz
    return startx(DEF_SCL, DEF_SDA, DEF_HZ)

PUB startx(SCL_PIN, SDA_PIN, I2C_HZ): status
' Start using custom settings
    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) and {
}   I2C_HZ =< core#I2C_MAX_FREQ
        if (status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ))
            time.usleep(core#T_POR)
            if (dev_id{})
                return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE

PUB stop{}
' Stop the driver
    i2c.deinit{}
    _temp_ch := 0

PUB amb_temp_data{}: temp_adc
' Read ambient temperature ADC data
'   Returns: s16
    temp_adc := 0
    readreg(core#CMD_RAM, core#T_A, 2, @temp_adc)

PUB amb_temp{}: temp
' Reads the Ambient temperature
'   Returns: Temperature in hundredths of a degree (e.g., 2135 is 21.35 deg),
'       using the chosen scale
    return temp_word2deg(amb_temp_data{})

PUB dev_id{}: id
' Reads the sensor ID
    id := 0
    readreg(core#CMD_EEPROM, core#EE_ID_1, 4, @id)

PUB rd_eeprom(ptr_buff)
' Dump EEPROM to array at ptr_buff
'   NOTE: ptr_buff must be at least 64 bytes
    readreg(core#CMD_EEPROM, $00, 64, ptr_buff)

PUB set_temp_channel(ch)
' Set temperature sensor channel #
'   Valid values: 1, 2 (CH2 availability is device-dependent)
    _temp_ch := ((1 #> ch <# 2) - 1)

PUB temp_channel{}: curr_ch
' Get temperature sensor currently set channel #
    return (_temp_ch + 1)

PUB temp_data{}: temp_word
' Read object temperature ADC word
'   Returns: s16
    temp_word := 0
    readreg(core#CMD_RAM, (core#T_OBJ1 + _temp_ch), 3, @temp_word)
    return (temp_word & $ffff)

PUB temp_word2deg(temp_word): temp
' Convert temperature ADC word to temperature
'   Returns: temperature, in hundredths of a degree, in chosen scale
    temp_word *= 2
    case _temp_scale
        C:
            return temp_word - 273_15
        F:
            return (((temp_word - 273_15) * 9_00) / 5_00) + 32_00
        K:
            return
        other:
            return FALSE

PRI readreg(region, reg_nr, nr_bytes, ptr_buff) | cmd_pkt
' Read nr_bytes from device into ptr_buff
    case region
        core#CMD_RAM:
        core#CMD_EEPROM:
        core#CMD_READFLAGS:
        other:
            return

    cmd_pkt.byte[0] := SLAVE_WR
    cmd_pkt.byte[1] := region | reg_nr

    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 2)
    i2c.start{}
    i2c.write(SLAVE_RD)
    i2c.rdblock_lsbf(ptr_buff, nr_bytes, i2c#NAK)
    i2c.stop{}

PRI writereg(region, reg_nr, nr_bytes, val) | cmd_pkt[2]
' Write nr_bytes from val to device
    case region
        core#CMD_EEPROM:
        core#CMD_SLEEPMODE:
        other:
            return

    cmd_pkt.byte[0] := SLAVE_WR
    cmd_pkt.byte[1] := region | reg_nr
    cmd_pkt.byte[2] := val.byte[LSB]
    cmd_pkt.byte[3] := val.byte[MSB]
    cmd_pkt.byte[4] := val.byte[PEC]

    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, 2 + nr_bytes)
    i2c.stop{}

DAT
{
Copyright 2022 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

