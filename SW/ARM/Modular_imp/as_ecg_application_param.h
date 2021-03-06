/*
 * as_ecg_application_param.h
 *
 *  Created on: 15.1.2015
 *      Author: Antti
 */

#ifndef AS_ECG_APPLICATION_PARAM_H_
#define AS_ECG_APPLICATION_PARAM_H_
#include "ECG_Detector.h"


//Signal detection thresholds
#define QRS_PEAK_DETEC_THRESH_AMP	(u32)800000
#define QRS_PEAK_DETEC_THRESH_DEL	(u32)30
#define R_PEAK_DETEC_THRESH			(u32)111411200	//1700//(u32)26214400	//400
#define R_PEAK_MIN_THRESH			(u32)26214400	//400//(u32)52428800	//800
#define R_PEAK_MAX_THRESH			(u32)0	//800//(u32)78643200	//1200


//Threshold registers
#define QRS_PEAK_REG ECG_DETECTOR_CTRL_AXI_SLV_REG0_OFFSET
#define QRS_DELAY_REG ECG_DETECTOR_CTRL_AXI_SLV_REG1_OFFSET
#define R_PEAK_THRES_REG ECG_DETECTOR_CTRL_AXI_SLV_REG2_OFFSET
#define R_MIN_THRES_REG ECG_DETECTOR_CTRL_AXI_SLV_REG3_OFFSET
#define R_MAX_THRES_REG ECG_DETECTOR_CTRL_AXI_SLV_REG4_OFFSET

//statistic registers
#define R_MAX_REG ECG_DETECTOR_CTRL_AXI_SLV_REG7_OFFSET
#define R_MIN_REG ECG_DETECTOR_CTRL_AXI_SLV_REG8_OFFSET
#define R_MEAN_REG ECG_DETECTOR_CTRL_AXI_SLV_REG9_OFFSET
#define STATUS_REG ECG_DETECTOR_CTRL_AXI_SLV_REG31_OFFSET

//status register masks
#define ECG_ABN_MASK (u32)1
#define COMP_VAL_MASK (u32)2
#define DEBUG_MASK		(u32)4

#endif /* AS_ECG_APPLICATION_PARAM_H_ */
