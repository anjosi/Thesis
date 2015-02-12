
/****************************************************************************/
/**
 * @author Antti Siirilä
 * @file ECG_Capteur.c
 * @date 17.9.2014
 *
 * \brief This file contains a ecg signal data acquisition program from e-Health sensor platform.
 *
 * The program is targeted on Arduino Uno micro-processor board. The main function is to make ADC
 * from the ecg sensor in fixed time interval and send the data to the UART interface. The sampling rate
 * is defined from the target devices by clocking the pin 2 on Arduino board.
 *
 ******************************************************************************/
/***************************** Include Files *********************************/
#include <TimerOne.h>
//#include "../../ECG_serial.h"

/************************** Constant Definitions *****************************/
 

//#define DEBUG
#define LED_INTERV 250

/*
 * Defines the baud rate of the UART connection
 */
#define BAUDRATE 115200
#define RETRANSMISSION_COUNT 5

/*
 * Defines the length of data word send over the UART.
 */
#define WORD_LENGTH 2
#define WORD_COUNT 32
#define HEADER_LENGTH 3
#define TRAILER_LENGTH 2
#define MSG_LENGTH (WORD_COUNT * WORD_LENGTH)
#define CTRL_MSG_LENGTH 2
#define CTRL_PACKET_LENGTH (HEADER_LENGTH + TRAILER_LENGTH + CTRL_MSG_LENGTH) 
#define PACKET_LENGTH (MSG_LENGTH + HEADER_LENGTH + TRAILER_LENGTH)
#define PACKET_BUFFER_LENGTH (PACKET_LENGTH*2)
#define MAX_NUMBER_OF_PKG ((PACKET_LENGTH/CTRL_PACKET_LENGTH)+1)
#define MSG_START_INDEX 3

#define ALL_ONES 255 //0xFF
#define HEAD 4 //0x04
#define END_BYTE 239 //0xEF
#define ACK_MSG 1	//0x1
#define NACK_MSG 2	//0x2
#define ERROR	0 		//0x0



enum states {INIT, STARTING, ACTIVE};

/*
 * Defines the interrupt states
 */
#define IDLE 0
#define SAMPLE 1
#define LED	13
/*
 * Buffer to send and receive data to/from UART
 */
/************************** Function Prototypes ******************************/
void isr(void);

void sendData(void);
void initStateProcedure(void);
unsigned int syncStream(byte * p_Buf, unsigned int *p_Length);
void activeStateProcedure(void);
void ledToggle(void);
void initResources(void);
void sendACK(void);
void resetBuffer(byte *p_Buf, unsigned int p_Start,  unsigned int p_Length);
unsigned int isSyncFrame(byte * p_Buf);
void dumpBuffer(byte *p_Buf, unsigned int p_Start, unsigned int p_End);
void writeHeader(void);
void writeTrailer(unsigned int p_StartIndex);
unsigned int receive(void);





/************************** Variable Definitions *****************************/
byte packetBuffer[MSG_LENGTH];
byte sendBuffer[PACKET_LENGTH];
byte rcvBuffer[PACKET_LENGTH];

unsigned int data, word_count, rcv_data, rt_count, RT_TIMEOUT, rt_timeout;
volatile int sample_state = IDLE;
unsigned int * word_ptr_pkg;
unsigned int * word_ptr_send;
unsigned int * word_ptr_rcv;

unsigned int ledTimer;

states serial_comm_state; 
unsigned int Index;
byte toggle;
int rcvIndex;
unsigned int g_Available, g_Start_index;
//SoftwareSerial mySerial(10, 11); // RX, TX

/*****************************************************************************/
/**
 *
 * \brief Main function to call the ecg sensor data acquisition program.
 *
 * @param None
 *
 * @note None
 *
 ******************************************************************************/
