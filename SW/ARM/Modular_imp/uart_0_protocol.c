/****************************************************************************/
/**
 *
 * @file		uart_0_protocol.c
 *
 * This file bases on the xilinx's xuartps_intr_example.c-file. The file contains
 * implementation of UART 0 serial protocol between the zed-board and a producer
 * client. 
 *
 *
 * @note
 * The example contains an infinite loop such that if interrupts are not
 * working it may hang.
 *
 * MODIFICATION HISTORY:
 * <pre>
 * Ver   Who    Date     Changes
 * ----- ------ -------- ----------------------------------------------
 * 1.00a  drg/jz 01/13/10 First Release
 * 1.00a  sdm    05/25/11 Modified the example for supporting Peripheral tests
 *		        in SDK
 * 1.03a  sg     07/16/12 Updated the example for CR 666306. Modified
 *			the device ID to use the first Device Id
 *			and increased the receive timeout to 8
 *			Removed the printf at the start of the main
 *			Put the device normal mode at the end of the example
 *
 *
 * </pre>
 ****************************************************************************/

/***************************** Include Files *******************************/
#include "uart_0_protocol.h"
#include "UART_0.h"
#include "signaling_macros.h"

#define PACKET_LENGTH ((WORD_COUNT * WORD_LENGTH) + HEADER_LENGTH + TRAILER_LENGTH)
#define CTRL_PACKET_LENGTH (HEADER_LENGTH + TRAILER_LENGTH + WORD_LENGTH)
#define BUFFER_SIZE	(PACKET_LENGTH *2)
#define MSG_LENGTH (WORD_COUNT * WORD_LENGTH)
#define MAX_PKG_COUNT ((PACKET_LENGTH/CTRL_PACKET_LENGTH)+1)

/**************************** Type Definitions ******************************/
typedef enum bufState{EMPTY,FULL, DATA} fifoState, *ptr_FifoState;
typedef enum parseState{HEAD_SEARCH, ONE_FF,TWO_FF, TAIL_SEARCH, ONE_EF, DONE, POTENTIAL_HEAD, UNEXCEPTED_HEAD, MSG_ERROR} recvParseState, *ptr_RecvState;
typedef struct msgS{
	recvParseState m_RecvState;
	u16 m_Length;
	u8 m_TempByte;
}msgState, *ptr_MsgState;


/************************** "private" Function Prototypes *****************************/

void Handler(void *CallBackRef, u32 Event, unsigned int EventData);
void resetBuffer(u8 *p_Buf, u16 p_Length);
void sendACK(void);
void sendNACK(void);
void clearMsgCtrlData(u16 p_Index);
void initMsgCtrlData(u16 p_StartIndex);
void rearrangeMsgCtrlData(u16 p_Index);
u16 parse(u16 p_BufLength);
void messageBufferPush(u8 p_Value);
u8 messageBufferPop(void);
void resetMessageFifo(void);
void writeHeader(void);
void writeTrailer(u16 p_StartIndex);
s8 reArrangeBuffer(u8 *p_Buf, u16 p_Start, u16 p_Length, u16 p_End);
s8 cpBuffer(u8 *p_BufSrc, u16 p_StartSrc, u16 p_EndSrc, u8 *p_BufDes, u16 p_StartDes, u16 p_EndDes, u16 p_Length);


/**************************Local Global Variable Definitions ***************************/

//the receiving fifo properties
static XUartPs UartPs	;		/* Instance of the UART Device */
static XScuGic InterruptController;	/* Instance of the Interrupt Controller */
msgState lg_msgCtrlData[MAX_PKG_COUNT];
u16 lg_msgFifoWriteIndex;
u16 lg_msgFifoReadIndex;
fifoState lg_msgFifoState;
static u8 lg_messageFifo[BUFFER_SIZE];	/* Buffer for Receiving Data */
static u8 SendBuffer[PACKET_LENGTH];	/* Buffer for Transmitting Data */
static u8 RecvBuffer[PACKET_LENGTH];	/* Buffer for Receiving Data */
static u8 ForwardBuffer[MSG_LENGTH];

/*
 * The following counters are used to determine when the entire buffer has
 * been sent and received.
 */
