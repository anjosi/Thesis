/*
 * UART_0.h
 *
 *  Created on: 15.1.2015
 *      Author: Antti
 */

#ifndef UART_0_H_
#define UART_0_H_

/***************************** Include Files *******************************/
#include "xuartps.h"

//The non-blocking receive timeout UART_RECV_TIMEOUTx4 character times
#define UART_RECV_TIMEOUT 80


/**************************** Type Definitions ******************************/



/************************** Function Prototypes *****************************/




int initUART_0(XScuGic *IntcInstPtr, XUartPs *UartInstPtr, XUartPs_Handler FuncPtr);
u32 u_receive(XUartPs *UartInstPtr, u8 *p_RecvBuffer, u16 p_Length);
u32 u_send(XUartPs *UartInstPtr, u8 *p_SendBuffer, volatile int *p_ReceivedCount, u16 p_Length);


/************************** Constant Definitions **************************/





#endif /* UART_0_H_ */
