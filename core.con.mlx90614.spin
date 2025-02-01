{
----------------------------------------------------------------------------------------------------
    Filename:       core.con.mlx90614.spin
    Description:    MLX90614-specific constants
    Author:         Jesse Burt
    Started:        Mar 17, 2019
    Updated:        Feb 1, 2025
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    I2C_MAX_FREQ            = 100_000
    I2C_MIN_FREQ            = 10_000
    SLAVE_ADDR              = $5A << 1

    T_POR                   = 250_000           ' usec
    T_ERASE                 = 5_000             ' EE erase cell
    T_WRITE                 = 5_000             ' EE write cell
    T_ERASE_MAX             = 10_000            ' safer values of the above
    T_WRITE_MAX             = 10_000            '


' Commands
    CMD_RAM                 = $00
    CMD_EEPROM              = $20
    CMD_READFLAGS           = $F0
    CMD_SLEEPMODE           = $FF

' Registers
'   EEPROM
    EE_FLAGS_MASK           = $00B0
        EEBUSY              = 7
        EE_DEAD             = 5
        INIT                = 4

    EE_TO_MAX               = CMD_EEPROM | $00

    EE_TO_MIN               = CMD_EEPROM | $01

    EE_PWMCTRL              = CMD_EEPROM | $02
        PWM_PERIOD          = 9
        PWM_REPNUM          = 4
        TRPWMB              = 3
        PPODB               = 2
        EN_PWM              = 1
        PWM_EXT_MODE        = 0
        PWM_PERIOD_BITS     = %1111111
        PWM_REPNUM_BITS     = %11111

    EE_TA_RANGE             = CMD_EEPROM | $03

    EE_EMISS_CORR           = CMD_EEPROM | $04

    EE_CFG                  = CMD_EEPROM | $05
    EE_CFG_MASK             = $FFFF
    EE_CFG_RECOMMEND_MASK   = $8777 ' Help keep from altering bits 14..11, 7, 3, per Melexis Datasheet
        SENSOR_TST          = 15
        K12                 = 14
        GAIN                = 11
        FIR                 = 8
        KS_SIGN             = 7
        IR_ZONES            = 6
        TA_TOBJ             = 4
        REPEAT_SENS_TST     = 3
        IIR                 = 0
        GAIN_BITS           = %111
        FIR_BITS            = %111
        TA_TOBJ_BITS        = %11
        IIR_BITS            = %111
        SENSOR_TST_MASK     = (1 << SENSOR_TST) ^ EE_CFG_MASK
        K12_MASK            = (1 << K12) ^ EE_CFG_MASK
        GAIN_MASK           = (GAIN_BITS << GAIN) ^ EE_CFG_MASK
        FIR_MASK            = (FIR_BITS << FIR) ^ EE_CFG_MASK
        KS_SIGN_MASK        = (1 << KS_SIGN) ^ EE_CFG_MASK
        IR_ZONES_MASK       = (1 << IR_ZONES) ^ EE_CFG_MASK
        TA_TOBJ_MASK        = (TA_TOBJ_BITS << TA_TOBJ) ^ EE_CFG_MASK
        REPEAT_SENS_TST_MASK= (1 << REPEAT_SENS_TST) ^ EE_CFG_MASK
        IIR_MASK            = IIR_BITS ^ EE_CFG_MASK

    EE_MLX_SLAVEADDR        = CMD_EEPROM | $0E

    EE_ID_1                 = CMD_EEPROM | $1C
    EE_ID_2                 = CMD_EEPROM | $1D
    EE_ID_3                 = CMD_EEPROM | $1E
    EE_ID_4                 = CMD_EEPROM | $1F

'   RAM
    IR_CH_1                 = CMD_RAM | $03
    IR_CH_2                 = CMD_RAM | $05
    T_A                     = CMD_RAM | $06
    T_OBJ1                  = CMD_RAM | $07
    T_OBJ2                  = CMD_RAM | $08


PUB null()
' This is not a top-level object


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

