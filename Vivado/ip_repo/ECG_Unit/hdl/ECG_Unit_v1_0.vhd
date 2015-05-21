library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ecg_components.multiplier;

entity ECG_Unit_v1_0 is
  generic (
    -- Users to add parameters here
    S_TSTRB_EN                  : boolean := false;
    S_TLAST_EN                  : boolean := false;
    S_TUSER_EN                  : boolean := false;
    S_TLAST_GEN                 : boolean := false;
    S_TLAST_PROP                : boolean := true;
    S_PACKET_LENGTH             : integer := 5;
    M_TSTRB_EN                  : boolean := false;
    M_TLAST_EN                  : boolean := false;
    M_TLAST_GEN                 : boolean := false;
    M_TLAST_PROP                : boolean := true;
    M_PACKET_LENGTH             : integer := 5;
    M_TUSER_EN                  : boolean := false;
    CLOCK_CONV_EN               : boolean := false;
    SYSTEM_CLK_FREQ             : integer := 100000000;
    SAMPLE_FREQ                 : integer := 500;
    C_S_FIFO_DEPTH              : integer := 16;
    C_M_FIFO_DEPTH              : integer := 16;
    C_S_AXIS_TUSER_WIDTH        : integer := 4;
    C_M_AXIS_TUSER_WIDTH        : integer := 4;
    C_S_READ_f_FIFO_START_COUNT : integer := 32;
    
    --ECG detection params
    C_ECG_R_THRESHOLD_PRI   : integer :=2000000;
    C_ECG_T_THRESHOLD_PRI    : integer := 2000;
   C_ECG_P_THRESHOLD_PRI   : integer :=900;
    C_ECG_R_THRESHOLD_SEC   : integer :=1000000;
    C_ECG_T_THRESHOLD_SEC    : integer := 1000;
     C_ECG_P_THRESHOLD_SEC    : integer := 500;

    -- Width of S_AXI data bus
    C_S00_AXI_DATA_WIDTH : integer := 32;
    -- Width of S_AXI address bus
    C_S00_AXI_ADDR_WIDTH : integer := 7;

    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface S00_AXIS
    C_S00_AXIS_TDATA_WIDTH : integer := 32;

    -- Parameters of Axi Master Bus Interface M00_AXIS
    C_M00_AXIS_TDATA_WIDTH : integer := 32;
    C_M00_AXIS_START_COUNT : integer := 32
    );
  port (
    -- Users to add ports here

    s00_axis_tuser : in  std_logic_vector(C_S_AXIS_TUSER_WIDTH-1 downto 0) := (others => '0');
    m00_axis_tuser : out std_logic_vector(C_M_AXIS_TUSER_WIDTH-1 downto 0) := (others => '0');

    -- Ports of Axi Slave Bus Interface S00_AXI
    s00_axi_aclk    : in  std_logic;
    s00_axi_aresetn : in  std_logic;
    s00_axi_awaddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot  : in  std_logic_vector(2 downto 0);
    s00_axi_awvalid : in  std_logic;
    s00_axi_awready : out std_logic;
    s00_axi_wdata   : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_wstrb   : in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid  : in  std_logic;
    s00_axi_wready  : out std_logic;
    s00_axi_bresp   : out std_logic_vector(1 downto 0);
    s00_axi_bvalid  : out std_logic;
    s00_axi_bready  : in  std_logic;
    s00_axi_araddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot  : in  std_logic_vector(2 downto 0);
    s00_axi_arvalid : in  std_logic;
    s00_axi_arready : out std_logic;
    s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_rresp   : out std_logic_vector(1 downto 0);
    s00_axi_rvalid  : out std_logic;
    s00_axi_rready  : in  std_logic;

    -- User ports ends
    -- Do not modify the ports beyond this line


    -- Ports of Axi Slave Bus Interface S00_AXIS
    s00_axis_aclk    : in  std_logic;
    s00_axis_aresetn : in  std_logic;
    s00_axis_tready  : out std_logic;
    s00_axis_tdata   : in  std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
    s00_axis_tstrb   : in  std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    s00_axis_tlast   : in  std_logic;
    s00_axis_tvalid  : in  std_logic;

    -- Ports of Axi Master Bus Interface M00_AXIS
    m00_axis_aclk    : in  std_logic;
    m00_axis_aresetn : in  std_logic;
    m00_axis_tvalid  : out std_logic;
    m00_axis_tdata   : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
    m00_axis_tstrb   : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    m00_axis_tlast   : out std_logic;
    m00_axis_tready  : in  std_logic
    );