// The setup routine runs once when you press reset:
void setup() {
  /*
  if((RETRANSMISSION_COUNT%2) == 0)
    RT_TIMEOUT = WORD_COUNT / (RETRANSMISSION_COUNT +1);
  else
    RT_TIMEOUT = WORD_COUNT / RETRANSMISSION_COUNT;
  */
  RT_TIMEOUT = WORD_COUNT;
  ledTimer = 0;
  
  Serial.begin(BAUDRATE);

  //  mySerial.begin(BAUDRATE);
  Serial.setTimeout(1);

  
  
  //attachInterrupt(0, isr, RISING );


  //Cast and assign the sendbuffer pointer to a two byte pointer. With this we can add two bytes at the time into the buffer.
  word_ptr_pkg = (unsigned int *)packetBuffer;
  word_ptr_send = (unsigned int *)sendBuffer;
  word_ptr_rcv = (unsigned int *)rcvBuffer;
  


  //init led pin
  pinMode(LED, OUTPUT);
  digitalWrite(LED, LOW);
  toggle = 1;

  Timer1.initialize(2000); // set the sample rate to 2000 microseconds (or 0.002 sec - or 500Hz => 500 samples/sec)
  Timer1.attachInterrupt( isr ); // attach the service routine here
  initResources();

}
void initResources(void)
{
  //Serial.println("Transision to INIT");
  
  serial_comm_state = INIT;
  rt_timeout = RT_TIMEOUT;
  rt_count = 0;
  
}
// The loop routine runs over and over again forever:
void loop() {

	
  while(sample_state == IDLE);


  //run the Serial communication procedure
  switch(serial_comm_state)
    {
    case INIT:

      digitalWrite(LED, HIGH);
      initStateProcedure();
      break;
    case ACTIVE:
#ifdef DEBUG
	    
      *(word_ptr_pkg+word_count) = word_count++;
      //digitalWrite(LED, LOW);
      ledToggle();
      
#else	    //Performs the ADC for the analog sensor data and stores it into the packet buffer.	
       ledToggle();
      *(word_ptr_pkg+word_count++) = analogRead(0);
#endif
      activeStateProcedure();
      break;
    case STARTING:
      // ledToggle();
#ifdef DEBUG
	    
      *(word_ptr_pkg+word_count) = word_count++;
      //      digitalWrite(LED, HIGH);
#else	    //Performs the ADC for the analog sensor data and stores it into the packet buffer.	
      *(word_ptr_pkg+word_count++) = analogRead(0);
#endif
      
      activeStateProcedure();
      break;
    default:
      initResources();
      break;
      
    }



  /*
   * Set state to IDLE
   */
  sample_state = IDLE;


}

/*****************************************************************************/
/**
 *
 * \brief This is the interrupt service routine to trigger the sampling processor.
 * 
 *p
 ****************************************************************************/

void isr(void)
{
  sample_state = SAMPLE;
}

void writeHeader(void)
{
  sendBuffer[0] = ALL_ONES;
  sendBuffer[1] = ALL_ONES;
  sendBuffer[2] = HEAD;
  
}