volatile int TotalReceivedCount;
volatile int TotalSentCount;
int TotalErrorCount;

/**************************************************************************/
/**
 *
 * This function is the handler which performs processing to handle data events
 * from the device.  It is called from an interrupt context. so the amount of
 * processing should be minimal.
 *
 * This handler provides an example of how to handle data for the device and
 * is application specific.
 *
 * @param	CallBackRef contains a callback reference from the driver,
 *		in this case it is the instance pointer for the XUartPs driver.
 * @param	Event contains the specific kind of event that has occurred.
 * @param	EventData contains the number of bytes sent or received for sent
 *		and receive events.
 *
 * @return	None.
 *
 * @note		None.
 *
 ***************************************************************************/
void Handler(void *CallBackRef, u32 Event, unsigned int EventData)
{
	/*
	 * All of the data has been sent
	 */
	if (Event == XUARTPS_EVENT_SENT_DATA) {
		TotalSentCount = EventData;
	}

	/*
	 * All of the data has been received
	 */
	if (Event == XUARTPS_EVENT_RECV_DATA) {
		TotalReceivedCount = EventData;
	}

	/*
	 * Data was received, but not the expected number of bytes, a
	 * timeout just indicates the data stopped for 8 character times
	 */
	if (Event == XUARTPS_EVENT_RECV_TOUT) {
		TotalReceivedCount = EventData;

	}

	/*
	 * Data was received with an error, keep the data but determine
	 * what kind of errors occurred
	 */
	if (Event == XUARTPS_EVENT_RECV_ERROR) {
		TotalReceivedCount = EventData;
		TotalErrorCount++;
	}
}

void initMsgCtrlData(u16 p_StartIndex)
{

	u16 Inx;
	for(Inx = p_StartIndex; Inx < MAX_PKG_COUNT; Inx++)
		clearMsgCtrlData(Inx);
}
void clearMsgCtrlData(u16 p_Index)
{


	lg_msgCtrlData[p_Index].m_Length = 0;
	lg_msgCtrlData[p_Index].m_RecvState = HEAD_SEARCH;
	lg_msgCtrlData[p_Index].m_TempByte = 0;

}

void resetMessageFifo(void)
{
	lg_msgFifoWriteIndex = 0;
	lg_msgFifoReadIndex = 0;
	lg_msgFifoState = EMPTY;
	resetBuffer(lg_messageFifo, BUFFER_SIZE);

}

void messageBufferPush(u8 p_Value)
{

	switch (lg_msgFifoState)
	{
	case EMPTY:
		lg_messageFifo[lg_msgFifoWriteIndex++] = p_Value;
		lg_msgFifoState = DATA;
		break;
	case DATA:
		lg_messageFifo[lg_msgFifoWriteIndex++] = p_Value;
		if(lg_msgFifoWriteIndex == BUFFER_SIZE)
			lg_msgFifoWriteIndex = 0;
		if(lg_msgFifoWriteIndex == lg_msgFifoReadIndex)
			lg_msgFifoState = FULL;
		break;
	default:
		break;
	}


}

u8 messageBufferPop(void)
{
	u8 l_Value = 0;
	switch (lg_msgFifoState)
	{
	case DATA:
		l_Value = lg_messageFifo[lg_msgFifoReadIndex++];
		if(lg_msgFifoReadIndex == BUFFER_SIZE)
			lg_msgFifoReadIndex = 0;
		if(lg_msgFifoWriteIndex == lg_msgFifoReadIndex)
			lg_msgFifoState = EMPTY;
		break;
	case FULL:
		l_Value = lg_messageFifo[lg_msgFifoReadIndex++];
		lg_msgFifoState = DATA;
		break;
	default:
		break;


	}

	return l_Value;
}
/*****************************************************************************/
/**
 *
 * \brief Resets the buffer pointed by p_Buf
 *
 * Writes zeros to the elements starting from the index 0 to the index p_Length-1
 *
 *
 *
 ****************************************************************************/

void resetBuffer(u8 *p_Buf, u16 p_Length)
{
	u16 i;
	for(i=0; i < p_Length; i++)
		p_Buf[i] = 0;

}

