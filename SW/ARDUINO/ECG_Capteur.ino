
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
/************************** Constant Definitions *****************************/
/*
* Defines the baud rate of the UART connection
*/
#define BAUDRATE 115200
/*
* Defines the length of data word send over the UART.
*/
#define WORD_LENGTH 2
/*
* Defines the interrupt states
*/
#define IDLE 0
#define SAMPLE 1

/*
* Buffer to send and receive data to/from UART
*/
/************************** Function Prototypes ******************************/
void isr(void);
void presentForUART();
void presentForProg();
void sendWord();
/************************** Variable Definitions *****************************/
byte sendBuffer[WORD_LENGTH];
byte rcvBuffer[WORD_LENGTH];
unsigned int data;
volatile int sample_state = IDLE;
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
Serial.begin(BAUDRATE);
pinMode(2, INPUT);
attachInterrupt(0, isr, RISING );
data = 0;
}
// The loop routine runs over and over again forever:
void loop() {

	while(!sample_state);
	/*
	* Performs the ADC for the analog sensor data and stores it into the data-variable.
	*/
	data = analogRead(0);
	/*
	* Present the sensor data for the UART as two bytes.
	*/
	presentForUART();
	/*
	* Send the data over the UART link.
	*/
	sendWord();
	sample_state = IDLE;

}
/*****************************************************************************/
/**
*
* \brief This is the interrupt service routine to trigger the sampling processor.
* 
*
****************************************************************************/

void isr(void)
{
	sample_state = SAMPLE;
}
/*****************************************************************************/
/**
*
* \brief This function does the presentation of data as two bytes for the UART.
*
* The 16-bit int is packed into a byte array.
*
*
*
****************************************************************************/
void presentForUART()
{
sendBuffer[0] = data;
sendBuffer[1] = (data >> 8);
data = 0;
}
/*****************************************************************************/
/**
*
* \brief This function does the presentation of data as 16-bit int for the program.
*
* Two bytes are packed into a 16-bit int.
*
*
*
****************************************************************************/
void presentForProg()
{
data = rcvBuffer[1];
data <<= 8;
data |= rcvBuffer[0];
for(int i = 0; i < WORD_LENGTH; i++)
rcvBuffer[i] = 0;
}
/*****************************************************************************/
/**
*
* \brief This function sends two bytes over the UART.
*
****************************************************************************/
void sendWord()
{
for(int i = 0; i < WORD_LENGTH; i++)
{
Serial.write(sendBuffer[i]);
//sendBuffer[i] = 0;
}
}