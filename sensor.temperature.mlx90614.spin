{
----------------------------------------------------------------------------------------------------
    Filename:       sensor.temperature.mlx90614.spin
    Description:    Driver for the Melexis MLX90614 IR thermometer
    Author:         Jesse Burt
    Started:        Mar 17, 2019
    Updated:        Feb 1, 2025
    Copyright (c) 2025 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

#include "sensor.temp.common.spinh"             ' use code common to all temperature sensor drivers

CON

    { default I/O settings; these can be overridden in the parent object }
    SCL         = 28
    SDA         = 29
    I2C_FREQ    = 100_000
    I2C_ADDR    = 0

    SLAVE_WR    = core.SLAVE_ADDR
    SLAVE_RD    = core.SLAVE_ADDR | 1

    MSB         = 0
    LSB         = 1
    PEC         = 2


OBJ

{ decide: Bytecode I2C engine, or PASM? Default is PASM if BC isn't specified }
#ifdef MLX90614_I2C_BC
    i2c:    "com.i2c.nocog"                     ' BC I2C engine
#else
    i2c:    "com.i2c"                           ' PASM I2C engine
#endif
    core:   "core.con.mlx90614"                 ' HW-specific constants
    time:   "time"                              ' timekeeping methods
    crc:    "math.crc"                          ' CRC routines


VAR

    byte _temp_ch                               ' temp. sensor channel #


PUB null()
' This is not a top-level object


PUB start(): status
' Start using default I/O settings
    return startx(SCL, SDA, I2C_FREQ)


PUB startx(SCL_PIN, SDA_PIN, I2C_HZ): status
' Start the driver with custom I/O settings
'   SCL_PIN:    I2C clock, 0..31
'   SDA_PIN:    I2C data, 0..31
'   I2C_HZ:     I2C clock speed (max official specification is 400_000 but is unenforced)
'   Returns:
'       cog ID+1 of I2C engine on success (= calling cog ID+1, if the bytecode I2C engine is used)
'       0 on failure
    if ( lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31) )
        if ( status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ) )
            time.usleep(core.T_POR)
            if ( dev_id() )
                return
    ' if this point is reached, something above failed
    ' Double check I/O pin assignments, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE


PUB stop()
' Stop the driver
    i2c.deinit()
    _temp_ch := 0


PUB amb_temp_data(): a
' Read ambient temperature ADC data
'   Returns: s16
    return readreg(core.T_A)


PUB amb_temp(): t
' Reads the Ambient temperature
'   Returns: Temperature in hundredths of a degree (e.g., 2135 is 21.35 deg),
'       using the chosen scale
    return temp_word2deg( amb_temp_data() )


PUB dev_id(): id
' Reads the sensor ID

    ' the high byte at this EE address might contain garbage so discard it; we only want the
    '   lower byte
    return ( readreg(core.EE_MLX_SLAVEADDR) & $ff )


PUB rd_eeprom(p_buff) | r
' Dump EEPROM to array at p_buff
'   NOTE: p_buff must be at least 32 words
    repeat r from $00 to $1f
        word[p_buff][r] := readreg(r)


PUB serial_num(p_sn) | n
' Read serial number from sensor
'   p_sn:   pointer to buffer to copy serial number to (must be at least 4 words in size)
    repeat n from 0 to 3
        word[p_sn][n] := readreg(core.EE_ID_1+n)


PUB set_temp_channel(ch)
' Set temperature sensor channel #
'   Valid values: 1, 2 (CH2 availability is device-dependent)
    _temp_ch := ((1 #> ch <# 2) - 1)


PUB temp_channel(): curr_ch
' Get temperature sensor currently set channel #
    return (_temp_ch + 1)


PUB temp_data(): w
' Read object temperature ADC word
'   Returns: s16
    return (readreg( (core.T_OBJ1 + _temp_ch) ) & $ffff)


PUB temp_word2deg(w): d
' Convert temperature ADC word to temperature
'   Returns: temperature, in hundredths of a degree, in chosen scale
    w *= 2
    case _temp_scale
        C:
            return w - 273_15
        F:
            return (((w - 273_15) * 9_00) / 5_00) + 32_00
        K:
            return
        other:
            return FALSE


PRI readreg(reg_nr): v | cmd_pkt, rd, tmp[2]
' Read word(s) from device into p_buff
    cmd_pkt.byte[0] := SLAVE_WR
    cmd_pkt.byte[1] := reg_nr

    rd := 0
    i2c.start()
    i2c.wrblock_lsbf(@cmd_pkt, 2)
    i2c.start()
    i2c.write(SLAVE_RD)
    i2c.rdblock_lsbf(@rd, 3, i2c.NAK)           ' read word plus the PEC
    i2c.stop()

    ' the CRC from the sensor incorporates the command sent as well the data it sent back
    tmp.byte[0] := cmd_pkt.byte[0]
    tmp.byte[1] := cmd_pkt.byte[1]
    tmp.byte[2] := SLAVE_RD
    tmp.byte[3] := rd.byte[0]
    tmp.byte[4] := rd.byte[1]

    ' compare it to our own check and if it matches, return the data
    if ( crc.crc8(  @tmp, 5, ...
                    $00, $00, ...               ' initial value = $00, xor final CRC with $00
                    crc.POLY8_MELEXIS, ...
                    0, 0 ) == rd.byte[2])       ' input, output reflect = false
        return rd.word[0]
    else
        return -1                               ' error: bad CRC


PRI write_eeprom(reg_nr, val) | cmd_pkt[2]
' Write value to sensor EEPROM
'   reg_nr: sensor EEPROM register/address
'   val:    value to write
    cmd_pkt.byte[0] := SLAVE_WR
    cmd_pkt.byte[1] := reg_nr
    cmd_pkt.byte[2] := 0
    cmd_pkt.byte[3] := 0
    cmd_pkt.byte[4] := crc.crc8(@cmd_pkt, 4, ...' check the previous four bytes
                                $00, $00, ...
                                crc.POLY8_MELEXIS, ...
                                0, 0)

    ' erase the cell
    i2c.start()
    i2c.wrblock_lsbf(@cmd_pkt, 5)
    i2c.stop()
    time.usleep(core.T_ERASE_MAX)               ' wait for the EE to finish


    cmd_pkt.byte[2] := val.byte[0]              ' update the cmd packet with the new value
    cmd_pkt.byte[3] := val.byte[1]              '   and CRC
    cmd_pkt.byte[4] := crc.crc8(@cmd_pkt, 4, ...
                                $00, $00, ...
                                crc.POLY8_MELEXIS, ...
                                0, 0)

    ' now write the new value
    i2c.start()
    i2c.wrblock_lsbf(@cmd_pkt, 5)
    i2c.stop()
    time.usleep(core.T_WRITE_MAX)


DAT
{
Copyright 2025 Jesse Burt

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