void sendACK(void)
{
	TotalSentCount = 0;
	writeHeader();
	SendBuffer[MSG_START_INDEX] = ACK_MSG;
	SendBuffer[MSG_START_INDEX+1] = 0;
	writeTrailer(MSG_START_INDEX+2);

	u_send(&UartPs, SendBuffer, &TotalReceivedCount, CTRL_PACKET_LENGTH);
}

void sendNACK(void)
{
	TotalSentCount = 0;
	writeHeader();
	SendBuffer[MSG_START_INDEX] = NACK_MSG;
	SendBuffer[MSG_START_INDEX+1] = 0;
	writeTrailer(MSG_START_INDEX+2);
	
	u_send(&UartPs, SendBuffer, &TotalReceivedCount, CTRL_PACKET_LENGTH);
}

void writeHeader(void)
{
	SendBuffer[0] = PACKET_DELIMITER;
	SendBuffer[1] = PACKET_DELIMITER;
	SendBuffer[2] = HEAD;

}

void writeTrailer(u16 p_StartIndex)
{
	SendBuffer[p_StartIndex] = TAIL;
	SendBuffer[p_StartIndex + 1] = TAIL;


}


/**************************************************************************/
/**
 *
 * This function does a minimal test on the UartPS device and driver as a
 * design example. The purpose of this function is to illustrate
 * how to use the XUartPs driver.
 *
 * This function sends data and expects to receive the same data through the
 * device using the local loopback mode.
 *
 * This function uses interrupt mode of the device.
 *
 * @param	IntcInstPtr is a pointer to the instance of the Scu Gic driver.
 * @param	UartInstPtr is a pointer to the instance of the UART driver
 *		which is going to be connected to the interrupt controller.
 * @param	DeviceId is the device Id of the UART device and is typically
 *		XPAR_<UARTPS_instance>_DEVICE_ID value from xparameters.h.
 * @param	UartIntrId is the interrupt Id and is typically
 *		XPAR_<UARTPS_instance>_INTR value from xparameters.h.
 *
 * @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
 *
 * @note
 *
 * This function contains an infinite loop such that if interrupts are not
 * working it may never return.
 *
 **************************************************************************/

