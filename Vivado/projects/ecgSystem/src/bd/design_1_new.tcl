
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:0.9 [current_project]


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set BTNs_5Bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 BTNs_5Bits ]
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set LEDs_8Bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 LEDs_8Bits ]

  # Create ports

  # Create instance: ECG_Unit_0, and set properties
  set ECG_Unit_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:ECG_Unit:1.4 ECG_Unit_0 ]
  set_property -dict [ list CONFIG.C_M00_AXIS_START_COUNT {1} CONFIG.C_M_FIFO_DEPTH {256} CONFIG.C_S_FIFO_DEPTH {256} CONFIG.C_S_READ_f_FIFO_START_COUNT {1}  ] $ECG_Unit_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list CONFIG.C_INTERRUPT_PRESENT {1} CONFIG.GPIO2_BOARD_INTERFACE {BTNs_5Bits} CONFIG.GPIO_BOARD_INTERFACE {LEDs_8Bits} CONFIG.USE_BOARD_FLOW {true}  ] $axi_gpio_0

  # Create instance: bandPass_fir_0, and set properties
  set bandPass_fir_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 bandPass_fir_0 ]
  set_property -dict [ list CONFIG.BestPrecision {true} CONFIG.Clock_Frequency {50} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File {../../../../../../../src/coe/real_16_PB_1_40.coe} CONFIG.Coefficient_Structure {Symmetric} CONFIG.DATA_Has_TLAST {Packet_Framing} CONFIG.Data_Fractional_Bits {21} CONFIG.Data_Sign {Signed} CONFIG.Data_Width {32} CONFIG.M_DATA_Has_TREADY {true} CONFIG.Output_Rounding_Mode {Truncate_LSBs} CONFIG.Output_Width {32} CONFIG.Quantization {Quantize_Only} CONFIG.RateSpecification {Frequency_Specification} CONFIG.Sample_Frequency {0.0005}  ] $bandPass_fir_0

  # Create instance: broadcast_signal_0, and set properties
  set broadcast_signal_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 broadcast_signal_0 ]

  # Create instance: difference_signal_0, and set properties
  set difference_signal_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 difference_signal_0 ]
  set_property -dict [ list CONFIG.C_USE_RX_CUT_THROUGH {false} CONFIG.C_USE_TX_DATA {0}  ] $difference_signal_0

  # Create instance: differentiator_fir_0, and set properties
  set differentiator_fir_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 differentiator_fir_0 ]
  set_property -dict [ list CONFIG.BestPrecision {true} CONFIG.Clock_Frequency {50} CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File {../../../../../../../src/coe/diff_05_45.coe} CONFIG.DATA_Has_TLAST {Packet_Framing} CONFIG.Data_Fractional_Bits {16} CONFIG.Data_Sign {Signed} CONFIG.Data_Width {32} CONFIG.M_DATA_Has_TREADY {true} CONFIG.Output_Rounding_Mode {Truncate_LSBs} CONFIG.Output_Width {32} CONFIG.Quantization {Quantize_Only} CONFIG.Sample_Frequency {0.0005}  ] $differentiator_fir_0

  # Create instance: noise_free_signal_0, and set properties
  set noise_free_signal_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 noise_free_signal_0 ]
  set_property -dict [ list CONFIG.C_USE_RX_CUT_THROUGH {false} CONFIG.C_USE_TX_DATA {0}  ] $noise_free_signal_0

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_CORE0_FIQ_INTR {1} \
CONFIG.PCW_CORE0_IRQ_INTR {1} CONFIG.PCW_CORE1_FIQ_INTR {1} \
CONFIG.PCW_CORE1_IRQ_INTR {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} CONFIG.PCW_EN_CLK1_PORT {1} \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {0.25} \
CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_MIO_10_PULLUP {disabled} \
CONFIG.PCW_MIO_11_PULLUP {disabled} CONFIG.PCW_P2F_UART0_INTR {1} \
CONFIG.PCW_P2F_UART1_INTR {1} CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
CONFIG.PCW_UART0_UART0_IO {MIO 10 .. 11} CONFIG.PCW_UART1_BAUD_RATE {115200} \
CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} CONFIG.PCW_USE_AXI_FABRIC_IDLE {1} \
CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.preset {ZedBoard*} \
 ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {0} CONFIG.NUM_MI {5}  ] $processing_system7_0_axi_periph

  # Create instance: raw_signal_0, and set properties
  set raw_signal_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 raw_signal_0 ]
  set_property -dict [ list CONFIG.C_HAS_AXIS_TDEST {false} CONFIG.C_USE_RX_DATA {0} CONFIG.C_USE_TX_CTRL {0}  ] $raw_signal_0

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create interface connections
  connect_bd_intf_net -intf_net ECG_Unit_0_M00_AXIS [get_bd_intf_pins ECG_Unit_0/M00_AXIS] [get_bd_intf_pins difference_signal_0/AXI_STR_RXD]
  connect_bd_intf_net -intf_net axi_fifo_mm_s_0_AXI_STR_TXD [get_bd_intf_pins bandPass_fir_0/S_AXIS_DATA] [get_bd_intf_pins raw_signal_0/AXI_STR_TXD]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports LEDs_8Bits] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO2 [get_bd_intf_ports BTNs_5Bits] [get_bd_intf_pins axi_gpio_0/GPIO2]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M00_AXIS [get_bd_intf_pins broadcast_signal_0/M00_AXIS] [get_bd_intf_pins noise_free_signal_0/AXI_STR_RXD]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M01_AXIS [get_bd_intf_pins broadcast_signal_0/M01_AXIS] [get_bd_intf_pins differentiator_fir_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net fir_compiler_0_M_AXIS_DATA [get_bd_intf_pins bandPass_fir_0/M_AXIS_DATA] [get_bd_intf_pins broadcast_signal_0/S_AXIS]
  connect_bd_intf_net -intf_net fir_compiler_0_M_AXIS_DATA1 [get_bd_intf_pins ECG_Unit_0/S00_AXIS] [get_bd_intf_pins differentiator_fir_0/M_AXIS_DATA]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI] [get_bd_intf_pins raw_signal_0/S_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins noise_free_signal_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins ECG_Unit_0/s00_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M04_AXI [get_bd_intf_pins difference_signal_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M04_AXI]

  # Create port connections
  connect_bd_net -net axi_gpio_0_ip2intc_irpt [get_bd_pins axi_gpio_0/ip2intc_irpt] [get_bd_pins processing_system7_0/IRQ_F2P]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins ECG_Unit_0/m00_axis_aclk] [get_bd_pins ECG_Unit_0/s00_axi_aclk] [get_bd_pins ECG_Unit_0/s00_axis_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins bandPass_fir_0/aclk] [get_bd_pins broadcast_signal_0/aclk] [get_bd_pins difference_signal_0/s_axi_aclk] [get_bd_pins differentiator_fir_0/aclk] [get_bd_pins noise_free_signal_0/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins raw_signal_0/s_axi_aclk] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins ECG_Unit_0/m00_axis_aresetn] [get_bd_pins ECG_Unit_0/s00_axi_aresetn] [get_bd_pins ECG_Unit_0/s00_axis_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins broadcast_signal_0/aresetn] [get_bd_pins difference_signal_0/s_axi_aresetn] [get_bd_pins noise_free_signal_0/s_axi_aresetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins raw_signal_0/s_axi_aresetn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x43C20000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs ECG_Unit_0/s00_axi/reg0] SEG_ECG_Unit_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs raw_signal_0/S_AXI/Mem0] SEG_axi_fifo_mm_s_0_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs noise_free_signal_0/S_AXI/Mem0] SEG_axi_fifo_mm_s_1_Mem0
  create_bd_addr_seg -range 0x10000 -offset 0x41200000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C30000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs difference_signal_0/S_AXI/Mem0] SEG_difference_signal_0_Mem0
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


