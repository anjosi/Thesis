/*
 * main.c
 *
 *  Created on: 16.1.2015
 *      Author: Antti Siirilä
 */

#include "axis_driver.h"
#include "uart_0_protocol.h"
#include "signaling_macros.h"
#include "platform.h"
#include "fixPTool.h"
#include "zed_signaling.h"
#include "ECG_Unit.h"
//#include "write.c"

/************************** Constant Definitions *****************************/
#define MATLAB_MSG_LENGTH (MAX_DATA_BUFFER_SIZE * 6)


/************************** Variable Definitions *****************************/

/*
 * The following are declared globally so they are zeroed and so they are
 * easily accessible from a debugger
 */

XGpio Gpio; /* The Instance of the GPIO Driver */
XLlFifo g_RawSignal_tx;
XLlFifo g_NoiseFreeSignal_rx;
XLlFifo g_DiffSignal_rx;
u8 g_LedBlink;
static u8 p_RawSignalBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
static u8 g_DiffSigBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
static u8 g_NoiseFreeSigBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
#if SIM_PLOT == 1
	static u8 MatLabBuffer[MATLAB_MSG_LENGTH];
#endif
static u32 msgCount;
static sFixed txFixed;
static sFixed rxFixed;
static u16 testBuf[900];


/************************** Function Prototypes ******************************/

s8 toECG(u8 *p_Buf, u16 msg_length);
int idle(void);

/**************************************************************************/
/**
 *
 * Main function to call the uart_0_protocol's run-fucntion.
 *
 * @param	None
 *
 * @return	XST_SUCCESS if successful, XST_FAILURE if unsuccessful
 *
 * @note		None
 *
 **************************************************************************/