int run(FT_FORWARD p_Forward, FT_IDLE p_Idle)
{

	int packet_count = 0;
	int Status;
	u16 i, j;
	u8 l_byte, h_byte;
	u8 l_Condition;
	int l_Expecting;

	//init UART_0
	Status = initUART_0(&InterruptController, &UartPs, Handler);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	resetBuffer(SendBuffer, PACKET_LENGTH);



	INFO_PRINT("INIT: Starting the receiving loop.");

	//Start the main receiver loop
	while (packet_count < DEBUG_TEST_PACKET_COUNT)
	{

		INFO_PRINT("Initializing the UART communication.");
		//set the initial expectation value so that at least
		l_Expecting = CTRL_PACKET_LENGTH + HEADER_LENGTH + TRAILER_LENGTH;
		//condition is 1 for the active receiving loop.
		l_Condition = 1;
		while(l_Condition > 0)	//We only exit here if an error, too short or long, or other ctrl than ACK message was received.
		{
			//Here there will be no pending messages, therefore we can reset all the old messages.
			initMsgCtrlData(0);
			resetMessageFifo();
			//condition is 2 for packet parsing loop.
			l_Condition = 2;
			while(l_Condition >1)	//We only come out of this loop if no pending messages exists
			{

				//Before receiving new packets, we'll reset the buffer
				resetBuffer(RecvBuffer,0);
				//set the received count to zero
				TotalReceivedCount = 0;
				//start the none-blocking uart receive
				u_receive(&UartPs, RecvBuffer, l_Expecting );
				//receiving loop: Wait until some thing is received or timeout occurs
				while(TotalReceivedCount == 0)
				{
					if(p_Idle())
						return -2;
				}
				DEBUG_PRINT("%d bytes received from UART.", TotalReceivedCount);
/*
				j=0;
				u16 *short_prt = (u16 *)RecvBuffer;
				while(j < TotalReceivedCount)
				{
					TEST_PRINT("%d:%d",(j+1), *(short_prt+j++));
				}
*/
				//parse the received bytes
				parse(TotalReceivedCount);
				i=0;
				l_Condition = 3;
				//This is the message check loop.
				while(l_Condition > 2)	// Here we loop until all the complete messages are checked or an erroneous message is found.
				{
					if(lg_msgCtrlData[i].m_RecvState == MSG_ERROR)
					{
						ERROR_PRINT("ERROR: error in packet parsing.", TotalReceivedCount);
						l_Condition = 0; //if the message state is error, move to re-initialization of the uart communication.
						continue;
					}

					if(lg_msgCtrlData[i].m_RecvState != DONE)
					{
						//We go here if the message is not complete
						if(lg_msgCtrlData[i].m_RecvState == HEAD_SEARCH)
							l_Condition = 1;//Empty message found. Go to init the buffers and receive next packet
						else
						{
							DEBUG_PRINT("%d. message pending", i);
							rearrangeMsgCtrlData(i); //The message is not complete so we need to move this in the start of the buffer
							initMsgCtrlData(1); //init the subsequent message
							l_Condition = 2; //go to receive next packet without initializing the message fifo
						}
						continue;
					}

					if(lg_msgCtrlData[i].m_Length != MSG_LENGTH)
					{
						//This is for the messages that are not data messages
						if(lg_msgCtrlData[i].m_Length == WORD_LENGTH)
						{
							//This is for the CTRL-messages
							l_byte = messageBufferPop();
							h_byte = messageBufferPop();

							if(l_byte == ACK_MSG && h_byte == 0)
							{
								//if the message was ACK
								INFO_PRINT("ACK received at index %d.", i);
								l_Expecting = PACKET_LENGTH; //change the expected byte count since from now on we should receive only data packets
								sendACK(); //signal the client that we are ready
								i++; //move to the next message
								continue;
							}
						}
						//All the other messages that are not data nor ctrl-messages go to to re-initialization of the uart communication.
						l_Condition = 0;

						continue;
					}

					//for complete data messages
					j=0;
					while(j < MSG_LENGTH)
					{
						if(lg_msgFifoState != EMPTY)
							ForwardBuffer[j] = messageBufferPop();
						else
						{
							TEST_PRINT("ERROR: FIFO EMPTY. Although it should not be.");
						}
						j++;
					}
//					if(lg_msgFifoState == EMPTY)
//						TEST_PRINT("FIFO EMPTY as it should.");
					if(p_Forward(ForwardBuffer, MSG_LENGTH)) //forward the message to the AXI
					{
						return -1;
					}
					sendACK(); //ACKNOWLEDGE the packet
					i++;//move to the next message
#ifdef DEBUG
					packet_count++;
					if(packet_count == DEBUG_TEST_PACKET_COUNT)
						l_Condition = 0;
#endif

				}

			}


		}
		//in case of erroneous message reception send negative acknowledgment
		sendNACK();

	}


	return packet_count;
}

/*
 * parse-function takes a received byte buffer as argument, removes the header and tail bytes, and writes the
 * message words in the message fifo. The state and other control data of each message are stored in g_MsgState-struct array
 */
