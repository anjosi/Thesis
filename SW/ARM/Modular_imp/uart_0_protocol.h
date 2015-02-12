/******************************************************************************
 *
 * Copyright (C) 2010 - 2014 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Use of the Software is limited solely to applications:
 * (a) running on a Xilinx device, or
 * (b) that interact with a Xilinx device through a bus or interconnect.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 *
 ******************************************************************************/
/*
 * @file uart_0_protocol.h
 *
 * The protcol defines the packet format, message types, and message
 * exchange sequence for data exchange between producer and consumer devices.
 * The data is independendt words of 16-bit long compined in a message, which
 * is furthermore packed into a packet with header and trailer bytes. The purpose
 * is to synchronize the data flow and provide some level of flow control for
 * the communication.
 *
 * Communication start with the exchange of ACK messages between producer and
 * consumer. The producer transmits ACK packets until it receives a reply from
 * consumer. After that the producer starts transmitting data packets. The ACK
 * exchange occurs after each recovery from a communication failure.
 *
 * The module bases on the Xilinx's example in xuartps_intr_example.c-file.
 *  
 * @date1 : 15.1.2015
 * @Author : Antti Siirilä
 */

#ifndef UART_0_PROTOCOL_H_
#define UART_0_PROTOCOL_H_

/***************************** Include Files *******************************/
#include "xparameters.h"
#include "xscugic.h"
#include "as_ecg_application_param.h"

/**************************** Type Definitions ******************************/
typedef s8 (*FT_FORWARD)(u8 *p_Buf, u16 p_Length);
typedef int (*FT_IDLE)(void);

/***************************** Defines *******************************/

/*
 * The following constant controls the length of the buffers to be sent
 * and received with the UART,
 */
#define DEBUG_TEST_PACKET_COUNT	200
#define TIMEOUT 500
#define WORD_LENGTH 2
#define WORD_COUNT 32
#define HEADER_LENGTH 3
#define TRAILER_LENGTH 2


//below are the packet delimeter byte definitions. A packet encoding is the following:
/*
 * 	|PACKET_DELIMITER|PACKET_DELIMITER|HEAD|msg|TAIL|TAIL|
 *
 */
#define PACKET_DELIMITER 255	   //xFF
#define HEAD	4 //0x04
#define TAIL 239

/*
 * There are two message types: ctrl- and data-messages. The control message has always the length of 2 bytes. The length
 * of a data message must be at least three bytes.
 */
//The following defines determine the control message data
#define ACK_MSG	1
#define NACK_MSG 2

#define MSG_START_INDEX	3


/************************** Function Prototypes *****************************/

int run(FT_FORWARD p_Forward, FT_IDLE p_Idle);




#endif /* UART_0_PROTOCOL_H_ */