end ECG_Unit_v1_0;

architecture arch_imp of ECG_Unit_v1_0 is

  -- component declaration
  component ECG_Unit_v1_0_S00_AXI is
    
    
    generic (
      -- Users to add parameters here
       C_R_THRESHOLD_PRI   : integer :=2000000;
     C_T_THRESHOLD_PRI    : integer := 2000;
    C_P_THRESHOLD_PRI   : integer :=900;
     C_R_THRESHOLD_SEC   : integer :=1000000;
     C_T_THRESHOLD_SEC    : integer := 1000;
      C_P_THRESHOLD_SEC    : integer := 500;

      -- User parameters ends
      -- Do not modify the parameters beyond this line

      -- Width of S_AXI data bus
      C_S_AXI_DATA_WIDTH : integer := 32;
      -- Width of S_AXI address bus
      C_S_AXI_ADDR_WIDTH : integer := 7
      );
    port (
      -- Users to add ports here
      S_AXI_SAMPLE_VALID : in std_logic;
      S_AXI_SAMPLE_IN    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      -- User ports ends
      -- Do not modify the ports beyond this line

      -- Global Clock Signal
      S_AXI_ACLK    : in  std_logic;
      -- Global Reset Signal. This Signal is Active LOW
      S_AXI_ARESETN : in  std_logic;
      -- Write address (issued by master, acceped by Slave)
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      -- Write channel Protection type. This signal indicates the
      -- privilege and security level of the transaction, and whether
      -- the transaction is a data access or an instruction access.
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      -- Write address valid. This signal indicates that the master signaling
      -- valid write address and control information.
      S_AXI_AWVALID : in  std_logic;
      -- Write address ready. This signal indicates that the slave is ready
      -- to accept an address and associated control signals.
      S_AXI_AWREADY : out std_logic;
      -- Write data (issued by master, acceped by Slave) 
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      -- Write strobes. This signal indicates which byte lanes hold
      -- valid data. There is one write strobe bit for each eight
      -- bits of the write data bus.    
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      -- Write valid. This signal indicates that valid write
      -- data and strobes are available.
      S_AXI_WVALID  : in  std_logic;
      -- Write ready. This signal indicates that the slave
      -- can accept the write data.
      S_AXI_WREADY  : out std_logic;
      -- Write response. This signal indicates the status
      -- of the write transaction.
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      -- Write response valid. This signal indicates that the channel
      -- is signaling a valid write response.
      S_AXI_BVALID  : out std_logic;
      -- Response ready. This signal indicates that the master
      -- can accept a write response.
      S_AXI_BREADY  : in  std_logic;
      -- Read address (issued by master, acceped by Slave)
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      -- Protection type. This signal indicates the privilege
      -- and security level of the transaction, and whether the
      -- transaction is a data access or an instruction access.
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      -- Read address valid. This signal indicates that the channel
      -- is signaling valid read address and control information.
      S_AXI_ARVALID : in  std_logic;
      -- Read address ready. This signal indicates that the slave is
      -- ready to accept an address and associated control signals.
      S_AXI_ARREADY : out std_logic;
      -- Read data (issued by slave)
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      -- Read response. This signal indicates the status of the
      -- read transfer.
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      -- Read valid. This signal indicates that the channel is
      -- signaling the required read data.
      S_AXI_RVALID  : out std_logic;
      -- Read ready. This signal indicates that the master can
      -- accept the read data and response information.
      S_AXI_RREADY  : in  std_logic
      );

  end component ECG_Unit_v1_0_S00_AXI;

  component ECG_Unit_v1_0_S00_AXIS is
    generic (
      S_TSTRB_EN           : boolean := false;
      S_TLAST_EN           : boolean := true;
      S_TLAST_GEN          : boolean := false;
      S_TLAST_PROP         : boolean := false;
      S_PACKET_LENGTH      : integer := 5;
      S_TUSER_EN           : boolean := false;
      CLOCK_CONV_EN        : boolean := false;
      SYSTEM_CLK_FREQ      : integer := 100000000;
      SAMPLE_FREQ          : integer := 500;
      C_S_AXIS_TUSER_WIDTH : integer := 4;
      C_S_FIFO_DEPTH       : integer := 16;
      C_S_START_COUNT      : integer := 32;
      C_S_AXIS_TDATA_WIDTH : integer := 32
      );
    port (
      -- Sample data out
      SAMPLE_DATA    : out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
      -- The next sample is read from the rx fifo and available at the sample_data-port at the same cycle when READ_SAMPLE -port goes high
      READ_SAMPLE    : in  std_logic;
      -- Indicates that a valid sample is available in the sample_data port
      SAMPLE_VALID   : out std_logic;
      --  The sample in sample_data port at the current cycle is the last sample.
      LAST_SAMPLE    : out std_logic;
      -- TUSER bus output from the RX fifo
      TUSER_DATA_OUT : out std_logic_vector(C_S_AXIS_TUSER_WIDTH-1 downto 0);
      --TSTRB out
      TSTRB_DATA_OUT : out std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
      -- END: addition to the Xilinx generated code 
      S_AXIS_TUSER   : in  std_logic_vector((C_S_AXIS_TUSER_WIDTH-1) downto 0) := (others => '0');
      S_AXIS_ACLK    : in  std_logic;
      S_AXIS_ARESETN : in  std_logic;
      S_AXIS_TREADY  : out std_logic;
      S_AXIS_TDATA   : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
      S_AXIS_TSTRB   : in  std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
      S_AXIS_TLAST   : in  std_logic;
      S_AXIS_TVALID  : in  std_logic
      );
  end component ECG_Unit_v1_0_S00_AXIS;

  component ECG_Unit_v1_0_M00_AXIS is
    generic (
      M_TSTRB_EN           : boolean := false;
      M_TLAST_EN           : boolean := true;
      M_TLAST_GEN          : boolean := false;
      M_TLAST_PROP         : boolean := false;
      M_PACKET_LENGTH      : integer := 5;
      M_TUSER_EN           : boolean := false;
      CLOCK_CONV_EN        : boolean := false;
      SYSTEM_CLK_FREQ      : integer := 100000000;
      SAMPLE_FREQ          : integer := 500;
      C_M_AXIS_TUSER_WIDTH : integer := 4;
      C_M_FIFO_DEPTH       : integer := 16;
      C_M_AXIS_TDATA_WIDTH : integer := 32;
      C_M_START_COUNT      : integer := 32
      );
    port (
      -- BEGIN: addition to the Xilinx generated code
      -- Sample data in
      SAMPLE_DATA    : in  std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
      -- the axis master IF is ready to write a sample into its tx fifo
      WRITE_SAMPLE   : out std_logic;
      -- Indicates that a valid sample is available in the sample_data port
      SAMPLE_VALID   : in  std_logic;
      --  The sample in sample_data port at the current cycle is the last sample.
      LAST_SAMPLE    : in  std_logic;
      -- TUSER bus input to the TX fifo
      TUSER_DATA_IN  : in  std_logic_vector(C_S_AXIS_TUSER_WIDTH-1 downto 0)   := (others => '0');
      --TSTRB in
      TSTRB_DATA_IN  : in  std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
      -- END: addition to the Xilinx generated code 
      M_AXIS_TUSER   : out std_logic_vector((C_M_AXIS_TUSER_WIDTH-1) downto 0) := (others => '0');
      M_AXIS_ACLK    : in  std_logic;
      M_AXIS_ARESETN : in  std_logic;
      M_AXIS_TVALID  : out std_logic;
      M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
      M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
      M_AXIS_TLAST   : out std_logic;
      M_AXIS_TREADY  : in  std_logic
      );
  end component ECG_Unit_v1_0_M00_AXIS;

  signal w_sample_data_in, squared_sample_out : std_logic_vector(C_S00_AXIS_TDATA_WIDTH -1 downto 0);  -- data bus between the IFes
  signal w_tr_sample      : std_logic;  --connect the read_sample and write_sample of axis slave and master IF fifos.
  signal w_sample_valid   : std_logic;  -- connect the sample_valid ports between the IFes.
  signal w_last_sample    : std_logic;  -- connect the last_sample ports between the IFes.
  signal w_valid_transA   : std_logic;  -- indicates the ecg logic when the new input is valid
  signal w_tuser          : std_logic_vector(C_S_AXIS_TUSER_WIDTH-1 downto 0);
  signal w_tstrb          : std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);


