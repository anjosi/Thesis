

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "ECG_Detector" "NUM_INSTANCES" "DEVICE_ID"  "C_CTRL_AXI_BASEADDR" "C_CTRL_AXI_HIGHADDR"
}
