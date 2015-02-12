/*
 * zed_signaling.h
 *
 *  Created on: 29.1.2015
 *      Author: Antti
 */

#ifndef ZED_SIGNALING_H_
#define ZED_SIGNALING_H_


/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xgpio.h"


/************************** Constant Definitions *****************************/

#define LED_RUN 0x01   /* Assumes bit 0 of GPIO is connected to an LED  */
#define LED_COMM_ARDU 0x02   /* Assumes bit 0 of GPIO is connected to an LED  */
#define LED_PL 0x04   /* Assumes bit 0 of GPIO is connected to an LED  */

/*
 * The following constant maps to the name of the hardware instances that
 * were created in the EDK XPS system.
 */
#define GPIO_EXAMPLE_DEVICE_ID  XPAR_AXI_GPIO_0_DEVICE_ID

/*
 * The following constant is used to wait after an LED is turned on to make
 * sure that it is visible to the human eye.  This constant might need to be
 * tuned for faster or slower processor speeds.
 */
#define LED_DELAY     100000000

/*
 * The following constant is used to determine which channel of the GPIO is
 * used for the LED if there are 2 channels supported.
 */
#define LED_CHANNEL 1
#define BUTTON_CHANNEL 2

/**************************** Type Definitions *******************************/



#endif /* ZED_SIGNALING_H_ */
