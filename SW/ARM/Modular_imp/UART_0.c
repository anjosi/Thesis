/*
 * UART_0.c
 *
 *  Created on: 15.1.2015
 *      Author: Antti
 */

#ifndef UART_0_C_
#define UART_0_C_

/***************************** Include Files *******************************/

#include "xscugic.h"
#include "UART_0.h"
#include "signaling_macros.h"
/***************************** Defines *******************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define UART_DEVICE_ID		XPAR_XUARTPS_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID
#define UART_INT_IRQ_ID		XPAR_XUARTPS_0_INTR




static int SetupInterruptSystem(XScuGic *IntcInstancePtr,
		XUartPs *UartInstancePtr,
		u16 UartIntrId);


/************************** Function Implementations *****************************/

int initUART_0(XScuGic *IntcInstPtr, XUartPs *UartInstPtr, XUartPs_Handler FuncPtr)
{
	int Status;
	XUartPs_Config *Config;

	u32 IntrMask;

	/*
	 * Initialize the UART driver so that it's ready to use
	 * Look up the configuration in the config table, then initialize it.
	 */
	Config = XUartPs_LookupConfig(UART_DEVICE_ID);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(UartInstPtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Check hardware build
	 */
	Status = XUartPs_SelfTest(UartInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the UART to the interrupt subsystem such that interrupts
	 * can occur. This function is application specific.
	 */
	Status = SetupInterruptSystem(IntcInstPtr, UartInstPtr, UART_INT_IRQ_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Setup the handlers for the UART that will be called from the
	 * interrupt context when data has been sent and received, specify
	 * a pointer to the UART driver instance as the callback reference
	 * so the handlers are able to access the instance data
	 */
	XUartPs_SetHandler(UartInstPtr, FuncPtr, UartInstPtr);

	/*
	 * Enable the interrupt of the UART so interrupts will occur, setup
	 * a local loopback so data that is sent will be received.
	 */
	IntrMask =
			XUARTPS_IXR_TOUT | XUARTPS_IXR_PARITY | XUARTPS_IXR_FRAMING |
			XUARTPS_IXR_OVER | XUARTPS_IXR_TXEMPTY | XUARTPS_IXR_RXFULL |
			XUARTPS_IXR_RXOVR;
	XUartPs_SetInterruptMask(UartInstPtr, IntrMask);

	XUartPs_SetOperMode(UartInstPtr, XUARTPS_OPER_MODE_NORMAL);
	return Status;
}


/*****************************************************************************/
/**
 *
 * This function sets up the interrupt system so interrupts can occur for the
 * Uart. This function is application-specific. The user should modify this
 * function to fit the application.
 *
 * @param	IntcInstancePtr is a pointer to the instance of the INTC.
 * @param	UartInstancePtr contains a pointer to the instance of the UART
 *		driver which is going to be connected to the interrupt
 *		controller.
 * @param	UartIntrId is the interrupt Id and is typically
 *		XPAR_<UARTPS_instance>_INTR value from xparameters.h.
 *
 * @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
 *
 * @note		None.
 *
 ****************************************************************************/

static int SetupInterruptSystem(XScuGic *IntcInstancePtr,
		XUartPs *UartInstancePtr,
		u16 UartIntrId)
{
	int Status;

#ifndef TESTAPP_GEN
	XScuGic_Config *IntcConfig; /* Config for interrupt controller */

	/*
	 * Initialize the interrupt controller driver
	 */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig,
			IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Connect the interrupt controller interrupt handler to the
	 * hardware interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
			IntcInstancePtr);
#endif

	/*
	 * Connect a device driver handler that will be called when an
	 * interrupt for the device occurs, the device driver handler
	 * performs the specific interrupt processing for the device
	 */
	Status = XScuGic_Connect(IntcInstancePtr, UartIntrId,
			(Xil_ExceptionHandler) XUartPs_InterruptHandler,
			(void *) UartInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Enable the interrupt for the device
	 */
	XScuGic_Enable(IntcInstancePtr, UartIntrId);


#ifndef TESTAPP_GEN
	/*
	 * Enable interrupts
	 */
	Xil_ExceptionEnable();
#endif

	return XST_SUCCESS;
}


u32 u_receive(XUartPs *UartInstPtr, u8 *p_RecvBuffer, u16 p_Length)
{
	XUartPs_SetRecvTimeout(UartInstPtr, UART_RECV_TIMEOUT);
	return XUartPs_Recv(UartInstPtr, p_RecvBuffer, p_Length);

}

u32 u_send(XUartPs *UartInstPtr, u8 *p_SendBuffer, volatile int *p_ReceivedCount, u16 p_Length)
{
	/*
	 * Send the buffer using the UART and ignore the number of bytes sent
	 * as the return value since we are using it in interrupt mode.
	 */
	XUartPs_Send(UartInstPtr, p_SendBuffer, p_Length);
	while(*p_ReceivedCount < p_Length);

	return p_Length;
}

#endif /* UART_0_C_ */