begin
  ECG_Unit_v1_0_S00_AXI_inst : ECG_Unit_v1_0_S00_AXI
    generic map (
     C_R_THRESHOLD_PRI => C_ECG_R_THRESHOLD_PRI,
    C_T_THRESHOLD_PRI => C_ECG_T_THRESHOLD_PRI,
	C_P_THRESHOLD_PRI => C_ECG_P_THRESHOLD_PRI,
    C_R_THRESHOLD_SEC => C_ECG_R_THRESHOLD_SEC,
    C_T_THRESHOLD_SEC => C_ECG_T_THRESHOLD_SEC,
     C_P_THRESHOLD_SEC => C_ECG_P_THRESHOLD_SEC,
     C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
      )
    port map (
      S_AXI_SAMPLE_VALID => w_valid_transA,
      S_AXI_SAMPLE_IN    => squared_sample_out,
      S_AXI_ACLK         => s00_axi_aclk,
      S_AXI_ARESETN      => s00_axi_aresetn,
      S_AXI_AWADDR       => s00_axi_awaddr,
      S_AXI_AWPROT       => s00_axi_awprot,
      S_AXI_AWVALID      => s00_axi_awvalid,
      S_AXI_AWREADY      => s00_axi_awready,
      S_AXI_WDATA        => s00_axi_wdata,
      S_AXI_WSTRB        => s00_axi_wstrb,
      S_AXI_WVALID       => s00_axi_wvalid,
      S_AXI_WREADY       => s00_axi_wready,
      S_AXI_BRESP        => s00_axi_bresp,
      S_AXI_BVALID       => s00_axi_bvalid,
      S_AXI_BREADY       => s00_axi_bready,
      S_AXI_ARADDR       => s00_axi_araddr,
      S_AXI_ARPROT       => s00_axi_arprot,
      S_AXI_ARVALID      => s00_axi_arvalid,
      S_AXI_ARREADY      => s00_axi_arready,
      S_AXI_RDATA        => s00_axi_rdata,
      S_AXI_RRESP        => s00_axi_rresp,
      S_AXI_RVALID       => s00_axi_rvalid,
      S_AXI_RREADY       => s00_axi_rready
      );


