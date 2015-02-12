#ifndef AXIS_DRIVER_C_
#define AXIS_DRIVER_C_

#include "axis_driver.h"
#include "signaling_macros.h"
#include "fixPTool.h"

/*****************************************************************************/
/**
*
* This function demonstrates the usage AXI FIFO
* It does the following:
*       - Set up the output terminal if UART16550 is in the hardware build
*       - Initialize the Axi FIFO Device.
*	- Transmit the data
*	- Receive the data from fifo
*	- Compare the data 
*	- Return the result
*
* @param	InstancePtr_rx is a pointer to the instance of the
*		XLlFifo component.
* @param	DeviceId is Device ID of the Axi Fifo Deive instance,
*		typically XPAR_<AXI_FIFO_instance>_DEVICE_ID value from
*		xparameters.h.
*
* @return	-XST_SUCCESS to indicate success
*		-XST_FAILURE to indicate failure
*
******************************************************************************/
 int initAxisDriver(XLlFifo *p_InstancePtr, u16 p_DeviceId)
{
	XLlFifo_Config *Config;
	int Status;
	Status = XST_SUCCESS;
	
	/* Initial setup for Uart16550 */
#ifdef XPAR_UARTNS550_0_BASEADDR

	Uart550_Setup();

#endif
/******************************************tx initialization**************/
	/* Initialize the Device Configuration Interface driver */
	Config = XLlFfio_LookupConfig(p_DeviceId);
	if (Config == NULL) {
		ERROR_PRINT("No config found for %d\r\n", p_DeviceId);
		return XST_FAILURE;
	}

	/*
	 * This is where the virtual address would be used, this example
	 * uses physical address.
	 */
	Status = XLlFifo_CfgInitialize(p_InstancePtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		ERROR_PRINT("Initialization failed");
		return Status;
	}
	
	/* Check for the Reset value */
	Status = XLlFifo_Status(p_InstancePtr);
	XLlFifo_IntClear(p_InstancePtr,0xffffffff);
	Status = XLlFifo_Status(p_InstancePtr);
	if(Status != 0x0) {
		ERROR_PRINT("\n ERROR : Reset value of ISR0 : 0x%x\t"
			    "Expected : 0x0",
			    (unsigned int)XLlFifo_Status(p_InstancePtr));
		return XST_FAILURE;
	}
	DEBUG_PRINT("Axis_fifo %d initialized.", p_DeviceId);
	return XST_SUCCESS;
}


 int axisSelftTest(XLlFifo *InstancePtr_tx, XLlFifo *InstancePtr_rx, u8 *p_SourceBuffer, u8 *p_DestinationBuffer, u32 p_Length)
  {

		u32 *source_ptr = (u32 *)p_SourceBuffer;
		u32 *dest_ptr = (u32 *)p_DestinationBuffer;
		u32 i,j,k;
		int Status = XST_SUCCESS, Error = 0;

	    sFixed l_srcFixed;
	    sfixed ptr_srcFixed = &l_srcFixed;
	    sFixed l_desFixed;
	    sfixed ptr_desFixed = &l_desFixed;

#ifdef TEST
		p_SourceBuffer[0] = 0;
		p_SourceBuffer[1] = 0;
		p_SourceBuffer[2] = 32;


		for (i=3;i<p_Length;i++)
		{
			p_SourceBuffer[i] = 0;
		}
		j=0;

		while (j < 25)
		{
#else
			for (i=0;i<p_Length;i++)
			{
				p_SourceBuffer[i] = 0;
			}
#endif
			/* Transmit the Data Stream */
			Status = TxSend(InstancePtr_tx, p_SourceBuffer, p_Length);
			if (Status != XST_SUCCESS){
				ERROR_PRINT("Transmisson of Data failed");
				return XST_FAILURE;
			}

			/* Revceive the Data Stream */
			k = 0;

			while(p_Length < (k += RxReceive(InstancePtr_rx, &p_DestinationBuffer[k])))
			{

			}


			/* Compare the data send with the data received */
			//INFO_PRINT(" Comparing data ...");
			for( i=0 ; i<MAX_DATA_BUFFER_SIZE ; i++ ){
			    Status = sFixedPointToDec(*(source_ptr + i), 32, 21, ptr_srcFixed);
			    Status = sFixedPointToDec(*(dest_ptr + i), 32, 16, ptr_desFixed);
			   if(Status)
			      ERROR_PRINT("Error in fixed to Dec convertion.");
			    else
			    	TEST_PRINT("Sample %d = Tx: %c%u.%s -> Rx: %c%u.%s : 0x%x", k++, l_srcFixed.m_Sign, (unsigned int)l_srcFixed.m_Int, l_srcFixed.m_Frac, l_desFixed.m_Sign, (unsigned int)l_desFixed.m_Int, l_desFixed.m_Frac, (unsigned int)*(dest_ptr + i));

			}
#ifdef TEST
			p_SourceBuffer[2] =0;
			//p_SourceBuffer[3] =0;
			j++;
		}
#endif
	if (Error != 0){

		ERROR_PRINT("Test packet transaction failed.");

		return XST_FAILURE;
	}
	
	INFO_PRINT("Axis driver initialized successfully!");
	return XST_SUCCESS;
}

