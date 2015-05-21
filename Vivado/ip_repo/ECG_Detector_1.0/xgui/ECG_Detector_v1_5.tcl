
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/ECG_Detector_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Optional_interfaces [ipgui::add_page $IPINST -name "Optional interfaces" -display_name {Inbound interfaces}]
  ipgui::add_param $IPINST -name "C_G_AXIS_INBOUND_TDATA_WIDTH" -parent ${Optional_interfaces} -widget comboBox
  #Adding Group
  set Noisy_ecg_bus [ipgui::add_group $IPINST -name "Noisy ecg bus" -parent ${Optional_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_S_AXIS_NSY_ENABLE" -parent ${Noisy_ecg_bus}

  #Adding Group
  set De-noised_ecg_bus [ipgui::add_group $IPINST -name "De-noised ecg bus" -parent ${Optional_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_S_AXIS_DE_NSD_ENABLE" -parent ${De-noised_ecg_bus}

  #Adding Group
  set Squared_ecg_bus [ipgui::add_group $IPINST -name "Squared ecg bus" -parent ${Optional_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_S_AXIS_SQ_ENABLE" -parent ${Squared_ecg_bus}

  #Adding Group
  set Integrated_ecg_bus [ipgui::add_group $IPINST -name "Integrated ecg bus" -parent ${Optional_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_S_AXIS_INTEG_ENABLE" -parent ${Integrated_ecg_bus}

  #Adding Group
  set Difference_ecg_bus [ipgui::add_group $IPINST -name "Difference ecg bus" -parent ${Optional_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_S_AXIS_DIFF_ENABLE" -parent ${Difference_ecg_bus}


  #Adding Page
  set Outbound_interfaces [ipgui::add_page $IPINST -name "Outbound interfaces"]
  #Adding Group
  set General [ipgui::add_group $IPINST -name "General" -parent ${Outbound_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_G_AXIS_OUTBOUND_TDATA_WIDTH" -parent ${General} -widget comboBox
  ipgui::add_param $IPINST -name "C_G_AXIS_FIFO_DEPTH" -parent ${General}

  #Adding Group
  set Tx_bus_1 [ipgui::add_group $IPINST -name "Tx bus 1" -parent ${Outbound_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_S_AXIS_TX_1_ENABLE" -parent ${Tx_bus_1}
  ipgui::add_param $IPINST -name "C_TX_SMP_01_AXIS_START_COUNT" -parent ${Tx_bus_1}

  #Adding Group
  set Tx_bus_2 [ipgui::add_group $IPINST -name "Tx bus 2" -parent ${Outbound_interfaces} -layout horizontal]
  ipgui::add_param $IPINST -name "C_S_AXIS_TX_2_ENABLE" -parent ${Tx_bus_2}
  ipgui::add_param $IPINST -name "C_TX_SMP_02_AXIS_START_COUNT" -parent ${Tx_bus_2}


  #Adding Page
  set AXIS_optional_buses [ipgui::add_page $IPINST -name "AXIS optional buses" -display_name {AXIS options}]
  #Adding Group
  set Bus_options [ipgui::add_group $IPINST -name "Bus options" -parent ${AXIS_optional_buses} -layout horizontal]
  #Adding Group
  set TUSER_bus [ipgui::add_group $IPINST -name "TUSER bus" -parent ${Bus_options} -layout horizontal]
  ipgui::add_param $IPINST -name "C_G_AXIS_TUSER_EN" -parent ${TUSER_bus}
  ipgui::add_param $IPINST -name "C_G_AXIS_TUSER_WIDTH" -parent ${TUSER_bus}

  #Adding Group
  set TSTRB [ipgui::add_group $IPINST -name "TSTRB" -parent ${Bus_options} -layout horizontal]
  ipgui::add_param $IPINST -name "C_G_AXIS_TSTRB_EN" -parent ${TSTRB}


  #Adding Group
  set Ctrl_signal_options [ipgui::add_group $IPINST -name "Ctrl signal options" -parent ${AXIS_optional_buses}]
  #Adding Group
  set TLAST_fifo_empty [ipgui::add_group $IPINST -name "TLAST fifo empty" -parent ${Ctrl_signal_options} -layout horizontal]
  ipgui::add_param $IPINST -name "C_G_AXIS_TLAST_FIFO_EMPTY" -parent ${TLAST_fifo_empty}

  #Adding Group
  set TLAST_generate [ipgui::add_group $IPINST -name "TLAST generate" -parent ${Ctrl_signal_options} -layout horizontal]
  ipgui::add_param $IPINST -name "C_G_AXIS_TLAST_GENERATE" -parent ${TLAST_generate}
  ipgui::add_param $IPINST -name "C_G_AXIS_PACKET_LENGTH" -parent ${TLAST_generate}

  #Adding Group
  set TLAST_propagate [ipgui::add_group $IPINST -name "TLAST propagate" -parent ${Ctrl_signal_options} -layout horizontal]
  ipgui::add_param $IPINST -name "C_G_AXIS_TLAST_PROPAGATE" -parent ${TLAST_propagate}



  #Adding Page
  set ECG_Detector [ipgui::add_page $IPINST -name "ECG Detector"]
  ipgui::add_param $IPINST -name "C_G_SYSTEM_CLK" -parent ${ECG_Detector}
  ipgui::add_param $IPINST -name "C_G_SAMPLE_FREQ" -parent ${ECG_Detector}
  ipgui::add_param $IPINST -name "C_ECG_DELAY" -parent ${ECG_Detector}

  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {CTRL bus}]
  ipgui::add_param $IPINST -name "C_CTRL_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CTRL_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CTRL_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CTRL_AXI_HIGHADDR" -parent ${Page_0}

  #Adding Page
  set Interrupts [ipgui::add_page $IPINST -name "Interrupts"]
  ipgui::add_param $IPINST -name "C_S_INTR_ENABLE" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_S_AXI_INTR_DATA_WIDTH" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_S_AXI_INTR_ADDR_WIDTH" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_NUM_OF_INTR" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_INTR_SENSITIVITY" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_INTR_ACTIVE_STATE" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_IRQ_SENSITIVITY" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_IRQ_ACTIVE_STATE" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_S_AXI_INTR_BASEADDR" -parent ${Interrupts}
  ipgui::add_param $IPINST -name "C_S_AXI_INTR_HIGHADDR" -parent ${Interrupts}


}

proc update_PARAM_VALUE.C_ECG_DELAY { PARAM_VALUE.C_ECG_DELAY } {
	# Procedure called to update C_ECG_DELAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ECG_DELAY { PARAM_VALUE.C_ECG_DELAY } {
	# Procedure called to validate C_ECG_DELAY
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_FIFO_DEPTH { PARAM_VALUE.C_G_AXIS_FIFO_DEPTH } {
	# Procedure called to update C_G_AXIS_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_FIFO_DEPTH { PARAM_VALUE.C_G_AXIS_FIFO_DEPTH } {
	# Procedure called to validate C_G_AXIS_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH { PARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH } {
	# Procedure called to update C_G_AXIS_INBOUND_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH { PARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH } {
	# Procedure called to validate C_G_AXIS_INBOUND_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH { PARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH } {
	# Procedure called to update C_G_AXIS_OUTBOUND_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH { PARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH } {
	# Procedure called to validate C_G_AXIS_OUTBOUND_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_PACKET_LENGTH { PARAM_VALUE.C_G_AXIS_PACKET_LENGTH } {
	# Procedure called to update C_G_AXIS_PACKET_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_PACKET_LENGTH { PARAM_VALUE.C_G_AXIS_PACKET_LENGTH } {
	# Procedure called to validate C_G_AXIS_PACKET_LENGTH
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY { PARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY } {
	# Procedure called to update C_G_AXIS_TLAST_FIFO_EMPTY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY { PARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY } {
	# Procedure called to validate C_G_AXIS_TLAST_FIFO_EMPTY
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_TLAST_GENERATE { PARAM_VALUE.C_G_AXIS_TLAST_GENERATE } {
	# Procedure called to update C_G_AXIS_TLAST_GENERATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_TLAST_GENERATE { PARAM_VALUE.C_G_AXIS_TLAST_GENERATE } {
	# Procedure called to validate C_G_AXIS_TLAST_GENERATE
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE { PARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE } {
	# Procedure called to update C_G_AXIS_TLAST_PROPAGATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE { PARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE } {
	# Procedure called to validate C_G_AXIS_TLAST_PROPAGATE
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_TSTRB_EN { PARAM_VALUE.C_G_AXIS_TSTRB_EN } {
	# Procedure called to update C_G_AXIS_TSTRB_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_TSTRB_EN { PARAM_VALUE.C_G_AXIS_TSTRB_EN } {
	# Procedure called to validate C_G_AXIS_TSTRB_EN
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_TUSER_EN { PARAM_VALUE.C_G_AXIS_TUSER_EN } {
	# Procedure called to update C_G_AXIS_TUSER_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_TUSER_EN { PARAM_VALUE.C_G_AXIS_TUSER_EN } {
	# Procedure called to validate C_G_AXIS_TUSER_EN
	return true
}

proc update_PARAM_VALUE.C_G_AXIS_TUSER_WIDTH { PARAM_VALUE.C_G_AXIS_TUSER_WIDTH } {
	# Procedure called to update C_G_AXIS_TUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_AXIS_TUSER_WIDTH { PARAM_VALUE.C_G_AXIS_TUSER_WIDTH } {
	# Procedure called to validate C_G_AXIS_TUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_G_SAMPLE_FREQ { PARAM_VALUE.C_G_SAMPLE_FREQ } {
	# Procedure called to update C_G_SAMPLE_FREQ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_SAMPLE_FREQ { PARAM_VALUE.C_G_SAMPLE_FREQ } {
	# Procedure called to validate C_G_SAMPLE_FREQ
	return true
}

proc update_PARAM_VALUE.C_G_SYSTEM_CLK { PARAM_VALUE.C_G_SYSTEM_CLK } {
	# Procedure called to update C_G_SYSTEM_CLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_G_SYSTEM_CLK { PARAM_VALUE.C_G_SYSTEM_CLK } {
	# Procedure called to validate C_G_SYSTEM_CLK
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE { PARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE } {
	# Procedure called to update C_S_AXIS_DE_NSD_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE { PARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE } {
	# Procedure called to validate C_S_AXIS_DE_NSD_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_DIFF_ENABLE { PARAM_VALUE.C_S_AXIS_DIFF_ENABLE } {
	# Procedure called to update C_S_AXIS_DIFF_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_DIFF_ENABLE { PARAM_VALUE.C_S_AXIS_DIFF_ENABLE } {
	# Procedure called to validate C_S_AXIS_DIFF_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_INTEG_ENABLE { PARAM_VALUE.C_S_AXIS_INTEG_ENABLE } {
	# Procedure called to update C_S_AXIS_INTEG_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_INTEG_ENABLE { PARAM_VALUE.C_S_AXIS_INTEG_ENABLE } {
	# Procedure called to validate C_S_AXIS_INTEG_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_NSY_ENABLE { PARAM_VALUE.C_S_AXIS_NSY_ENABLE } {
	# Procedure called to update C_S_AXIS_NSY_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_NSY_ENABLE { PARAM_VALUE.C_S_AXIS_NSY_ENABLE } {
	# Procedure called to validate C_S_AXIS_NSY_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_SQ_ENABLE { PARAM_VALUE.C_S_AXIS_SQ_ENABLE } {
	# Procedure called to update C_S_AXIS_SQ_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_SQ_ENABLE { PARAM_VALUE.C_S_AXIS_SQ_ENABLE } {
	# Procedure called to validate C_S_AXIS_SQ_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_TX_1_ENABLE { PARAM_VALUE.C_S_AXIS_TX_1_ENABLE } {
	# Procedure called to update C_S_AXIS_TX_1_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_TX_1_ENABLE { PARAM_VALUE.C_S_AXIS_TX_1_ENABLE } {
	# Procedure called to validate C_S_AXIS_TX_1_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_AXIS_TX_2_ENABLE { PARAM_VALUE.C_S_AXIS_TX_2_ENABLE } {
	# Procedure called to update C_S_AXIS_TX_2_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXIS_TX_2_ENABLE { PARAM_VALUE.C_S_AXIS_TX_2_ENABLE } {
	# Procedure called to validate C_S_AXIS_TX_2_ENABLE
	return true
}

proc update_PARAM_VALUE.C_S_INTR_ENABLE { PARAM_VALUE.C_S_INTR_ENABLE } {
	# Procedure called to update C_S_INTR_ENABLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_INTR_ENABLE { PARAM_VALUE.C_S_INTR_ENABLE } {
	# Procedure called to validate C_S_INTR_ENABLE
	return true
}

proc update_PARAM_VALUE.C_CTRL_AXI_DATA_WIDTH { PARAM_VALUE.C_CTRL_AXI_DATA_WIDTH } {
	# Procedure called to update C_CTRL_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CTRL_AXI_DATA_WIDTH { PARAM_VALUE.C_CTRL_AXI_DATA_WIDTH } {
	# Procedure called to validate C_CTRL_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH { PARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH } {
	# Procedure called to update C_CTRL_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH { PARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_CTRL_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_CTRL_AXI_BASEADDR { PARAM_VALUE.C_CTRL_AXI_BASEADDR } {
	# Procedure called to update C_CTRL_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CTRL_AXI_BASEADDR { PARAM_VALUE.C_CTRL_AXI_BASEADDR } {
	# Procedure called to validate C_CTRL_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_CTRL_AXI_HIGHADDR { PARAM_VALUE.C_CTRL_AXI_HIGHADDR } {
	# Procedure called to update C_CTRL_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CTRL_AXI_HIGHADDR { PARAM_VALUE.C_CTRL_AXI_HIGHADDR } {
	# Procedure called to validate C_CTRL_AXI_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT { PARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT } {
	# Procedure called to update C_TX_SMP_01_AXIS_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT { PARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT } {
	# Procedure called to validate C_TX_SMP_01_AXIS_START_COUNT
	return true
}

proc update_PARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT { PARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT } {
	# Procedure called to update C_TX_SMP_02_AXIS_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT { PARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT } {
	# Procedure called to validate C_TX_SMP_02_AXIS_START_COUNT
	return true
}

proc update_PARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH { PARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_INTR_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH { PARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_INTR_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_INTR_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_INTR_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_NUM_OF_INTR { PARAM_VALUE.C_NUM_OF_INTR } {
	# Procedure called to update C_NUM_OF_INTR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_NUM_OF_INTR { PARAM_VALUE.C_NUM_OF_INTR } {
	# Procedure called to validate C_NUM_OF_INTR
	return true
}

proc update_PARAM_VALUE.C_INTR_SENSITIVITY { PARAM_VALUE.C_INTR_SENSITIVITY } {
	# Procedure called to update C_INTR_SENSITIVITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INTR_SENSITIVITY { PARAM_VALUE.C_INTR_SENSITIVITY } {
	# Procedure called to validate C_INTR_SENSITIVITY
	return true
}

proc update_PARAM_VALUE.C_INTR_ACTIVE_STATE { PARAM_VALUE.C_INTR_ACTIVE_STATE } {
	# Procedure called to update C_INTR_ACTIVE_STATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_INTR_ACTIVE_STATE { PARAM_VALUE.C_INTR_ACTIVE_STATE } {
	# Procedure called to validate C_INTR_ACTIVE_STATE
	return true
}

proc update_PARAM_VALUE.C_IRQ_SENSITIVITY { PARAM_VALUE.C_IRQ_SENSITIVITY } {
	# Procedure called to update C_IRQ_SENSITIVITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_IRQ_SENSITIVITY { PARAM_VALUE.C_IRQ_SENSITIVITY } {
	# Procedure called to validate C_IRQ_SENSITIVITY
	return true
}

proc update_PARAM_VALUE.C_IRQ_ACTIVE_STATE { PARAM_VALUE.C_IRQ_ACTIVE_STATE } {
	# Procedure called to update C_IRQ_ACTIVE_STATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_IRQ_ACTIVE_STATE { PARAM_VALUE.C_IRQ_ACTIVE_STATE } {
	# Procedure called to validate C_IRQ_ACTIVE_STATE
	return true
}

proc update_PARAM_VALUE.C_S_AXI_INTR_BASEADDR { PARAM_VALUE.C_S_AXI_INTR_BASEADDR } {
	# Procedure called to update C_S_AXI_INTR_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_INTR_BASEADDR { PARAM_VALUE.C_S_AXI_INTR_BASEADDR } {
	# Procedure called to validate C_S_AXI_INTR_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_INTR_HIGHADDR { PARAM_VALUE.C_S_AXI_INTR_HIGHADDR } {
	# Procedure called to update C_S_AXI_INTR_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_INTR_HIGHADDR { PARAM_VALUE.C_S_AXI_INTR_HIGHADDR } {
	# Procedure called to validate C_S_AXI_INTR_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_INTR_ENABLE { MODELPARAM_VALUE.C_S_INTR_ENABLE PARAM_VALUE.C_S_INTR_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_INTR_ENABLE}] ${MODELPARAM_VALUE.C_S_INTR_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_NSY_ENABLE { MODELPARAM_VALUE.C_S_AXIS_NSY_ENABLE PARAM_VALUE.C_S_AXIS_NSY_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_NSY_ENABLE}] ${MODELPARAM_VALUE.C_S_AXIS_NSY_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE { MODELPARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE PARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE}] ${MODELPARAM_VALUE.C_S_AXIS_DE_NSD_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_DIFF_ENABLE { MODELPARAM_VALUE.C_S_AXIS_DIFF_ENABLE PARAM_VALUE.C_S_AXIS_DIFF_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_DIFF_ENABLE}] ${MODELPARAM_VALUE.C_S_AXIS_DIFF_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_SQ_ENABLE { MODELPARAM_VALUE.C_S_AXIS_SQ_ENABLE PARAM_VALUE.C_S_AXIS_SQ_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_SQ_ENABLE}] ${MODELPARAM_VALUE.C_S_AXIS_SQ_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_INTEG_ENABLE { MODELPARAM_VALUE.C_S_AXIS_INTEG_ENABLE PARAM_VALUE.C_S_AXIS_INTEG_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_INTEG_ENABLE}] ${MODELPARAM_VALUE.C_S_AXIS_INTEG_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_TX_1_ENABLE { MODELPARAM_VALUE.C_S_AXIS_TX_1_ENABLE PARAM_VALUE.C_S_AXIS_TX_1_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_TX_1_ENABLE}] ${MODELPARAM_VALUE.C_S_AXIS_TX_1_ENABLE}
}

proc update_MODELPARAM_VALUE.C_S_AXIS_TX_2_ENABLE { MODELPARAM_VALUE.C_S_AXIS_TX_2_ENABLE PARAM_VALUE.C_S_AXIS_TX_2_ENABLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXIS_TX_2_ENABLE}] ${MODELPARAM_VALUE.C_S_AXIS_TX_2_ENABLE}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_TUSER_EN { MODELPARAM_VALUE.C_G_AXIS_TUSER_EN PARAM_VALUE.C_G_AXIS_TUSER_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_TUSER_EN}] ${MODELPARAM_VALUE.C_G_AXIS_TUSER_EN}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_TUSER_WIDTH { MODELPARAM_VALUE.C_G_AXIS_TUSER_WIDTH PARAM_VALUE.C_G_AXIS_TUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_TUSER_WIDTH}] ${MODELPARAM_VALUE.C_G_AXIS_TUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_TSTRB_EN { MODELPARAM_VALUE.C_G_AXIS_TSTRB_EN PARAM_VALUE.C_G_AXIS_TSTRB_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_TSTRB_EN}] ${MODELPARAM_VALUE.C_G_AXIS_TSTRB_EN}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE { MODELPARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE PARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE}] ${MODELPARAM_VALUE.C_G_AXIS_TLAST_PROPAGATE}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_TLAST_GENERATE { MODELPARAM_VALUE.C_G_AXIS_TLAST_GENERATE PARAM_VALUE.C_G_AXIS_TLAST_GENERATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_TLAST_GENERATE}] ${MODELPARAM_VALUE.C_G_AXIS_TLAST_GENERATE}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_PACKET_LENGTH { MODELPARAM_VALUE.C_G_AXIS_PACKET_LENGTH PARAM_VALUE.C_G_AXIS_PACKET_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_PACKET_LENGTH}] ${MODELPARAM_VALUE.C_G_AXIS_PACKET_LENGTH}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY { MODELPARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY PARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY}] ${MODELPARAM_VALUE.C_G_AXIS_TLAST_FIFO_EMPTY}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_FIFO_DEPTH { MODELPARAM_VALUE.C_G_AXIS_FIFO_DEPTH PARAM_VALUE.C_G_AXIS_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_FIFO_DEPTH}] ${MODELPARAM_VALUE.C_G_AXIS_FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.C_G_SYSTEM_CLK { MODELPARAM_VALUE.C_G_SYSTEM_CLK PARAM_VALUE.C_G_SYSTEM_CLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_SYSTEM_CLK}] ${MODELPARAM_VALUE.C_G_SYSTEM_CLK}
}

proc update_MODELPARAM_VALUE.C_G_SAMPLE_FREQ { MODELPARAM_VALUE.C_G_SAMPLE_FREQ PARAM_VALUE.C_G_SAMPLE_FREQ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_SAMPLE_FREQ}] ${MODELPARAM_VALUE.C_G_SAMPLE_FREQ}
}

proc update_MODELPARAM_VALUE.C_ECG_DELAY { MODELPARAM_VALUE.C_ECG_DELAY PARAM_VALUE.C_ECG_DELAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ECG_DELAY}] ${MODELPARAM_VALUE.C_ECG_DELAY}
}

proc update_MODELPARAM_VALUE.C_CTRL_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_CTRL_AXI_DATA_WIDTH PARAM_VALUE.C_CTRL_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CTRL_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_CTRL_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH PARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_CTRL_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH { MODELPARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH PARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_G_AXIS_INBOUND_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH { MODELPARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH PARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_G_AXIS_OUTBOUND_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT { MODELPARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT PARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT}] ${MODELPARAM_VALUE.C_TX_SMP_01_AXIS_START_COUNT}
}

proc update_MODELPARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT { MODELPARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT PARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT}] ${MODELPARAM_VALUE.C_TX_SMP_02_AXIS_START_COUNT}
}

proc update_MODELPARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH PARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_INTR_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH PARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_INTR_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_NUM_OF_INTR { MODELPARAM_VALUE.C_NUM_OF_INTR PARAM_VALUE.C_NUM_OF_INTR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_NUM_OF_INTR}] ${MODELPARAM_VALUE.C_NUM_OF_INTR}
}

proc update_MODELPARAM_VALUE.C_INTR_SENSITIVITY { MODELPARAM_VALUE.C_INTR_SENSITIVITY PARAM_VALUE.C_INTR_SENSITIVITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INTR_SENSITIVITY}] ${MODELPARAM_VALUE.C_INTR_SENSITIVITY}
}

proc update_MODELPARAM_VALUE.C_INTR_ACTIVE_STATE { MODELPARAM_VALUE.C_INTR_ACTIVE_STATE PARAM_VALUE.C_INTR_ACTIVE_STATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_INTR_ACTIVE_STATE}] ${MODELPARAM_VALUE.C_INTR_ACTIVE_STATE}
}

proc update_MODELPARAM_VALUE.C_IRQ_SENSITIVITY { MODELPARAM_VALUE.C_IRQ_SENSITIVITY PARAM_VALUE.C_IRQ_SENSITIVITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_IRQ_SENSITIVITY}] ${MODELPARAM_VALUE.C_IRQ_SENSITIVITY}
}

proc update_MODELPARAM_VALUE.C_IRQ_ACTIVE_STATE { MODELPARAM_VALUE.C_IRQ_ACTIVE_STATE PARAM_VALUE.C_IRQ_ACTIVE_STATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_IRQ_ACTIVE_STATE}] ${MODELPARAM_VALUE.C_IRQ_ACTIVE_STATE}
}