-- Instantiation of Axi Bus Interface S00_AXIS
  ECG_Unit_v1_0_S00_AXIS_inst : ECG_Unit_v1_0_S00_AXIS
    generic map (
      S_TSTRB_EN           => S_TSTRB_EN,
      S_TLAST_EN           => S_TLAST_EN,
      S_TLAST_GEN          => S_TLAST_GEN,
      S_TLAST_PROP         => S_TLAST_PROP,
      S_PACKET_LENGTH      => S_PACKET_LENGTH,
      S_TUSER_EN           => S_TUSER_EN,
      CLOCK_CONV_EN        => CLOCK_CONV_EN,
      SYSTEM_CLK_FREQ      => SYSTEM_CLK_FREQ,
      SAMPLE_FREQ          => SAMPLE_FREQ,
      C_S_AXIS_TUSER_WIDTH => C_S_AXIS_TUSER_WIDTH,
      C_S_FIFO_DEPTH       => C_S_FIFO_DEPTH,
      C_S_START_COUNT      => C_S_READ_f_FIFO_START_COUNT,
      C_S_AXIS_TDATA_WIDTH => C_S00_AXIS_TDATA_WIDTH
      )
    port map (
      -- BEGIN: addition to the Xilinx generated code
      -- Sample data out
      SAMPLE_DATA    => w_sample_data_in,
      -- The next sample is read from the rx fifo and available at the sample_data-port at the same cycle when READ_SAMPLE -port goes high
      READ_SAMPLE    => w_tr_sample,
      -- Indicates that a valid sample is available in the sample_data port
      SAMPLE_VALID   => w_sample_valid,
      -- the word read from fifo closes the packet
      LAST_SAMPLE    => w_last_sample,
      -- TUSER output
      TUSER_DATA_OUT => w_tuser,
      -- TSTRB out
      TSTRB_DATA_OUT => w_tstrb,
      -- END: addition to the Xilinx generated code 
      S_AXIS_TUSER   => s00_axis_tuser,
      S_AXIS_ACLK    => s00_axis_aclk,
      S_AXIS_ARESETN => s00_axis_aresetn,
      S_AXIS_TREADY  => s00_axis_tready,
      S_AXIS_TDATA   => s00_axis_tdata,
      S_AXIS_TSTRB   => s00_axis_tstrb,
      S_AXIS_TLAST   => s00_axis_tlast,
      S_AXIS_TVALID  => s00_axis_tvalid
      );

