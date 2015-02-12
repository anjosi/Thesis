/*
 * signaling_macros.h
 *
 *  Created on: 15.1.2015
 *      Author: Antti
 */

#ifndef SIGNALING_MACROS_H_
#define SIGNALING_MACROS_H_
#include "xil_printf.h"

//#define DEBUG
//#define INFO
//#define ERROR
//#define WARNING
//#define TEST
#define SIM_PLOT 0
#define MATLAB

#ifdef DEBUG
#define DEBUG_TEST 1
#else
#define DEBUG_TEST 0
#endif

#define DEBUG_PRINT(fmt, args...) \
        do { if (DEBUG_TEST) xil_printf( "%s:%d:%s(): " fmt "\n\r", __FILE__, \
                                __LINE__, __FUNCTION__, ##args); } while (0)
#ifdef ERROR
#define ERROR_TEST 1
#else
#define ERROR_TEST 0
#endif

#define ERROR_PRINT(fmt, args...) \
        do { if (ERROR_TEST) printf( "%s:%d:%s(): " fmt "\n\r", __FILE__, \
                                __LINE__, __FUNCTION__, ##args); } while (0)
#ifdef WARNING
#define WARNING_TEST 1
#else
#define WARNING_TEST 0
#endif

#define WARNING_PRINT(fmt, args...) \
        do { if (WARNING_TEST) printf( "%s:%d:%s(): " fmt "\n\r", __FILE__, \
                                __LINE__, __FUNCTION__, ##args); } while (0)
#ifdef INFO
#define INFO_TEST 1
#else
#define INFO_TEST 0
#endif

#define INFO_PRINT(fmt, args...) \
        do { if (INFO_TEST) xil_printf( "%d:%s(): " fmt "\n\r", \
                                __LINE__, __FUNCTION__, ##args); } while (0)
#ifdef TEST
#define TEST_TEST 1
#else
#define TEST_TEST 0
#endif

#define TEST_PRINT(fmt, args...) \
        do { if (TEST_TEST) printf( "%d:%s(): " fmt "\n\r", \
                                __LINE__, __FUNCTION__, ##args); } while (0)


#endif /* SIGNALING_MACROS_H_ */