int main(void)
{
    init_platform();

	int i,Status;

	Status = XGpio_Initialize(&Gpio, GPIO_EXAMPLE_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	//set I/O direction to write
	XGpio_SetDataDirection(&Gpio, LED_CHANNEL, 0xfffffff8);

	//turn on the running led
	XGpio_DiscreteSet(&Gpio, LED_CHANNEL, LED_RUN);

	g_LedBlink = 0;

	//ECG_UNIT_Reg_SelfTest((u32)XPAR_ECG_UNIT_0_S00_AXI_BASEADDR);
	while(!(0x0002&XGpio_DiscreteRead(&Gpio, BUTTON_CHANNEL)));
#ifdef TEST
    u32 test = 0xfffd0000;
    sFixed l_Fixed;
  if(sFixedPointToDec(test, 32, 30, &l_Fixed))
      ERROR_PRINT("Error in fixed to Dec convertion.");
    else
    	TEST_PRINT("Testing the fixPTool | original fixed-point word: %u -> converted word %c%u.%s", (unsigned int)test, l_Fixed.m_Sign, (unsigned int)l_Fixed.m_Int, l_Fixed.m_Frac);
#endif

	INFO_PRINT("ECG program starts.");

	msgCount = 0;
	//init the buffers to zero
	//write the sync-token

	Status = initAxisDriver(&g_RawSignal_tx, XPAR_AXI_FIFO_2_DEVICE_ID);
	Status = initAxisDriver(&g_NoiseFreeSignal_rx, XPAR_AXI_FIFO_1_DEVICE_ID);
	Status = initAxisDriver(&g_DiffSignal_rx, XPAR_AXI_FIFO_0_DEVICE_ID);
	if(Status == XST_FAILURE)
	{
		ERROR_PRINT("Error in axis fifo initializations.");
		return 0;
	}


	//Status = axisSelftTest(&g_RawSignal_tx, &g_NoiseFreeSignal_rx, p_RawSignalBuffer, g_NoiseFreeSigBuffer, (MAX_DATA_BUFFER_SIZE * WORD_SIZE));
	//Status = axisSelftTest(&g_RawSignal_tx, &g_DiffSignal_rx, p_RawSignalBuffer, g_DiffSigBuffer, (MAX_DATA_BUFFER_SIZE * WORD_SIZE));

	if(Status == XST_FAILURE)
	{
		XGpio_DiscreteClear(&Gpio, LED_CHANNEL, LED_COMM_ARDU|LED_RUN);
		return 0;
	}
	else
		XGpio_DiscreteSet(&Gpio, LED_CHANNEL, LED_COMM_ARDU|LED_RUN);


	FT_FORWARD forward = &toECG;
	FT_IDLE l_Idle = &idle;


	/*
	 * Run the uart_0 protocol to receive data from ARDUINO
	 */
	Status = run(forward, l_Idle);


	//turn off the running LED
	XGpio_DiscreteClear(&Gpio, LED_CHANNEL, LED_COMM_ARDU|LED_RUN);

	//stop matlab
	for(i = 0; i < 700; i++ )
	{
		outbyte(0xf4);
		outbyte(0x44);
		outbyte(0x0);
		outbyte(0x0);
	}

	INFO_PRINT("ECG program terminates.");
	return XST_SUCCESS;
}

s8 toECG(u8 *p_Buf, u16 msg_length)
{
	u16 i, j;
	u16 *l_Buf = (u16 *)p_Buf;
	u32 tx_word, *tx_word_ptr = (u32 *)p_RawSignalBuffer;
	u32 *rx_word_ptr;
	rx_word_ptr = (u32 *)g_DiffSigBuffer;	//Assign a u32 pointer to the data stream

	//convert the 16bit ecg samples from ardu to 32bit fixed point samples of 32_21
	for(i=0;i<WORD_COUNT;i++)
	{
		tx_word = (u32)l_Buf[i];
		tx_word <<= 21;
		tx_word_ptr[i]=tx_word;

	}


	TxSend(&g_RawSignal_tx, p_RawSignalBuffer, (MAX_DATA_BUFFER_SIZE * WORD_SIZE));	//send the samples to PL (PS [--> FIR --> ECG -->] PS)
	while( !(XLlFifo_IsTxDone(&g_RawSignal_tx)))
	{
		//TEST_PRINT("sending...");
	}
/*
		sFixedPointToDec(ECG_UNIT_mReadReg((u32)XPAR_ECG_UNIT_0_S00_AXI_BASEADDR,ECG_UNIT_S00_AXI_SLV_REG2_OFFSET), 32, 16, &rxFixed);
		TEST_PRINT("%c%d.%s", rxFixed.m_Sign, rxFixed.m_Int, rxFixed.m_Frac);
		sFixedPointToDec(ECG_UNIT_mReadReg((u32)XPAR_ECG_UNIT_0_S00_AXI_BASEADDR,ECG_UNIT_S00_AXI_SLV_REG3_OFFSET), 32, 16, &rxFixed);
		TEST_PRINT("%c%d.%s", rxFixed.m_Sign, rxFixed.m_Int, rxFixed.m_Frac);
		sFixedPointToDec(ECG_UNIT_mReadReg((u32)XPAR_ECG_UNIT_0_S00_AXI_BASEADDR,ECG_UNIT_S00_AXI_SLV_REG4_OFFSET), 32, 16, &rxFixed);
		TEST_PRINT("%c%d.%s", rxFixed.m_Sign, rxFixed.m_Int, rxFixed.m_Frac);
*/

	i = 0;
	while((MAX_DATA_BUFFER_SIZE * WORD_SIZE) > (i +=	RxReceive(&g_DiffSignal_rx, &g_DiffSigBuffer[i])))	//receive the filtered samples form FIR
	{
		//TEST_PRINT("Received: %d", i);

	}
	i=0;
	while((MAX_DATA_BUFFER_SIZE * WORD_SIZE) > (i +=	RxReceive(&g_NoiseFreeSignal_rx, &g_NoiseFreeSigBuffer[i])))	//receive the filtered samples form FIR
	{
		//TEST_PRINT("Received: %d", i);

	}
	//TEST_PRINT("Received: %d", i);

/*
		for(i=29;i<32;i++)
		{
			sFixedPointToDec(tx_word_ptr[i], 32, 21, &txFixed);
			sFixedPointToDec(rx_word_ptr[i], 32, 16, &rxFixed);
			TEST_PRINT("%lu: tx_word is %c%d.%s --> rx_word is %c%d.%s", msgCount, txFixed.m_Sign, (int)txFixed.m_Int, txFixed.m_Frac, rxFixed.m_Sign, (int)rxFixed.m_Int, rxFixed.m_Frac);
		}
*/

	msgCount++;

	//testing block
#ifdef TEST
	rx_word_ptr = (u32 *)g_DiffSigBuffer;	//Assign a u32 pointer to the data stream
	//if((msgCount%64)==0)
		for(i=0;i<5;i++)
		{
			sFixedPointToDec(tx_word_ptr[i], 32, 21, &txFixed);
			sFixedPointToDec(rx_word_ptr[i], 32, 16, &rxFixed);
			if((int)rxFixed.m_Int > 1023 || (int)rxFixed.m_Int < -1024)
				TEST_PRINT("%lu: tx_word is %c%d.%s --> rx_word is %c%d.%s", msgCount, txFixed.m_Sign, (int)txFixed.m_Int, txFixed.m_Frac, rxFixed.m_Sign, (int)rxFixed.m_Int, rxFixed.m_Frac);
		}
	msgCount++;

#elif(SIM_PLOT == 1)


	rx_word_ptr = (u32 *)g_DiffSigBuffer;	//Assign a u32 pointer to the data stream
	s16 *Plot = (s16 *)MatLabBuffer;
	for(i = 0, j= 0; i < (MAX_DATA_BUFFER_SIZE); i++, j+=3)
	{

		sFixedPointToDec(rx_word_ptr[i], 32, 16, &rxFixed);
		*(Plot+j) = 0xCDAB;
		*(Plot+j+1) = 2;
		*(Plot+j+2) = (s16)rxFixed.m_Int;

	}

	for(i = 0; i < (MAX_DATA_BUFFER_SIZE * 6); i++)
		outbyte(MatLabBuffer[i]);

#else

	if(!(msgCount++%17))
	{
		if((g_LedBlink = ~g_LedBlink))
			XGpio_DiscreteClear(&Gpio, LED_CHANNEL, LED_COMM_ARDU|LED_RUN|LED_PL);
		else
			XGpio_DiscreteSet(&Gpio, LED_CHANNEL, LED_COMM_ARDU|LED_RUN|LED_PL);
	}
	outbyte(0xff);
	outbyte(0xfb);
	outbyte(0x04);
	outbyte(0x0);


		for(i = 0; i < (MAX_DATA_BUFFER_SIZE * WORD_SIZE); i +=4)
		{
			for(j = i; j < i+4; j++)
				outbyte(g_DiffSigBuffer[j]);	//write 4 bytes of integrated signal
			for(j = i+2; j < i+4; j++)
				outbyte(g_NoiseFreeSigBuffer[j]); //write the integer portion (2 bytes) of noise free ecg sig
		}

#endif
//	if((msgCount%960) == 0)
//		TEST_PRINT("%lu messages received.", msgCount);
		return 0;
}

int idle(void)
{
	return 0x0001&XGpio_DiscreteRead(&Gpio, BUTTON_CHANNEL);
}
