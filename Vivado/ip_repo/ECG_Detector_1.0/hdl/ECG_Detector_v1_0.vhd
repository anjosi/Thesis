library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ecg_components.all;

entity ECG_Detector_v1_0 is
  generic (
    -- Users to add parameters here
    C_S_INTR_ENABLE        : boolean := false;
    C_S_AXIS_NSY_ENABLE    : boolean := false;
    C_S_AXIS_DE_NSD_ENABLE : boolean := true;
    C_S_AXIS_DIFF_ENABLE   : boolean := true;
    C_S_AXIS_SQ_ENABLE     : boolean := false;
    C_S_AXIS_INTEG_ENABLE  : boolean := false;
    C_S_AXIS_TX_1_ENABLE   : boolean := true;
    C_S_AXIS_TX_2_ENABLE   : boolean := false;

    --TSTRB en
    C_G_AXIS_TUSER_EN         : boolean := false;
    C_G_AXIS_TUSER_WIDTH      : integer := 8;
    C_G_AXIS_TSTRB_EN         : boolean := false;
    C_G_AXIS_TLAST_PROPAGATE  : boolean := true;
    C_G_AXIS_TLAST_GENERATE   : boolean := false;
    C_G_AXIS_PACKET_LENGTH    : integer := 32;
    C_G_AXIS_TLAST_FIFO_EMPTY : boolean := false;
    C_G_AXIS_FIFO_DEPTH       : integer := 256;

    C_G_SYSTEM_CLK    : integer := 50000000;
    C_G_SAMPLE_FREQ   : integer := 500;
	C_ECG_DELAY		  : integer := 29;
	C_STAT_BUFFER_WINDOW : integer := 10;

    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface CTRL_AXI
    C_CTRL_AXI_DATA_WIDTH : integer := 32;
    C_CTRL_AXI_ADDR_WIDTH : integer := 7;

    -- Streaming bus data width
    C_G_AXIS_INBOUND_TDATA_WIDTH  : integer := 32;
    C_G_AXIS_OUTBOUND_TDATA_WIDTH : integer := 32;

    -- Parameters of Axi Master Bus Interface TX_SMP_01_AXIS
    C_TX_SMP_01_AXIS_START_COUNT : integer := 32;

    -- Parameters of Axi Master Bus Interface TX_SMP_02_AXIS
    C_TX_SMP_02_AXIS_START_COUNT : integer := 32;

    -- Parameters of Axi Slave Bus Interface S_AXI_INTR
    C_S_AXI_INTR_DATA_WIDTH : integer          := 32;
    C_S_AXI_INTR_ADDR_WIDTH : integer          := 5;
    C_NUM_OF_INTR           : integer          := 1;
    C_INTR_SENSITIVITY      : std_logic_vector := x"FFFFFFFF";
    C_INTR_ACTIVE_STATE     : std_logic_vector := x"FFFFFFFF";
    C_IRQ_SENSITIVITY       : integer          := 1;
    C_IRQ_ACTIVE_STATE      : integer          := 1
    );
  port (
    -- Users to add ports here
    aclk    : in std_logic;
    aresetn : in std_logic;
    -- User ports ends
    -- Do not modify the ports beyond this line


    -- Ports of Axi Slave Bus Interface CTRL_AXI
--              ctrl_axi_aclk   : in std_logic;
--              ctrl_axi_aresetn        : in std_logic;
    ctrl_axi_awaddr  : in  std_logic_vector(C_CTRL_AXI_ADDR_WIDTH-1 downto 0)     := (others => '0');
    ctrl_axi_awprot  : in  std_logic_vector(2 downto 0)                           := (others => '0');
    ctrl_axi_awvalid : in  std_logic                                              := '0';
    ctrl_axi_awready : out std_logic;
    ctrl_axi_wdata   : in  std_logic_vector(C_CTRL_AXI_DATA_WIDTH-1 downto 0)     := (others => '0');
    ctrl_axi_wstrb   : in  std_logic_vector((C_CTRL_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '0');
    ctrl_axi_wvalid  : in  std_logic                                              := '0';
    ctrl_axi_wready  : out std_logic;
    ctrl_axi_bresp   : out std_logic_vector(1 downto 0);
    ctrl_axi_bvalid  : out std_logic;
    ctrl_axi_bready  : in  std_logic                                              := '0';
    ctrl_axi_araddr  : in  std_logic_vector(C_CTRL_AXI_ADDR_WIDTH-1 downto 0)     := (others => '0');
    ctrl_axi_arprot  : in  std_logic_vector(2 downto 0)                           := (others => '0');
    ctrl_axi_arvalid : in  std_logic                                              := '0';
    ctrl_axi_arready : out std_logic;
    ctrl_axi_rdata   : out std_logic_vector(C_CTRL_AXI_DATA_WIDTH-1 downto 0);
    ctrl_axi_rresp   : out std_logic_vector(1 downto 0);
    ctrl_axi_rvalid  : out std_logic;
    ctrl_axi_rready  : in  std_logic                                              := '0';

    -- Ports of Axi Slave Bus Interface DE_NSD_IN_AXIS
--              de_nsd_in_axis_aclk     : in std_logic;
--              de_nsd_in_axis_aresetn  : in std_logic;
    de_nsd_in_axis_tready : out std_logic;
    de_nsd_in_axis_tdata  : in  std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0)     := (others => '0');
    de_nsd_in_axis_tstrb  : in  std_logic_vector((C_G_AXIS_INBOUND_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    de_nsd_in_axis_tlast  : in  std_logic                                                     := '0';
    de_nsd_in_axis_tvalid : in  std_logic                                                     := '0';

    -- Ports of Axi Slave Bus Interface NSY_IN_AXIS
--              nsy_in_axis_aclk        : in std_logic;
--              nsy_in_axis_aresetn     : in std_logic;
    nsy_in_axis_tready : out std_logic;
    nsy_in_axis_tdata  : in  std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0)     := (others => '0');
    nsy_in_axis_tstrb  : in  std_logic_vector((C_G_AXIS_INBOUND_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    nsy_in_axis_tlast  : in  std_logic                                                     := '0';
    nsy_in_axis_tvalid : in  std_logic                                                     := '0';

    -- Ports of Axi Slave Bus Interface SQR_IN_AXIS
--              sqr_in_axis_aclk        : in std_logic;
--              sqr_in_axis_aresetn     : in std_logic;
    sqr_in_axis_tready : out std_logic;
    sqr_in_axis_tdata  : in  std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0)     := (others => '0');
    sqr_in_axis_tstrb  : in  std_logic_vector((C_G_AXIS_INBOUND_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    sqr_in_axis_tlast  : in  std_logic                                                     := '0';
    sqr_in_axis_tvalid : in  std_logic                                                     := '0';

    -- Ports of Axi Slave Bus Interface DIFF_IN_AXIS
--              diff_in_axis_aclk       : in std_logic;
--              diff_in_axis_aresetn    : in std_logic;
    diff_in_axis_tready : out std_logic;
    diff_in_axis_tdata  : in  std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0)     := (others => '0');
    diff_in_axis_tstrb  : in  std_logic_vector((C_G_AXIS_INBOUND_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    diff_in_axis_tlast  : in  std_logic                                                     := '0';
    diff_in_axis_tvalid : in  std_logic                                                     := '0';

    -- Ports of Axi Slave Bus Interface INTEG_IN_AXIS
--              integ_in_axis_aclk      : in std_logic;
--              integ_in_axis_aresetn   : in std_logic;
    integ_in_axis_tready : out std_logic;
    integ_in_axis_tdata  : in  std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0)     := (others => '0');
    integ_in_axis_tstrb  : in  std_logic_vector((C_G_AXIS_INBOUND_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    integ_in_axis_tlast  : in  std_logic                                                     := '0';
    integ_in_axis_tvalid : in  std_logic                                                     := '0';

    -- Ports of Axi Master Bus Interface TX_SMP_01_AXIS
--              tx_smp_01_axis_aclk     : in std_logic;
--              tx_smp_01_axis_aresetn  : in std_logic;
    tx_smp_01_axis_tvalid : out std_logic;
    tx_smp_01_axis_tdata  : out std_logic_vector(C_G_AXIS_OUTBOUND_TDATA_WIDTH-1 downto 0);
    tx_smp_01_axis_tstrb  : out std_logic_vector((C_G_AXIS_OUTBOUND_TDATA_WIDTH/8)-1 downto 0);
    tx_smp_01_axis_tlast  : out std_logic;
    tx_smp_01_axis_tready : in  std_logic := '0';

    -- Ports of Axi Master Bus Interface TX_SMP_02_AXIS
--              tx_smp_02_axis_aclk     : in std_logic;
--              tx_smp_02_axis_aresetn  : in std_logic;
    tx_smp_02_axis_tvalid : out std_logic;
    tx_smp_02_axis_tdata  : out std_logic_vector(C_G_AXIS_OUTBOUND_TDATA_WIDTH-1 downto 0);
    tx_smp_02_axis_tstrb  : out std_logic_vector((C_G_AXIS_OUTBOUND_TDATA_WIDTH/8)-1 downto 0);
    tx_smp_02_axis_tlast  : out std_logic;
    tx_smp_02_axis_tready : in  std_logic := '0';

    -- Ports of Axi Slave Bus Interface S_AXI_INTR
--              s_axi_intr_aclk : in std_logic;
--              s_axi_intr_aresetn      : in std_logic;
    s_axi_intr_awaddr  : in  std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0)     := (others => '0');
    s_axi_intr_awprot  : in  std_logic_vector(2 downto 0)                             := (others => '0');
    s_axi_intr_awvalid : in  std_logic                                                := '0';
    s_axi_intr_awready : out std_logic;
    s_axi_intr_wdata   : in  std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0)     := (others => '0');
    s_axi_intr_wstrb   : in  std_logic_vector((C_S_AXI_INTR_DATA_WIDTH/8)-1 downto 0) := (others => '0');
    s_axi_intr_wvalid  : in  std_logic                                                := '0';
    s_axi_intr_wready  : out std_logic;
    s_axi_intr_bresp   : out std_logic_vector(1 downto 0);
    s_axi_intr_bvalid  : out std_logic;
    s_axi_intr_bready  : in  std_logic                                                := '0';
    s_axi_intr_araddr  : in  std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0)     := (others => '0');
    s_axi_intr_arprot  : in  std_logic_vector(2 downto 0)                             := (others => '0');
    s_axi_intr_arvalid : in  std_logic                                                := '0';
    s_axi_intr_arready : out std_logic;
    s_axi_intr_rdata   : out std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
    s_axi_intr_rresp   : out std_logic_vector(1 downto 0);
    s_axi_intr_rvalid  : out std_logic;
    s_axi_intr_rready  : in  std_logic                                                := '0';
    irq                : out std_logic
    );
end ECG_Detector_v1_0;

architecture arch_imp of ECG_Detector_v1_0 is

  signal integrator_to_qrs_tdata, qrs_to_tx2_tdata, ctrlAxi_to_qrs_thresh_data : std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0);
  signal ctrlAxi_to_r_thresh_data : std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0);
  signal wave_detector_to_ctrl_peak_data, wave_detector_to_tx2_peak_data : std_logic_vector(C_G_AXIS_INBOUND_TDATA_WIDTH-1 downto 0);
  signal to_tx1_x, delay_to_tx1_tdata                              : std_logic_vector(C_G_AXIS_OUTBOUND_TDATA_WIDTH-1 downto 0);
  signal qrs_to_ctrlAxi_thresh_addr, r_to_ctrlAxi_thresh_addr, peakDet_to_Stat_wr_addr_r					   		: std_logic_vector(C_CTRL_AXI_ADDR_WIDTH-1 downto 0);
  signal diff_to_tx1_tready                                        : std_logic;
  signal diff_to_tx1_tvalid                                        : std_logic;
  signal diff_to_tx1_tlast                                         : std_logic;
  signal qrs_detected_x												: std_logic;
  signal ecg_abn_r													: std_logic;
  signal diff_to_integrator_sample_valid, deNsd_to_ecgDelay_sample_valid                           : std_logic;
  signal wave_detector_to_ctrl_peak_data_valid, wave_detector_to_tx2_peak_data_valid						: std_logic;
  type BYTE_FIFO_TYPE is array (0 to (C_ECG_DELAY-1)) of std_logic_vector(7 downto 0);

  -- component declaration
  component ECG_Detector_v1_0_CTRL_AXI is
    generic (
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 7;
   	  C_S_AXI_STAT_BUFFER_WINDOW : integer := 10
     );
    port (
	  S_AXI_QRS_DETECTED_IN	: in std_logic;
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
	  S_AXI_STATVALID : in std_logic;
	  S_AXI_ECG_ABN	: in std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	  S_AXI_THRESH_ADDR_QRS_IN	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	  S_AXI_THRESH_RD_ADDR_R_IN	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	  S_AXI_STAT_WR_ADDR_R_IN	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	  S_AXI_THRESH_DATA_QRS_OUT	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	  S_AXI_THRESH_DATA_R_OUT	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	  S_AXI_STAT_DATA_R_IN	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic
      );
  end component ECG_Detector_v1_0_CTRL_AXI;

  component ECG_Detector_v1_0_S_AXI_INTR is
    generic (
      C_S_AXI_DATA_WIDTH  : integer          := 32;
      C_S_AXI_ADDR_WIDTH  : integer          := 5;
      C_NUM_OF_INTR       : integer          := 1;
      C_INTR_SENSITIVITY  : std_logic_vector := x"FFFFFFFF";
      C_INTR_ACTIVE_STATE : std_logic_vector := x"FFFFFFFF";
      C_IRQ_SENSITIVITY   : integer          := 1;
      C_IRQ_ACTIVE_STATE  : integer          := 1
      );
    port (
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic;
      irq           : out std_logic
      );
  end component ECG_Detector_v1_0_S_AXI_INTR;

begin

-- Instantiation of Axi Bus Interface CTRL_AXI
  ECG_Detector_v1_0_CTRL_AXI_inst : ECG_Detector_v1_0_CTRL_AXI
    generic map (
      C_S_AXI_DATA_WIDTH => C_CTRL_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_CTRL_AXI_ADDR_WIDTH,
	  C_S_AXI_STAT_BUFFER_WINDOW => C_STAT_BUFFER_WINDOW
      )
    port map (
	  S_AXI_QRS_DETECTED_IN => qrs_detected_x,
      S_AXI_ACLK    => aclk,
      S_AXI_ARESETN => aresetn,
      S_AXI_AWADDR  => ctrl_axi_awaddr,
      S_AXI_AWPROT  => ctrl_axi_awprot,
      S_AXI_AWVALID => ctrl_axi_awvalid,
      S_AXI_AWREADY => ctrl_axi_awready,
	  S_AXI_STATVALID => wave_detector_to_ctrl_peak_data_valid,
	  S_AXI_ECG_ABN => ecg_abn_r,
      S_AXI_WDATA   => ctrl_axi_wdata,
      S_AXI_WSTRB   => ctrl_axi_wstrb,
      S_AXI_WVALID  => ctrl_axi_wvalid,
      S_AXI_WREADY  => ctrl_axi_wready,
      S_AXI_BRESP   => ctrl_axi_bresp,
      S_AXI_BVALID  => ctrl_axi_bvalid,
      S_AXI_BREADY  => ctrl_axi_bready,
      S_AXI_ARADDR  => ctrl_axi_araddr,
	  S_AXI_THRESH_ADDR_QRS_IN => qrs_to_ctrlAxi_thresh_addr,
	  S_AXI_THRESH_RD_ADDR_R_IN => r_to_ctrlAxi_thresh_addr,
	  S_AXI_STAT_WR_ADDR_R_IN => peakDet_to_Stat_wr_addr_r,
      S_AXI_ARPROT  => ctrl_axi_arprot,
      S_AXI_ARVALID => ctrl_axi_arvalid,
      S_AXI_ARREADY => ctrl_axi_arready,
      S_AXI_RDATA   => ctrl_axi_rdata,
	  S_AXI_THRESH_DATA_QRS_OUT => ctrlAxi_to_qrs_thresh_data,
 	  S_AXI_THRESH_DATA_R_OUT => ctrlAxi_to_r_thresh_data,
	  S_AXI_STAT_DATA_R_IN => wave_detector_to_ctrl_peak_data,
      S_AXI_RRESP   => ctrl_axi_rresp,
      S_AXI_RVALID  => ctrl_axi_rvalid,
      S_AXI_RREADY  => ctrl_axi_rready
      );

-- Instantiation of Axi Bus Interface DE_NSD_IN_AXIS
  de_nsd_in_axis : axis_fifo
    generic map (
      C_FIFO_DEPTH       => C_G_AXIS_FIFO_DEPTH,
      C_AXIS_TUSER_WIDTH => C_G_AXIS_TUSER_WIDTH,
      TUSER_EN           => C_G_AXIS_TUSER_EN,
      TSTRB_EN           => C_G_AXIS_TSTRB_EN,
      TLAST_EN           => C_G_AXIS_TLAST_FIFO_EMPTY,
      TLAST_GEN          => C_G_AXIS_TLAST_GENERATE,
      TLAST_PROP         => C_G_AXIS_TLAST_PROPAGATE,
      PACKET_LENGTH      => C_G_AXIS_PACKET_LENGTH,
      SYSTEM_CLK_FREQ    => C_G_SYSTEM_CLK,
      SAMPLE_FREQ        => C_G_SAMPLE_FREQ,
      C_AXIS_TDATA_WIDTH => C_G_AXIS_INBOUND_TDATA_WIDTH,
      C_M_START_COUNT    => C_TX_SMP_01_AXIS_START_COUNT
      )
    port map (
      -- Users to add ports here
      -- Ready to accept data in
      S_AXIS_TREADY => de_nsd_in_axis_tready,
      -- Data in
      S_AXIS_TDATA  => de_nsd_in_axis_tdata,
      -- Byte qualifier
      S_AXIS_TSTRB  => de_nsd_in_axis_tstrb,
      -- Indicates boundary of last packet
      S_AXIS_TLAST  => de_nsd_in_axis_tlast,
      -- Data is in valid
      S_AXIS_TVALID => de_nsd_in_axis_tvalid,

      S_AXIS_TUSER => open,
      M_AXIS_TUSER => open,
      SAMPLE_VALID => deNsd_to_ecgDelay_sample_valid,
      -- User ports ends
      -- Do not modify the ports beyond this line

      -- Global ports
      AXIS_ACLK     => aclk,
      -- 
      AXIS_ARESETN  => aresetn,
      -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
      M_AXIS_TVALID => tx_smp_01_axis_tvalid,
      -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
      M_AXIS_TDATA  => to_tx1_x,
      -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
      M_AXIS_TSTRB  => tx_smp_01_axis_tstrb,
      -- TLAST indicates the boundary of a packet.
      M_AXIS_TLAST  => tx_smp_01_axis_tlast,
      -- TREADY indicates that the slave can accept a transfer in the current cycle.
      M_AXIS_TREADY => tx_smp_01_axis_tready
      );

-- Instantiation of Axi Bus Interface NSY_IN_AXIS
-- Instantiation of Axi Bus Interface SQR_IN_AXIS
-- Instantiation of Axi Bus Interface DIFF_IN_AXIS
  diff_in_axis : axis_fifo
    generic map (
      C_FIFO_DEPTH       => C_G_AXIS_FIFO_DEPTH,
      C_AXIS_TUSER_WIDTH => C_G_AXIS_TUSER_WIDTH,
      TUSER_EN           => C_G_AXIS_TUSER_EN,
      TSTRB_EN           => C_G_AXIS_TSTRB_EN,
      TLAST_EN           => C_G_AXIS_TLAST_FIFO_EMPTY,
      TLAST_GEN          => C_G_AXIS_TLAST_GENERATE,
      TLAST_PROP         => C_G_AXIS_TLAST_PROPAGATE,
      PACKET_LENGTH      => C_G_AXIS_PACKET_LENGTH,
      SYSTEM_CLK_FREQ    => C_G_SYSTEM_CLK,
      SAMPLE_FREQ        => C_G_SAMPLE_FREQ,
      C_AXIS_TDATA_WIDTH => C_G_AXIS_INBOUND_TDATA_WIDTH,
      C_M_START_COUNT    => C_TX_SMP_02_AXIS_START_COUNT
      )
    port map (
      -- Users to add ports here
      -- Ready to accept data in
      S_AXIS_TREADY => diff_in_axis_tready,
      -- Data in
      S_AXIS_TDATA  => qrs_to_tx2_tdata,
      -- Byte qualifier
      S_AXIS_TSTRB  => diff_in_axis_tstrb,
      -- Indicates boundary of last packet
      S_AXIS_TLAST  => diff_in_axis_tlast,
      -- Data is in valid
      S_AXIS_TVALID => diff_in_axis_tvalid,

      S_AXIS_TUSER => open,
      M_AXIS_TUSER => open,
      SAMPLE_VALID => diff_to_integrator_sample_valid,
      -- User ports ends
      -- Do not modify the ports beyond this line

      -- Global ports
      AXIS_ACLK     => aclk,
      -- 
      AXIS_ARESETN  => aresetn,
      -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
      M_AXIS_TVALID => tx_smp_02_axis_tvalid,
      -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
      M_AXIS_TDATA  => tx_smp_02_axis_tdata,
      -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
      M_AXIS_TSTRB  => tx_smp_02_axis_tstrb,
      -- TLAST indicates the boundary of a packet.
      M_AXIS_TLAST  => tx_smp_02_axis_tlast,
      -- TREADY indicates that the slave can accept a transfer in the current cycle.
      M_AXIS_TREADY => tx_smp_02_axis_tready
      );


-- Instantiation of Axi Bus Interface INTEG_IN_AXIS
-- Instantiation of Axi Bus Interface TX_SMP_01_AXIS
-- Instantiation of Axi Bus Interface TX_SMP_02_AXIS
-- Instantiation of Axi Bus Interface S_AXI_INTR
  ECG_Detector_v1_0_S_AXI_INTR_inst : ECG_Detector_v1_0_S_AXI_INTR
    generic map (
      C_S_AXI_DATA_WIDTH  => C_S_AXI_INTR_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH  => C_S_AXI_INTR_ADDR_WIDTH,
      C_NUM_OF_INTR       => C_NUM_OF_INTR,
      C_INTR_SENSITIVITY  => C_INTR_SENSITIVITY,
      C_INTR_ACTIVE_STATE => C_INTR_ACTIVE_STATE,
      C_IRQ_SENSITIVITY   => C_IRQ_SENSITIVITY,
      C_IRQ_ACTIVE_STATE  => C_IRQ_ACTIVE_STATE
      )
    port map (
      S_AXI_ACLK    => aclk,
      S_AXI_ARESETN => aresetn,
      S_AXI_AWADDR  => s_axi_intr_awaddr,
      S_AXI_AWPROT  => s_axi_intr_awprot,
      S_AXI_AWVALID => s_axi_intr_awvalid,
      S_AXI_AWREADY => s_axi_intr_awready,
      S_AXI_WDATA   => s_axi_intr_wdata,
      S_AXI_WSTRB   => s_axi_intr_wstrb,
      S_AXI_WVALID  => s_axi_intr_wvalid,
      S_AXI_WREADY  => s_axi_intr_wready,
      S_AXI_BRESP   => s_axi_intr_bresp,
      S_AXI_BVALID  => s_axi_intr_bvalid,
      S_AXI_BREADY  => s_axi_intr_bready,
      S_AXI_ARADDR  => s_axi_intr_araddr,
      S_AXI_ARPROT  => s_axi_intr_arprot,
      S_AXI_ARVALID => s_axi_intr_arvalid,
      S_AXI_ARREADY => s_axi_intr_arready,
      S_AXI_RDATA   => s_axi_intr_rdata,
      S_AXI_RRESP   => s_axi_intr_rresp,
      S_AXI_RVALID  => s_axi_intr_rvalid,
      S_AXI_RREADY  => s_axi_intr_rready,
      irq           => irq
      );

  -- Add user logic here
  square_integrator : multiplier generic map (
    MUL_DATA_WIDTH => C_G_AXIS_INBOUND_TDATA_WIDTH


    )
    port map (
      clk    => aclk,
      clk_en => diff_to_integrator_sample_valid,
      rst    => aresetn,
      a      => diff_in_axis_tdata,
      b      => diff_in_axis_tdata,
      p      => integrator_to_qrs_tdata
      );

  
  -- R_detector : peakDetector 	generic map	(
												-- C_PEAKDET_DATA_WIDTH => C_G_AXIS_INBOUND_TDATA_WIDTH
											-- )
								-- port map 	(	
												-- data_in   => delay_to_tx1_tdata,
												-- threshold => ctrlAxi_to_r_thresh_data,
												-- clk      => aclk,
												-- rst_n    => (aresetn and qrs_detected_x),
												-- clk_en   => deNsd_to_ecgDelay_sample_valid,
												-- peak_value => qrs_to_tx2_tdata,
												-- peak_delay => open,
												-- peak_detected => open
											-- );                                               
	-- r_to_ctrlAxi_thresh_addr <= (3 => '1', others => '0'); -- assign the address for the R-wave threshold register.


	qrs_detector : QRSDetector 	generic map	(
												C_QRSDET_DATA_WIDTH => C_G_AXIS_INBOUND_TDATA_WIDTH,
												C_QRSDET_ADDR_WIDTH => C_CTRL_AXI_ADDR_WIDTH
											)
								port map 	(	
												data_in   => integrator_to_qrs_tdata,
												thresholdData_in => ctrlAxi_to_qrs_thresh_data,
												clk      => aclk,
												rst_n    => aresetn,
												clk_en   => diff_to_integrator_sample_valid,
												qrs_detected => qrs_detected_x,
												thresholdAddr_out => qrs_to_ctrlAxi_thresh_addr
											);   
                                            
	wave_detector : PQRSTDetector 	generic map	(
												C_PQRSTDET_DATA_WIDTH => C_G_AXIS_INBOUND_TDATA_WIDTH,
												C_PQRSTDET_ADDR_WIDTH => C_CTRL_AXI_ADDR_WIDTH
											)
								port map 	(	
												data_in   => delay_to_tx1_tdata,
												thresholdData_in => ctrlAxi_to_r_thresh_data,
												clk      => aclk,
												rst_n    => aresetn,
												clk_en   => deNsd_to_ecgDelay_sample_valid,
												qrs_detected => qrs_detected_x,
												thresholdAddr_out => r_to_ctrlAxi_thresh_addr,
												peak_data_out => wave_detector_to_ctrl_peak_data,
												peak_addr_out => open,
												peak_data_valid_out => wave_detector_to_ctrl_peak_data_valid,
												ecg_abn => ecg_abn_r
											);                                               

	-- the qrs portions of the delayed and de-noised ECG signal
	
	tx2_data:process(aclk)
	
	begin
		if rising_edge(aclk) then
			if aresetn = '0' then
				qrs_to_tx2_tdata <= (others => '0');
				wave_detector_to_tx2_peak_data <= (others => '0');
				wave_detector_to_tx2_peak_data_valid <= '0';
			else
				if wave_detector_to_ctrl_peak_data_valid = '1' then
					wave_detector_to_tx2_peak_data <= wave_detector_to_ctrl_peak_data;
					wave_detector_to_tx2_peak_data_valid <= '1';
				end if;
				if diff_to_integrator_sample_valid = '1' then
					
					if qrs_detected_x = '1' then--wave_detector_to_tx2_peak_data_valid = '1' then
						qrs_to_tx2_tdata <= wave_detector_to_tx2_peak_data;--(26 => '1', others => '0');--
						wave_detector_to_tx2_peak_data_valid <= '0';
					else
						qrs_to_tx2_tdata <= (others => '0');
					end if;
				
				end if;
			
			end if;
		end if;
	
	end process;
	--qrs_to_tx2_tdata <= delay_to_tx1_tdata when (qrs_detected_x = '1') else (others => '0');
	
	-- the delayed and de-noised ECG signal to the matlab
	tx_smp_01_axis_tdata <= delay_to_tx1_tdata;

	-- FIFO Implementation
	 ecg_delay: for byte_index in 0 to ((C_G_AXIS_INBOUND_TDATA_WIDTH/8)-1) generate

	 signal stream_data_fifo : BYTE_FIFO_TYPE;
	 begin   
	  -- Streaming input data is stored in FIFO
	  process(aclk)
	  begin
	    if (rising_edge (aclk)) then
			
			
	    if(aresetn = '0') then                                             
					for i in 0 to C_ECG_DELAY-1 loop
					stream_data_fifo(i) <= (others => '0'); --S_AXIS_TDATA((byte_index*8+7) downto (byte_index*8));	
					end loop;					
				delay_to_tx1_tdata((byte_index*8+7) downto (byte_index*8)) <= (others => '0');  
	    else
			
				if (deNsd_to_ecgDelay_sample_valid = '1') then -- && M_AXIS_TSTRB(byte_index)                   
					stream_data_fifo(0) <= to_tx1_x((byte_index*8+7) downto (byte_index*8));	
					for i in 1 to C_ECG_DELAY-1 loop
						stream_data_fifo(i) <= stream_data_fifo(i-1);
					end loop;					
					delay_to_tx1_tdata((byte_index*8+7) downto (byte_index*8)) <= stream_data_fifo(stream_data_fifo'high);
				end if;
			
		end if;                                                                   

	    end  if;
	  end process;

	end generate ecg_delay;

 -- User logic ends

end arch_imp;