-- Instantiation of Axi Bus Interface M00_AXIS
  ECG_Unit_v1_0_M00_AXIS_inst : ECG_Unit_v1_0_M00_AXIS
    generic map (
      M_TSTRB_EN           => M_TSTRB_EN,
      M_TLAST_EN           => M_TLAST_EN,
      M_TLAST_GEN          => M_TLAST_GEN,
      M_TLAST_PROP         => M_TLAST_PROP,
      M_PACKET_LENGTH      => M_PACKET_LENGTH,
      M_TUSER_EN           => M_TUSER_EN,
      CLOCK_CONV_EN        => CLOCK_CONV_EN,
      SYSTEM_CLK_FREQ      => SYSTEM_CLK_FREQ,
      SAMPLE_FREQ          => SAMPLE_FREQ,
      C_M_AXIS_TUSER_WIDTH => C_M_AXIS_TUSER_WIDTH,
      C_M_FIFO_DEPTH       => C_M_FIFO_DEPTH,
      C_M_AXIS_TDATA_WIDTH => C_M00_AXIS_TDATA_WIDTH,
      C_M_START_COUNT      => C_M00_AXIS_START_COUNT
      )
    port map (
      -- BEGIN: addition to the Xilinx generated code
      -- Sample data in
      SAMPLE_DATA    => squared_sample_out,
      -- the axis master IF is ready to write a sample into its tx fifo
      WRITE_SAMPLE   => w_tr_sample,
      -- Indicates that a valid sample is available in the sample_data port
      SAMPLE_VALID   => w_sample_valid,
      -- the word read from fifo closes the packet
      LAST_SAMPLE    => w_last_sample,
      -- TUSER
      TUSER_DATA_IN  => w_tuser,
      -- TSTRB in
      TSTRB_DATA_IN  => w_tstrb,
      -- END: addition to the Xilinx generated code 
      M_AXIS_TUSER   => m00_axis_tuser,
      M_AXIS_ACLK    => m00_axis_aclk,
      M_AXIS_ARESETN => m00_axis_aresetn,
      M_AXIS_TVALID  => m00_axis_tvalid,
      M_AXIS_TDATA   => m00_axis_tdata,
      M_AXIS_TSTRB   => m00_axis_tstrb,
      M_AXIS_TLAST   => m00_axis_tlast,
      M_AXIS_TREADY  => m00_axis_tready
      );

  -- Add user logic here
  
  --w_valid_transA indicates when the sample_data_in has a valid new sample
  w_valid_transA <= w_sample_valid and w_tr_sample;

  square:multiplier generic map(
MUL_DATA_WIDTH => 32, MUL_FRACTION_PORTION => 16)
  port map(clk => s00_axi_aclk,
           clk_en => w_valid_transA,
           rst => s00_axi_aresetn,
           a => w_sample_data_in,
           b => w_sample_data_in,
           p => squared_sample_out
           );
  
  -- User logic ends

end arch_imp;
