{
    --------------------------------------------
    Filename: sensor.temperature.mlx90614.i2c.spin
    Author: Jesse Burt
    Description: Driver for the Melexis MLX90614 IR thermometer
    Copyright (c) 2020
    Started Mar 17, 2019
    Updated Mar 5, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SLAVE_WR        = core#SLAVE_ADDR
    SLAVE_RD        = core#SLAVE_ADDR|1

    DEF_SCL         = 28
    DEF_SDA         = 29
    DEF_HZ          = 100_000
    I2C_MAX_FREQ    = core#I2C_MAX_FREQ

    MSB             = 0
    LSB             = 1
    PEC             = 2

' Temperature scales
    C               = 0
    F               = 1
    K               = 2

VAR

    byte _temp_scale

OBJ

    i2c : "com.i2c"                                             'PASM I2C Driver
    core: "core.con.mlx90614"
    time: "time"                                                'Basic timing functions

PUB Null
''This is not a top-level object

PUB Start: okay                                                 'Default to "standard" Propeller I2C pins and 100kHz

    okay := Startx (DEF_SCL, DEF_SDA, DEF_HZ)

PUB Startx(SCL_PIN, SDA_PIN, I2C_HZ): okay

    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if okay := i2c.setupx (SCL_PIN, SDA_PIN, I2C_HZ)    'I2C Object Started?
                time.MSleep (1)
                if i2c.present (SLAVE_WR)                       'Response from device?
                    if DeviceID
                        time.MSleep (250)                       'First data available approx 250ms after POR
                        return okay

    return FALSE                                                'If we got here, something went wrong

PUB Stop

    i2c.terminate

PUB AmbientTemp | tmp
' Reads the Ambient temperature
'   Returns: Calculated temperature in centidegrees (e.g., 2135 is 21.35 deg), using the chosen scale
    readReg(core#CMD_RAM, core#T_A, 3, @result)

    tmp := result.byte[PEC]
    result &= $FFFF

    case _temp_scale
        C:                                  ' Result will be in centidegrees Celsius
            result := (result * 2) - 273_15
        F:                                  ' Result will be in centidegrees Fahrenheit
            result := ((result * 2) - 273_15) * 9_00/5_00 + 32_00
        K:                                  ' Result will be in centidegrees Kelvin
            result := result * 2
        OTHER:
            return

    return

PUB DeviceID
' Reads the sensor ID
    readReg(core#CMD_EEPROM, core#EE_ID_1, 4, @result)

PUB EEPROM(addr) | tmp
' Dump EEPROM to array at addr
    readReg(core#CMD_EEPROM, $00, 64, addr)

PUB ObjTemp(channel) | tmp
' Reads the Object temperature (IR temp)
'   channel
'       Valid values: 1, 2 (CH2 availability is device-dependent)
'       Any other value is ignored
'   Returns: Calculated temperature in centidegrees (e.g., 2135 is 21.35 deg), using the chosen scale
    case channel
        1:
            readReg(core#CMD_RAM, core#T_OBJ1, 3, @result)
        2:
            readReg(core#CMD_RAM, core#T_OBJ2, 3, @result)
        OTHER:
            return

    tmp := result.byte[PEC]
    result &= $FFFF

    case _temp_scale
        C:                                  ' Result will be in centidegrees Celsius
            result := (result * 2) - 273_15
        F:                                  ' Result will be in centidegrees Fahrenheit
            result := ((result * 2) - 273_15) * 9_00/5_00 + 32_00
        K:                                  ' Result will be in centidegrees Kelvin
            result := result * 2
        OTHER:
            return

    return

PUB Scale(temp_scale)
' Set scale of temperature data returned by AmbientTemp and ObjTemp methods
'   Valid values:
'      *C (0): Celsius
'       F (1): Fahrenheit
'       K (2): Kelvin
'   Any other value returns the current setting
    case temp_scale
        C, F, K:
            _temp_scale := temp_scale
            return _temp_scale
        OTHER:
            return _temp_scale

PRI readReg(region, reg, nr_bytes, addr_buff) | cmd_packet
' Reads bytes from device register in selected memory region

    cmd_packet.byte[0] := SLAVE_WR

    case region
        core#CMD_RAM:
        core#CMD_EEPROM:
        core#CMD_READFLAGS:
        OTHER:
            return

    cmd_packet.byte[1] := region | reg

    i2c.start
    i2c.wr_block (@cmd_packet, 2)
    i2c.start
    i2c.write (SLAVE_RD)
    i2c.rd_block (addr_buff, nr_bytes, TRUE)
    i2c.stop

PRI writeReg(region, reg, nr_bytes, val) | cmd_packet[2]
' Writes bytes to device register in selected memory region
    cmd_packet.byte[0] := SLAVE_WR

    case region
        core#CMD_EEPROM:
        core#CMD_SLEEPMODE:
        OTHER:
            return

    cmd_packet.byte[1] := region | reg
    cmd_packet.byte[2] := val.byte[LSB]
    cmd_packet.byte[3] := val.byte[MSB]
    cmd_packet.byte[4] := val.byte[PEC]

    i2c.start
    i2c.wr_block (@cmd_packet, 2 + nr_bytes)
    i2c.stop

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