void writeTrailer(unsigned int p_StartIndex)
{
  sendBuffer[p_StartIndex] = END_BYTE;
  sendBuffer[p_StartIndex + 1] = END_BYTE;


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

void resetBuffer(byte *p_Buf, unsigned int p_Start, unsigned int p_Length)
{
  unsigned int i;
  for(i=p_Start; i < p_Length; i++)
    p_Buf[i] = 0;

}


/*****************************************************************************/
/**
 *
 * \brief Packs the given control word into a serial packet
 * 
 *
 ****************************************************************************/

void sendACK(void)
{
  resetBuffer(sendBuffer, MSG_START_INDEX, PACKET_LENGTH);
  writeHeader();
  sendBuffer[MSG_START_INDEX] = ACK_MSG;
  sendBuffer[MSG_START_INDEX+1] = 0;
  writeTrailer(MSG_START_INDEX+2);
  Serial.write(sendBuffer, CTRL_PACKET_LENGTH);
 
  
}

/*****************************************************************************/
/**
 *
 * \brief Packs the given data buffer into a serial packet
 * 
 *
 ****************************************************************************/

void sendData(void)
{

  unsigned int l_SendIndex = MSG_START_INDEX;
  
  resetBuffer(sendBuffer, MSG_START_INDEX, PACKET_LENGTH);
  writeHeader();
  
  for(Index = 0; Index < MSG_LENGTH; Index++)
    {
      *(sendBuffer+l_SendIndex) = *(packetBuffer+Index);
      l_SendIndex++;
    }

  writeTrailer(l_SendIndex);
  Serial.write(sendBuffer, PACKET_LENGTH);
  resetBuffer(packetBuffer, 0, PACKET_LENGTH);
}

/*****************************************************************************/
/**
 *
 * \brief Serial connection initialization procedure
 * 
 * Disables the interrupts, resets all the buffers, resets the control variables,
 * sends an ACK msg and waits for reply. If the reply does not arrive with in
 * the timeout period, the procedure resends the ACK msg. The procedure teriminates
 * only after a succesful ACK exchange sequence.
 *
 ****************************************************************************/

void initStateProcedure(void)
{

  g_Available = 0;
  g_Start_index = 0;
  
  //send the ACK
  if(rt_timeout == RT_TIMEOUT)
    {
      sendACK();
      rt_timeout = 0;
    }

  //wait the response
  if((g_Available = receive()) == 0)
    {
      rt_timeout++;
      return;
	  
    }

  //parse the message from the received packet
  g_Start_index = syncStream(rcvBuffer, &g_Available);

  //a valid packet has at least two header fields
  if(g_Start_index < 2)
    {
      rt_timeout = RT_TIMEOUT;
      //invalid message was received therefore we'll send a new ACK right a way.
      return;
    }

  //if the message was ACK
  if(rcvBuffer[g_Start_index] == ACK_MSG)
    {
	      
      //set connection state to ACTIVE
      serial_comm_state = STARTING;
      resetBuffer(packetBuffer, 0, MSG_LENGTH);
      //this is clear we are ready to return
      return;

    }

  //if the message was NACK
  if(rcvBuffer[g_Start_index] == NACK_MSG)
    {
      //NACK request a new ACK to be sent
      rt_timeout = RT_TIMEOUT;
	      
    }
	  
	  

	
}



/*****************************************************************************/
/**
 *
 * \brief Serial connections active procedure
 * 
 * The active procedure has two states STARTING and ACTIVE. In STARTING state
 * system waits until the data for the first serial packet is ready. Once the
 * data is ready, it is packed and sent to the Serial interface. After that the
 * prcedure transitions to the ACTIVE state. IN ACTIVE state the system waits
 * the ACK for the earlier sent packages, performs the retransmission, and sends
 * next data packets. Retransmission occurs if the ACK is not received within 
 * the given timeout period. The ACK must arrive before the next data packet 
 * is sent otherwise the system transitions to the INIT state.
 *
 ****************************************************************************/

void activeStateProcedure(void)
{
  g_Start_index = 0;
  g_Available = 0;
  
  
  switch(serial_comm_state)
    {
    case STARTING:
      if(word_count == WORD_COUNT)
	{
	  sendData();
	  rt_timeout = 0;
	  rt_count = 0;
	  word_count = 0;
	  serial_comm_state = ACTIVE;
	}
      break;
    case ACTIVE:
      
      if((g_Available = receive()) == 0)
	{
	  rt_timeout++;
	  
	}
      else
	{
	  
     	  
	  g_Start_index = syncStream(rcvBuffer, &g_Available);
	  
	  //if the packet was invalid
	  if(g_Start_index < 2)
	    rt_timeout++;
	  //if the packet was valid
	  else
	    {
	      //in case of ACK
	      if(rcvBuffer[g_Start_index] == ACK_MSG)
		{
		  rt_timeout = 0;
		  rt_count = 0;
		}
	      //in case of NACK
	      else if(rcvBuffer[g_Start_index] == NACK_MSG)
		{
		  initResources(); //Transition to the init state
		}
	      //others
	      else
		{
		  rt_timeout++;
		}
	    }
	  
	}
      
      
      //Check if the rt_timer has expired
      if(rt_timeout == RT_TIMEOUT)
	{
	  rt_timeout = 0;
	  rt_count++;
	}
      
      if(rt_count == RETRANSMISSION_COUNT)
	{
	  initResources();
	  //if replies has not been received within RETRANSMISSION_COUNT * WORD_COUNT sample time
	  //then transition to the init state
	  return;
	}
      
      //check if it is time to send the next packet
      if(word_count == WORD_COUNT)
	{
	  sendData();
	  word_count = 0;
	}
      break;
    default:
      initResources(); //Transition to the init state
      break;
      
    }
}



void ledToggle(void)
{

  if(ledTimer == LED_INTERV)
    {
      ledTimer = 0;
      
  //Toggle the led
  if(toggle)
    {
      digitalWrite(LED, LOW);
      toggle = 0;
    }
  else
    {
      digitalWrite(LED, HIGH);
      toggle = 1; 
    }
    }
  
  else
    ledTimer++;
  
}

unsigned int syncStream(byte * p_Buf, unsigned int *p_Length)
{
  unsigned int i,j;
  unsigned int found = 0;
  for(i=0; i < *p_Length; i++)
    {
      // in here we're going to read 3 elements after i
      if(i < (*p_Length-3))
	{
	  found = (isSyncFrame(&p_Buf[i]) + i);
	  if(found > 1)
	    {
	      for(j=found+WORD_LENGTH;j< *p_Length;j++)
		{
		  if(p_Buf[j] == END_BYTE && (j+1) < *p_Length)
		    {
		      if(p_Buf[j+1] == END_BYTE)
			{
			  *p_Length = j-found;
			  return found;
			  
			}
		      
		    }
		  
		}
	      
	    }
	  
	}
    }

  return 0;
}

unsigned int isSyncFrame(byte * p_Buf)
{
  //First sync byte
  if(*p_Buf == ALL_ONES)
    {
      //sencond sync byte
      if(*(p_Buf+1) == ALL_ONES)
	{
	  //if third bit is all ones
	  if(*(p_Buf+2) == HEAD)
	    return 3; 	// the msg starts in the next element
	  else
	    return 0;
	}
      else if(*(p_Buf+1) == HEAD)
	return 2; //otherwise right after second sync byte
      else
	return 0;
    }
  else
    return 0;

}


void dumpBuffer(byte *p_Buf, unsigned int p_Start, unsigned int p_End)
{
  unsigned int i;

  //Serial.println("");
  //Serial.println("Buffer contents");
  
  for(i=p_Start; i < p_End; i++)
    {
      //Serial.print(i+1);
      //Serial.print(". word: ");
      //Serial.println(p_Buf[i]);
      
    }
  
}

unsigned int receive(void)
{
  resetBuffer(rcvBuffer, 0, PACKET_LENGTH);
  unsigned int i = 0;
  
  while(Serial.available() > 0)
    {
      rcvBuffer[i++] = Serial.read();
      
    }
  
  return i;
  
}