/*****************************************************************************/
/*
*
* TxSend routine, It will send the requested amount of data at the 
* specified addr.
*
* @param	InstancePtr_tx is a pointer to the instance of the
*		XLlFifo component.
*
* @param	SourceAddr is the address where the FIFO stars writing
*
* @return	-XST_SUCCESS to indicate success
*		-XST_FAILURE to indicate failure
*
* @note		None
*
******************************************************************************/
int TxSend(XLlFifo *InstancePtr_tx, u8  *SourceAddr, u32 p_Length)
{


	while( !(XLlFifo_iTxVacancy(InstancePtr_tx) ));
	
	XLlFifo_Write(InstancePtr_tx, SourceAddr, p_Length);

	/* Start Transmission by writing transmission length into the TLR */
	XLlFifo_iTxSetLen(InstancePtr_tx, p_Length);
	

	/* Transmission Complete */
	return XST_SUCCESS;
}

/*****************************************************************************/
/*
*
* RxReceive routine.It will receive the data from the FIFO.
*
* @param	InstancePtr_rx is a pointer to the instance of the
*		XLlFifo instance.
*
* @param	DestinationAddr is the address where to copy the received data.
*
* @return	-XST_SUCCESS to indicate success
*		-XST_FAILURE to indicate failure
*
* @note		None
*
******************************************************************************/
int RxReceive (XLlFifo *InstancePtr_rx, u8* DestinationAddr)
{

	u32 ReceiveLength;
	
		if(XLlFifo_iRxOccupancy(InstancePtr_rx))
		{
			ReceiveLength = 0;
			ReceiveLength = XLlFifo_iRxGetLen(InstancePtr_rx);
			DEBUG_PRINT("Received %d bytes", ReceiveLength);
			XLlFifo_Read(InstancePtr_rx, DestinationAddr, ReceiveLength);
			//i += ReceiveLength;
		}
	return ReceiveLength;
}

#ifdef XPAR_UARTNS550_0_BASEADDR
/*****************************************************************************/
/*
*
* Uart16550 setup routine, need to set baudrate to 9600 and data bits to 8
*
* @param	None
*
* @return	None
*
* @note		None
*
******************************************************************************/
static void Uart550_Setup(void)
{

	XUartNs550_SetBaud(XPAR_UARTNS550_0_BASEADDR,
			XPAR_XUARTNS550_CLOCK_HZ, 9600);

	XUartNs550_SetLineControlReg(XPAR_UARTNS550_0_BASEADDR,
			XUN_LCR_8_DATA_BITS);
}
#endif


#endif /* AXIS_DRIVER_C_ */
