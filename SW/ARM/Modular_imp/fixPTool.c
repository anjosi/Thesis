#include "fixPTool.h"
#include <stdio.h>
#include "signaling_macros.h"

#ifdef FTD_TEST_APP

#define W_LEN 16
#define F_LEN 14

int main()
{
  u8 sign;
  u32 test = 0x0000fffd;

  uFixed l_uFixed;
  ufixed ptr_uFixed = &l_uFixed;
  sFixed l_sFixed;
  sfixed ptr_sFixed = &l_sFixed;

  if(sFixedPointToDec(test, W_LEN, F_LEN, ptr_sFixed))
    ERROR_PRINT("Error in fixed to Dec convertion.");
  else
    printf("Test fraction %c%u.%s \n\r", l_sFixed.m_Sign, l_sFixed.m_Int, l_sFixed.m_Frac);


  if(uFixedPointToDec(test, W_LEN, F_LEN, ptr_sFixed))
    ERROR_PRINT("Error in fixed to Dec convertion.");
  else
    printf("Test fraction %u.%s \n\r", l_sFixed.m_Int, l_sFixed.m_Frac);





return 0;



}

#endif


s8 sFixedPointToDec(u32 p_Word, u8 p_Length, u8 p_FractionPortion, sfixed p_Fixed)
{
	s8 status = FTD_ERROR;
  //if fraction portion is longer than the word then somethig is wrong
  if(p_Length < p_FractionPortion)
    return status;
  else if (p_Length > 32)
    return status;
  else if(p_FractionPortion > 32)
    return status;
  else if(p_Length == 0)
    return status;

  u32 mask, frac_mask, low_mask, fix_word, temp;
  u8 l_Length;
  p_Fixed->m_Sign = VAL_POS;
  mask = 1 << (p_Length-1);
  fix_word = p_Word;


  l_Length = p_Length;
  if(p_Word&mask)
    {
      if((l_Length-p_FractionPortion) > 1)
	{
	  if(p_FractionPortion == 32)
	    {
	      frac_mask = 0;
	    }
	  else
	    {
	      frac_mask = ALL_SET_32;
	      frac_mask <<= p_FractionPortion;
	    }

	  low_mask = ALL_SET_32;
	  low_mask >>= 32-l_Length;
	  mask = frac_mask & low_mask;
	  fix_word = p_Word & mask;
	  fix_word >>= p_FractionPortion;

	  fix_word = ~fix_word;
	  fix_word++;

	  fix_word <<= p_FractionPortion;
	  fix_word &= mask;

	  frac_mask = ~frac_mask;
	  temp = p_Word & frac_mask;
	  temp = ~temp;
	  temp++;
	  temp &= frac_mask;

	  fix_word |= temp;


	}
      else
	{
	  fix_word = ~fix_word;
	  fix_word++;
	  if((l_Length-p_FractionPortion) == 1)
	    {
	      l_Length--;
	    }

	}

      p_Fixed->m_Sign = VAL_NEG;
    }

  status =  uFixedPointToDec(fix_word, l_Length, p_FractionPortion, p_Fixed);
  if(p_Fixed->m_Sign)
	  p_Fixed->m_Int--;
  return status;
}



s8 uFixedPointToDec(u32 p_Word, u8 p_Length, u8 p_FractionPortion, sfixed p_Fixed)
{

  //if fraction portion is longer than the word then somethig is wrong
  if(p_Length < p_FractionPortion)
    return FTD_ERROR;
  else if (p_Length > 32)
    return FTD_ERROR;
  else if(p_FractionPortion > 32)
    return FTD_ERROR;
  else if(p_Length == 0)
    return FTD_ERROR;

  s8 i, first;
  u32 bit_value,build_mask, mask, power = 1, frac_bits, frac_result = 0;

  if(p_FractionPortion == 32)
    mask = 0;
  else
    {
      mask = ALL_SET_32; //all set mask
      mask <<= p_FractionPortion; //shift the mask to cover only the integer portion
    }

  build_mask = ALL_SET_32; //all set build mask
  build_mask >>= 32-p_Length; //shift the build mask to the right so that we get wanted word length

  mask &= build_mask; //finalize the mask for integer portion

  p_Fixed->m_Int = p_Word; //set the integer portion
  p_Fixed->m_Int &= mask; //get the integer portion

  p_Fixed->m_Int >>= p_FractionPortion; //shift the integer portion down to its correct position


  frac_result = 0; //initialize the fracment portion to zero
  frac_bits =  p_Word; //get the org word
  mask = ~mask; //flip the mask to get the fraction portion
  mask &= build_mask; //remove the high bits
  frac_bits &= mask; //get the fraction portion

  mask = 1 << (p_FractionPortion-1);
  //iterate all the fraction bits
  first = 0;
  for(i = p_FractionPortion-1; i >= 0; i--)
    {
      power <<= 1; //increment the power
      if(power == 0)
	break;
      bit_value = (frac_bits&mask)>>i;
      if(first == 0 && bit_value == 1)
	first = p_FractionPortion-i;
      frac_result += (bit_value)*(SCALE/power); //calculate the fracment bit weigth
      mask >>= 1; //shift the mask to the next fraction bit
    }
  u8 digit = 0;
  u32 divider_dec = SCALE/10;
  for(i = 0; divider_dec > 0; i++)
    {
      digit = frac_result/divider_dec;
	p_Fixed->m_Frac[i] = 48 + digit;
	frac_result = frac_result - (digit * divider_dec);
	divider_dec /= 10;
    }
  p_Fixed->m_Frac[i] = '\0';



  return FTD_SUCCESS;

}