u16 parse(u16 p_BufLength)
{
	u16 i, j=0, k=0;

	for(i = 0; i < p_BufLength; i++)
	{

		switch(lg_msgCtrlData[j].m_RecvState)
		{
		case HEAD_SEARCH:
			if(RecvBuffer[i] == PACKET_DELIMITER)
				lg_msgCtrlData[j].m_RecvState = ONE_FF;
			break;
		case ONE_FF:
			if(RecvBuffer[i] == PACKET_DELIMITER)
				lg_msgCtrlData[j].m_RecvState = TWO_FF;
			else if(RecvBuffer[i] == HEAD)
			{
				lg_msgCtrlData[j].m_RecvState = TAIL_SEARCH;
			}
			else
				lg_msgCtrlData[j].m_RecvState = HEAD_SEARCH;

			break;
		case TWO_FF:
			if(RecvBuffer[i] == HEAD)
			{
				lg_msgCtrlData[j].m_RecvState = TAIL_SEARCH;
			}
			else
				lg_msgCtrlData[j].m_RecvState = HEAD_SEARCH;

			break;
		case TAIL_SEARCH:
			if(RecvBuffer[i] == TAIL)
			{
				lg_msgCtrlData[j].m_RecvState = ONE_EF;
				lg_msgCtrlData[j].m_TempByte = RecvBuffer[i];
			}
			else if(RecvBuffer[i] == PACKET_DELIMITER)
			{
				lg_msgCtrlData[j].m_RecvState = POTENTIAL_HEAD;
				lg_msgCtrlData[j].m_TempByte = RecvBuffer[i];

			}
			else
			{
				messageBufferPush(RecvBuffer[i]);
				lg_msgCtrlData[j].m_Length++;
			}
			break;
		case ONE_EF:
			if(RecvBuffer[i] == TAIL || RecvBuffer[i] == PACKET_DELIMITER)
			{
				lg_msgCtrlData[j].m_RecvState = DONE;
				k += lg_msgCtrlData[j].m_Length;
				//increment the byte count
				j++;

			}
			else
			{
				lg_msgCtrlData[j].m_RecvState = TAIL_SEARCH;
				messageBufferPush(lg_msgCtrlData[j].m_TempByte);
				messageBufferPush(RecvBuffer[i]);
				lg_msgCtrlData[j].m_Length += 2;
			}

			break;
		case POTENTIAL_HEAD:
			if(RecvBuffer[i] == PACKET_DELIMITER)
			{
				lg_msgCtrlData[j].m_RecvState = UNEXCEPTED_HEAD;

			}
			else if(RecvBuffer[i] == HEAD)
			{
				ERROR_PRINT("Unexpected and complete header found");
				lg_msgCtrlData[j].m_RecvState = DONE;
				j++;
				lg_msgCtrlData[j].m_RecvState = TAIL_SEARCH;
			}
			else
			{
				lg_msgCtrlData[j].m_RecvState = TAIL_SEARCH;
				messageBufferPush(lg_msgCtrlData[j].m_TempByte);
				messageBufferPush(RecvBuffer[i]);
				lg_msgCtrlData[j].m_Length += 2;
			}

			break;
		case UNEXCEPTED_HEAD:

			if(RecvBuffer[i] == HEAD)
			{
				ERROR_PRINT("Unexpected and complete header found");
				lg_msgCtrlData[j].m_RecvState = DONE;
				j++;
				lg_msgCtrlData[j].m_RecvState = TAIL_SEARCH;
			}
			else
			{
				ERROR_PRINT("Unexpected but incomplete header found");
				lg_msgCtrlData[j].m_RecvState = MSG_ERROR;

				i = p_BufLength;
			}
			break;
		default:

			break;
		}
	}


	if(lg_msgCtrlData[j].m_RecvState != DONE)
		k += lg_msgCtrlData[j].m_Length;
	//how many bytes were written in the packetBufferRecv
	return k;
}



void rearrangeMsgCtrlData(u16 p_Index)
{
	lg_msgCtrlData[0].m_Length = lg_msgCtrlData[p_Index].m_Length;
	lg_msgCtrlData[0].m_RecvState = lg_msgCtrlData[p_Index].m_RecvState;
	lg_msgCtrlData[0].m_TempByte = lg_msgCtrlData[p_Index].m_TempByte;
	initMsgCtrlData(1);
}

s8 reArrangeBuffer(u8 *p_Buf, u16 p_Start, u16 p_Length, u16 p_End)
{
	if(p_Length > p_End)
		return -1;
	u16 i, j = 0;
	for(i = p_Start; i < p_Length; i++)
		p_Buf[j++] = p_Buf[i];
	return 0;


}

s8 cpBuffer(u8 *p_BufSrc, u16 p_StartSrc, u16 p_EndSrc, u8 *p_BufDes, u16 p_StartDes, u16 p_EndDes, u16 p_Length)
{
	if((p_StartSrc+p_Length) > p_EndSrc || (p_StartDes+p_Length) > p_EndDes)
		return -1;
	u16 i_src, i_des = p_StartDes;
	for(i_src = p_StartSrc; i_src < p_Length; i_src++)
		p_BufDes[i_des++] = p_BufSrc[i_src];
	return 0;
}

