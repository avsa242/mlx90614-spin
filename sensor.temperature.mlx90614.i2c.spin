{
    --------------------------------------------
    Filename: sensor.temperature.mlx90614.i2c.spin
    Author: Jesse Burt
    Description: Driver for the Melexis MLX90614 IR thermometer
    Copyright (c) 2020
    Started Mar 17, 2019
    Updated Dec 7, 2020
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

    i2c : "com.i2c"
    core: "core.con.mlx90614"
    time: "time"

PUB Null{}
' This is not a top-level object

PUB Start{}: okay
' Start using "standard" Propeller I2C pins and 100kHz
    okay := startx(DEF_SCL, DEF_SDA, DEF_HZ)

PUB Startx(SCL_PIN, SDA_PIN, I2C_HZ): okay
' Start using custom settings
    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if okay := i2c.setupx(SCL_PIN, SDA_PIN, I2C_HZ)
                time.msleep(1)
                if i2c.present(SLAVE_WR)        ' test bus device presence
                    if deviceid{}
                        time.usleep(core#TPOR)
                        return okay

    return FALSE                                ' something above failed

PUB Stop{}

    i2c.terminate{}

PUB AmbientTemp{}: temp
' Reads the Ambient temperature
'   Returns: Calculated temperature in centidegrees (e.g., 2135 is 21.35 deg), using the chosen scale
    readreg(core#CMD_RAM, core#T_A, 2, @temp)

    temp &= $FFFF

    case _temp_scale
        C:                                  ' Result will be in centidegrees Celsius
            temp := (temp * 2) - 273_15
        F:                                  ' Result will be in centidegrees Fahrenheit
            temp := ((temp * 2) - 273_15) * 9_00/5_00 + 32_00
        K:                                  ' Result will be in centidegrees Kelvin
            temp := temp * 2
        other:
            return

    return

PUB DeviceID{}: id
' Reads the sensor ID
    readreg(core#CMD_EEPROM, core#EE_ID_1, 4, @id)

PUB EEPROM(ptr_buff)
' Dump EEPROM to array at ptr_buff
'   NOTE: ptr_buff must be at least 64 bytes
    readreg(core#CMD_EEPROM, $00, 64, ptr_buff)

PUB ObjTemp(channel): temp
' Reads the Object temperature (IR temp)
'   channel
'       Valid values: 1, 2 (CH2 availability is device-dependent)
'       Any other value is ignored
'   Returns: Calculated temperature in centidegrees (e.g., 2135 is 21.35 deg), using the chosen scale
    case channel
        1:
            readreg(core#CMD_RAM, core#T_OBJ1, 2, @temp)
        2:
            readreg(core#CMD_RAM, core#T_OBJ2, 2, @temp)
        other:
            return

    temp &= $FFFF

    case _temp_scale
        C:                                  ' Result will be in centidegrees Celsius
            temp := (temp * 2) - 273_15
        F:                                  ' Result will be in centidegrees Fahrenheit
            temp := ((temp * 2) - 273_15) * 9_00/5_00 + 32_00
        K:                                  ' Result will be in centidegrees Kelvin
            temp := temp * 2
        other:
            return

    return

PUB TempScale(scale): curr_scl
' Set scale of temperature data returned by AmbientTemp and ObjTemp methods
'   Valid values:
'      *C (0): Celsius
'       F (1): Fahrenheit
'       K (2): Kelvin
'   Any other value returns the current setting
    case scale
        C, F, K:
            _temp_scale := scale
            return _temp_scale
        other:
            return _temp_scale

PRI readReg(region, reg, nr_bytes, ptr_buff) | cmd_pkt
' Read nr_bytes from device into ptr_buff
    case region
        core#CMD_RAM:
        core#CMD_EEPROM:
        core#CMD_READFLAGS:
        other:
            return

    cmd_pkt.byte[0] := SLAVE_WR
    cmd_pkt.byte[1] := region | reg

    i2c.start{}
    i2c.wr_block(@cmd_pkt, 2)
    i2c.start{}
    i2c.write(SLAVE_RD)
    i2c.rd_block(ptr_buff, nr_bytes, TRUE)
    i2c.stop{}

PRI writreg(region, reg, nr_bytes, val) | cmd_pkt[2]
' Write nr_bytes from val to device
    case region
        core#CMD_EEPROM:
        core#CMD_SLEEPMODE:
        other:
            return

    cmd_pkt.byte[0] := SLAVE_WR
    cmd_pkt.byte[1] := region | reg
    cmd_pkt.byte[2] := val.byte[LSB]
    cmd_pkt.byte[3] := val.byte[MSB]
    cmd_pkt.byte[4] := val.byte[PEC]

    i2c.start{}
    i2c.wr_block(@cmd_pkt, 2 + nr_bytes)
    i2c.stop{}

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
