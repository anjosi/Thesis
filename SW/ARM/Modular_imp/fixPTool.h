/*
 * fixPTool.h
 *
 *  Created on: 21.1.2015
 *      Author: Antti
 */

#ifndef FIXPTOOL_H_
#define FIXPTOOL_H_

#include "xil_types.h"

#define ALL_SET_32 0xFFFFFFFF//4294967295
#define HIGH_BIT_SET_32 0x80000000 //2147483648
#define SCALE 1000000000
#define FTD_ERROR -1
#define FTD_SUCCESS 0

#define VAL_NEG 45
#define VAL_POS 0

//#define FTD_TEST_APP


typedef struct sstr_Fix
{
  u32 m_Int;
  char m_Frac[11];
  u8 m_Sign;
} sFixed, *sfixed;

typedef struct ustr_Fix
{
  u32 m_Int;
  u32 m_Frac;
} uFixed, *ufixed;

s8 sFixedPointToDec(u32 p_Word, u8 p_Length, u8 p_FractionPortion, sfixed p_Fixed);
s8 uFixedPointToDec(u32 p_Word, u8 p_Length, u8 p_fractionPortion, sfixed p_Fixed);


#endif /* FIXPTOOL_H_ */
