library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;	
USE ieee.math_real.ALL;   -- for UNIFORM, TRUNC functions
USE ieee.numeric_std.ALL; -- for TO_UNSIGNED function


entity tb_ecg_unit is

end tb_ecg_unit;

architecture test_flow of tb_ecg_unit is

component ECG_Detector_v1_0
	generic (
		-- Users to add parameters here
        C_S_INTR_ENABLE : boolean := false;
        C_S_AXIS_NSY_ENABLE : boolean := false;
        C_S_AXIS_DE_NSD_ENABLE : boolean := true;
        C_S_AXIS_DIFF_ENABLE    : boolean := true;
        C_S_AXIS_SQ_ENABLE : boolean := false;
        C_S_AXIS_INTEG_ENABLE : boolean := false;
        C_S_AXIS_TX_1_ENABLE : boolean := true;
        C_S_AXIS_TX_2_ENABLE : boolean := false;
        
        --TSTRB en
        DIFF_TSTRB_EN : boolean := false;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface CTRL_AXI
		C_CTRL_AXI_DATA_WIDTH	: integer	:= 32;
		C_CTRL_AXI_ADDR_WIDTH	: integer	:= 7;

		-- Streaming bus data width
		C_G_AXIS_TDATA_WIDTH	: integer	:= 32;
		
		-- Parameters of Axi Master Bus Interface TX_SMP_01_AXIS
		C_TX_SMP_01_AXIS_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Master Bus Interface TX_SMP_02_AXIS
		C_TX_SMP_02_AXIS_START_COUNT	: integer	:= 32;

		-- Parameters of Axi Slave Bus Interface S_AXI_INTR
		C_S_AXI_INTR_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_INTR_ADDR_WIDTH	: integer	:= 5;
		C_NUM_OF_INTR	: integer	:= 1;
		C_INTR_SENSITIVITY	: std_logic_vector	:= x"FFFFFFFF";
		C_INTR_ACTIVE_STATE	: std_logic_vector	:= x"FFFFFFFF";
		C_IRQ_SENSITIVITY	: integer	:= 1;
		C_IRQ_ACTIVE_STATE	: integer	:= 1
	);
	port (
		-- Users to add ports here
    aclk : in std_logic;
    aresetn : in std_logic;
    -- User ports ends
    -- Do not modify the ports beyond this line


    -- Ports of Axi Slave Bus Interface CTRL_AXI
--        ctrl_axi_aclk    : in std_logic;
--        ctrl_axi_aresetn    : in std_logic;
    ctrl_axi_awaddr    : in std_logic_vector(C_CTRL_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    ctrl_axi_awprot    : in std_logic_vector(2 downto 0) := (others => '0');
    ctrl_axi_awvalid    : in std_logic := '0';
    ctrl_axi_awready    : out std_logic;
    ctrl_axi_wdata    : in std_logic_vector(C_CTRL_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    ctrl_axi_wstrb    : in std_logic_vector((C_CTRL_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '0');
    ctrl_axi_wvalid    : in std_logic := '0';
    ctrl_axi_wready    : out std_logic;
    ctrl_axi_bresp    : out std_logic_vector(1 downto 0);
    ctrl_axi_bvalid    : out std_logic;
    ctrl_axi_bready    : in std_logic := '0';
    ctrl_axi_araddr    : in std_logic_vector(C_CTRL_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    ctrl_axi_arprot    : in std_logic_vector(2 downto 0) := (others => '0');
    ctrl_axi_arvalid    : in std_logic := '0';
    ctrl_axi_arready    : out std_logic;
    ctrl_axi_rdata    : out std_logic_vector(C_CTRL_AXI_DATA_WIDTH-1 downto 0);
    ctrl_axi_rresp    : out std_logic_vector(1 downto 0);
    ctrl_axi_rvalid    : out std_logic;
    ctrl_axi_rready    : in std_logic := '0';

    -- Ports of Axi Slave Bus Interface DE_NSD_IN_AXIS
--        de_nsd_in_axis_aclk    : in std_logic;
--        de_nsd_in_axis_aresetn    : in std_logic;
    de_nsd_in_axis_tready    : out std_logic;
    de_nsd_in_axis_tdata    : in std_logic_vector(C_G_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
    de_nsd_in_axis_tstrb    : in std_logic_vector((C_G_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    de_nsd_in_axis_tlast    : in std_logic := '0';
    de_nsd_in_axis_tvalid    : in std_logic := '0';

    -- Ports of Axi Slave Bus Interface NSY_IN_AXIS
--        nsy_in_axis_aclk    : in std_logic;
--        nsy_in_axis_aresetn    : in std_logic;
    nsy_in_axis_tready    : out std_logic;
    nsy_in_axis_tdata    : in std_logic_vector(C_G_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
    nsy_in_axis_tstrb    : in std_logic_vector((C_G_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    nsy_in_axis_tlast    : in std_logic := '0';
    nsy_in_axis_tvalid    : in std_logic := '0';

    -- Ports of Axi Slave Bus Interface SQR_IN_AXIS
--        sqr_in_axis_aclk    : in std_logic;
--        sqr_in_axis_aresetn    : in std_logic;
    sqr_in_axis_tready    : out std_logic;
    sqr_in_axis_tdata    : in std_logic_vector(C_G_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
    sqr_in_axis_tstrb    : in std_logic_vector((C_G_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    sqr_in_axis_tlast    : in std_logic := '0';
    sqr_in_axis_tvalid    : in std_logic := '0';

    -- Ports of Axi Slave Bus Interface DIFF_IN_AXIS
--        diff_in_axis_aclk    : in std_logic;
--        diff_in_axis_aresetn    : in std_logic;
    diff_in_axis_tready    : out std_logic;
    diff_in_axis_tdata    : in std_logic_vector(C_G_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
    diff_in_axis_tstrb    : in std_logic_vector((C_G_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    diff_in_axis_tlast    : in std_logic := '0';
    diff_in_axis_tvalid    : in std_logic := '0';

    -- Ports of Axi Slave Bus Interface INTEG_IN_AXIS
--        integ_in_axis_aclk    : in std_logic;
--        integ_in_axis_aresetn    : in std_logic;
    integ_in_axis_tready    : out std_logic;
    integ_in_axis_tdata    : in std_logic_vector(C_G_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
    integ_in_axis_tstrb    : in std_logic_vector((C_G_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
    integ_in_axis_tlast    : in std_logic := '0';
    integ_in_axis_tvalid    : in std_logic := '0';

    -- Ports of Axi Master Bus Interface TX_SMP_01_AXIS
--        tx_smp_01_axis_aclk    : in std_logic;
--        tx_smp_01_axis_aresetn    : in std_logic;
    tx_smp_01_axis_tvalid    : out std_logic;
    tx_smp_01_axis_tdata    : out std_logic_vector(C_G_AXIS_TDATA_WIDTH-1 downto 0);
    tx_smp_01_axis_tstrb    : out std_logic_vector((C_G_AXIS_TDATA_WIDTH/8)-1 downto 0);
    tx_smp_01_axis_tlast    : out std_logic;
    tx_smp_01_axis_tready    : in std_logic := '0';

    -- Ports of Axi Master Bus Interface TX_SMP_02_AXIS
--        tx_smp_02_axis_aclk    : in std_logic;
--        tx_smp_02_axis_aresetn    : in std_logic;
    tx_smp_02_axis_tvalid    : out std_logic;
    tx_smp_02_axis_tdata    : out std_logic_vector(C_G_AXIS_TDATA_WIDTH-1 downto 0);
    tx_smp_02_axis_tstrb    : out std_logic_vector((C_G_AXIS_TDATA_WIDTH/8)-1 downto 0);
    tx_smp_02_axis_tlast    : out std_logic;
    tx_smp_02_axis_tready    : in std_logic := '0';

    -- Ports of Axi Slave Bus Interface S_AXI_INTR
--        s_axi_intr_aclk    : in std_logic;
--        s_axi_intr_aresetn    : in std_logic;
    s_axi_intr_awaddr    : in std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0) := (others => '0');
    s_axi_intr_awprot    : in std_logic_vector(2 downto 0) := (others => '0');
    s_axi_intr_awvalid    : in std_logic := '0';
    s_axi_intr_awready    : out std_logic;
    s_axi_intr_wdata    : in std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0) := (others => '0');
    s_axi_intr_wstrb    : in std_logic_vector((C_S_AXI_INTR_DATA_WIDTH/8)-1 downto 0) := (others => '0');
    s_axi_intr_wvalid    : in std_logic := '0';
    s_axi_intr_wready    : out std_logic;
    s_axi_intr_bresp    : out std_logic_vector(1 downto 0);
    s_axi_intr_bvalid    : out std_logic;
    s_axi_intr_bready    : in std_logic := '0';
    s_axi_intr_araddr    : in std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0) := (others => '0');
    s_axi_intr_arprot    : in std_logic_vector(2 downto 0) := (others => '0');
    s_axi_intr_arvalid    : in std_logic := '0';
    s_axi_intr_arready    : out std_logic;
    s_axi_intr_rdata    : out std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
    s_axi_intr_rresp    : out std_logic_vector(1 downto 0);
    s_axi_intr_rvalid    : out std_logic;
    s_axi_intr_rready    : in std_logic := '0';
    irq    : out std_logic
	);
end component ECG_Detector_v1_0;

SIGNAL rst, clk, in_TEST_TLAST_in, in_TEST_TVALID_in, out_TEST_TREADY_in : std_logic := '0';
signal in_TEST_TREADY_out, out_TEST_TVALID_out, out_TEST_TLAST_out	:	std_logic;
SIGNAL in_TEST_TSTRB_in, out_TEST_TSTRB_out: STD_LOGIC_VECTOR(3 downto 0);
signal in_TEST_TDATA_in, out_TEST_TDATA_out	: std_logic_vector(31 downto 0);
signal s_tuser, m_tuser	: std_logic_vector(3 downto 0);

	--Total number of output data.
	-- Total number of output data                                              
	constant NUMBER_OF_OUTPUT_WORDS : integer := 20;                                   
	constant C_M_START_COUNT	: integer := 5;
	constant C_M_AXIS_TDATA_WIDTH	: integer := 32;
	 -- function called clogb2 that returns an integer which has the   
	 -- value of the ceiling of the log base 2.                              
	function clogb2 (bit_depth : integer) return integer is                  
	 	variable depth  : integer := bit_depth;                               
	 	variable count  : integer := 1;                                       
	 begin                                                                   
	 	 for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	      if (bit_depth <= 2) then                                           
	        count := 1;                                                      
	      else                                                               
	        if(depth <= 1) then                                              
	 	       count := count;                                                
	 	     else                                                             
	 	       depth := depth / 2;                                            
	          count := count + 1;                                            
	 	     end if;                                                          
	 	   end if;                                                            
	   end loop;                                                             
	   return(count);        	                                              
	 end;                                                                    

	 -- WAIT_COUNT_BITS is the width of the wait counter.                       
	 constant  WAIT_COUNT_BITS  : integer := clogb2(C_M_START_COUNT-1);               
	                                                                                  
	-- In this example, Depth of FIFO is determined by the greater of                 
	-- the number of input words and output words.                                    
	constant depth : integer := NUMBER_OF_OUTPUT_WORDS;                               
	                                                                                  
	-- bit_num gives the minimum number of bits needed to address 'depth' size of FIFO
	constant bit_num : integer := clogb2(depth);                                      
	                                                                                  
	-- Define the states of state machine                                             
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO                                   
	type state is ( IDLE,        -- This is the initial/idle state                    
	                INIT_COUNTER,  -- This state initializes the counter, ones        
	                                -- the counter reaches C_M_START_COUNT count,     
	                                -- the state machine changes state to INIT_WRITE  
	                SEND_STREAM);  -- In this state the                               
	                             -- stream data is output through TEST_TDATA        
	-- State variable                                                                 
	signal  mst_exec_state : state;                                                   
	-- Example design FIFO read pointer                                               
	signal read_pointer : integer range 0 to bit_num-1;                               

	-- AXI Stream internal signals
	--wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	signal count	: std_logic_vector(WAIT_COUNT_BITS-1 downto 0);
	--streaming data valid
	signal axis_tvalid	: std_logic;
	--streaming data valid delayed by one clock cycle
	signal axis_tvalid_delay	: std_logic;
	--Last of the streaming data 
	signal axis_tlast	: std_logic;
	--Last of the streaming data delayed by one clock cycle
	signal axis_tlast_delay	: std_logic;
	--FIFO implementation signals
	signal stream_data_out	: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal tx_en	: std_logic;
	--The master has issued all the streaming data stored in FIFO
	signal tx_done, restart	: std_logic;
	signal counter_1 : integer range 0 to 65535;
	
component QRSDetector
  generic (
    C_QRSDET_DATA_WIDTH : integer := 32;
	C_QRSDET_ADDR_WIDTH	: integer := 7
	
    );
  port (

		 data_in : in  std_logic_vector (C_QRSDET_DATA_WIDTH-1 downto 0);
		 thresholdData_in : in  std_logic_vector (C_QRSDET_DATA_WIDTH-1 downto 0);
         clk      : in  std_logic;
         rst_n    : in  std_logic;
         clk_en   : in  std_logic;
		 thresholdAddr_out : out std_logic_vector (C_QRSDET_ADDR_WIDTH-1 downto 0);
		 qrs_detected	: out std_logic);
end component QRSDetector;
	

begin



		

DUT: ECG_Detector_v1_0 	generic map (
        C_S_INTR_ENABLE  =>  false,
C_S_AXIS_NSY_ENABLE  => false,
C_S_AXIS_DE_NSD_ENABLE  => true,
C_S_AXIS_DIFF_ENABLE     => true,
C_S_AXIS_SQ_ENABLE  => false,
C_S_AXIS_INTEG_ENABLE  => false,
C_S_AXIS_TX_1_ENABLE  => true,
C_S_AXIS_TX_2_ENABLE  => false,

--TSTRB en
DIFF_TSTRB_EN => false,
-- User parameters ends
-- Do not modify the parameters beyond this line


-- Parameters of Axi Slave Bus Interface CTRL_AXI
C_CTRL_AXI_DATA_WIDTH => 32,
C_CTRL_AXI_ADDR_WIDTH    => 7,

-- Streaming bus data width
C_G_AXIS_TDATA_WIDTH    => 32,

-- Parameters of Axi Master Bus Interface TX_SMP_01_AXIS
C_TX_SMP_01_AXIS_START_COUNT    => 32,

-- Parameters of Axi Master Bus Interface TX_SMP_02_AXIS
C_TX_SMP_02_AXIS_START_COUNT   => 32,

-- Parameters of Axi Slave Bus Interface S_AXI_INTR
C_S_AXI_INTR_DATA_WIDTH   => 32,
C_S_AXI_INTR_ADDR_WIDTH    => 5,
C_NUM_OF_INTR       => 1,
C_INTR_SENSITIVITY    => x"FFFFFFFF",
C_INTR_ACTIVE_STATE    => x"FFFFFFFF",
C_IRQ_SENSITIVITY    => 1,
C_IRQ_ACTIVE_STATE    => 1
	)
								port map (		
        aclk 	=> clk,
                                aresetn  => rst,
                                -- User ports ends
                                -- Do not modify the ports beyond this line
                        
                        
                                -- Ports of Axi Slave Bus Interface CTRL_AXI
                        --        ctrl_axi_aclk    : in std_logic;
                        --        ctrl_axi_aresetn    : in std_logic;
		                  ctrl_axi_awaddr	=> open,
                        ctrl_axi_awprot	=> open,
                        ctrl_axi_awvalid 	=> open,
                        ctrl_axi_awready  	=> open, 
                        ctrl_axi_wdata    	=> open,
                        ctrl_axi_wstrb  	=> open,  
                        ctrl_axi_wvalid   	=> open,
                        ctrl_axi_wready    	=> open,
                        ctrl_axi_bresp    	=> open,
                        ctrl_axi_bvalid  	=> open,
                        ctrl_axi_bready  	=> open,
                        ctrl_axi_araddr  	=> open,
                        ctrl_axi_arprot    	=> open,
                        ctrl_axi_arvalid  	=> open,
                        ctrl_axi_arready   	=> open,
                        ctrl_axi_rdata   	=> open,
                        ctrl_axi_rresp   	=> open,
                        ctrl_axi_rvalid  	=> open,
                        ctrl_axi_rready  	=> open,
                         
                                -- Ports of Axi Slave Bus Interface DE_NSD_IN_AXIS
                        --        de_nsd_in_axis_aclk    : in std_logic;
                        --        de_nsd_in_axis_aresetn    : in std_logic;
                        
                                -- Ports of Axi Slave Bus Interface NSY_IN_AXIS
                        --        nsy_in_axis_aclk    : in std_logic;
                        --        nsy_in_axis_aresetn    : in std_logic;
                        
                                -- Ports of Axi Slave Bus Interface SQR_IN_AXIS
                        --        sqr_in_axis_aclk    : in std_logic;
                        --        sqr_in_axis_aresetn    : in std_logic;
                        
                                -- Ports of Axi Slave Bus Interface DIFF_IN_AXIS
                        --        diff_in_axis_aclk    : in std_logic;
                        --        diff_in_axis_aresetn    : in std_logic;
                                diff_in_axis_tready  => in_TEST_TREADY_out,
                                diff_in_axis_tdata  => in_TEST_TDATA_in,
                                diff_in_axis_tstrb => open,
                                diff_in_axis_tlast  => in_TEST_TLAST_in,
                                diff_in_axis_tvalid => in_TEST_TVALID_in,
                        
                                -- Ports of Axi Slave Bus Interface INTEG_IN_AXIS
                        --        integ_in_axis_aclk    : in std_logic;
                        --        integ_in_axis_aresetn    : in std_logic;
        
                                -- Ports of Axi Master Bus Interface TX_SMP_01_AXIS
                        --        tx_smp_01_axis_aclk    : in std_logic;
                        --        tx_smp_01_axis_aresetn    : in std_logic;
                                tx_smp_01_axis_tvalid => out_TEST_TVALID_out,
                                tx_smp_01_axis_tdata => out_TEST_TDATA_out,
                                tx_smp_01_axis_tstrb => open,
                                tx_smp_01_axis_tlast => out_TEST_TLAST_out,
                                tx_smp_01_axis_tready => out_TEST_TREADY_in
                        
                                -- Ports of Axi Master Bus Interface TX_SMP_02_AXIS
                        --        tx_smp_02_axis_aclk    : in std_logic;
                        --        tx_smp_02_axis_aresetn    : in std_logic;
                       
                                -- Ports of Axi Slave Bus Interface S_AXI_INTR
                        --        s_axi_intr_aclk    : in std_logic;
                        --        s_axi_intr_aresetn    : in std_logic;
													
												
												);

		

clk <= not clk after 10 ns;

-- test sequence for the master interface (reading from the tx-fifo)
slave_if:process(clk)
begin

if rising_edge(clk) then

	out_TEST_TREADY_in <= '0';
	restart <= '0';
	case counter_1 is
		when 10 to 22 =>
			if in_TEST_TREADY_out = '0' then
				out_TEST_TREADY_in <= '1';
			elsif out_TEST_TREADY_in = '1' then
				out_TEST_TREADY_in <= '1';
			end if;
		when 25 to 28 =>
			out_TEST_TREADY_in <= '1';
		when 35 to 100 =>
			out_TEST_TREADY_in <= '1';
		when 101 =>
			restart <= '1';
		when 105 to 1000 =>
			out_TEST_TREADY_in <= '1';
		when others =>
			out_TEST_TREADY_in <= '0';
	end case;
	


end if;

end process;

-- counter to give some timing in the test sequence
counter:process(clk)
begin

if rising_edge(clk) then
	if rst = '0' then
		counter_1 <= 0;
	else
		counter_1 <= counter_1 + 1;
	end if;

end if;

end process;


-- the axis master logic is used to drive test sequence into the axis slave IF (rx-fifo).

	-- I/O Connections assignments

	in_TEST_TVALID_in	<= axis_tvalid_delay;
	in_TEST_TDATA_in	<= stream_data_out;
	in_TEST_TLAST_in	<= axis_tlast_delay;
	in_TEST_TSTRB_in	<= (others => '1');


	-- Control state machine implementation                                               
	process(clk)                                                                        
	begin                                                                                       
	  if (rising_edge (clk)) then                                                       
	    if(rst = '0') then                                                           
	      -- Synchronous reset (active low)                                                     
	      mst_exec_state      <= IDLE;    
			rst <= '1';
	      count <= (others => '0');                                                             
	    else                                                                                    
	      case (mst_exec_state) is    
			
					
	        when IDLE     =>                                                                    
	          -- The slave starts accepting tdata when                                          
	          -- there tvalid is asserted to mark the                                           
	          -- presence of valid streaming data                                               
	          --if (count = "0")then                                                            
	            mst_exec_state <= INIT_COUNTER;    
							
	          --else                                                                              
	          --  mst_exec_state <= IDLE;                                                         
	          --end if;                                                                           
	                                                                                            
	          when INIT_COUNTER =>                                                              
	            -- This state is responsible to wait for user defined C_M_START_COUNT           
	            -- number of clock cycles.                                                      
	            if ( count = std_logic_vector(to_unsigned((C_M_START_COUNT - 1), WAIT_COUNT_BITS))) then
	              mst_exec_state  <= SEND_STREAM;                                               
	            else                                                                            
	              count <= std_logic_vector (unsigned(count) + 1);                              
	              mst_exec_state  <= INIT_COUNTER;                                              
	            end if;                                                                         
	                                                                                            
	        when SEND_STREAM  =>                                                                
	          -- The example design streaming master functionality starts                       
	          -- when the master drives output tdata from the FIFO and the slave                
	          -- has finished storing the TEST_TDATA                                          
	          if (tx_done = '1') then                                                           
	            mst_exec_state <= IDLE;                                                         
	          else                                                                              
	            mst_exec_state <= SEND_STREAM;                                                  
	          end if;                                                                           
	                                                                                            
	        when others    =>                                                                   
	          mst_exec_state <= IDLE;                                                           
	                                                                                            
	      end case;                                                                             
	    end if;                                                                                 
	  end if;                                                                                   
	end process;                                                                                


	--tvalid generation
	--axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	--number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
	axis_tvalid <= '1' when ((mst_exec_state = SEND_STREAM) and (read_pointer < NUMBER_OF_OUTPUT_WORDS)) else '0';
	                                                                                               
	-- AXI tlast generation                                                                        
	-- axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1          
	-- (0 to NUMBER_OF_OUTPUT_WORDS-1)                                                             
	axis_tlast <= '1' when (read_pointer = NUMBER_OF_OUTPUT_WORDS-1) else '0';                     
	                                                                                               
	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	-- to match the latency of in_TEST_TDATA_in                                                        
	process(clk)                                                                           
	begin                                                                                          
	  if (rising_edge (clk)) then                                                          
	    if(rst = '0') then                                                              
	      axis_tvalid_delay <= '0';                                                                
	      axis_tlast_delay <= '0';                                                                 
	    else                                                                                       
	      axis_tvalid_delay <= axis_tvalid;                                                        
	      axis_tlast_delay <= axis_tlast;                                                          
	    end if;                                                                                    
	  end if;                                                                                      
	end process;                                                                                   


	--read_pointer pointer

	process(clk)                                                       
	begin                                                                            
	  if (rising_edge (clk)) then                                            
	    if(rst = '0') then                                                
	      read_pointer <= 0;                                                         
	      tx_done  <= '0';                                                           
	    else                                                                         
	      if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1) then                         
	        if (tx_en = '1') then                                                    
	          -- read pointer is incremented after every read from the FIFO          
	          -- when FIFO read signal is enabled.                                   
	          read_pointer <= read_pointer + 1;    

				tx_done <= '0';

	        end if;                                                                  
	      elsif (read_pointer = NUMBER_OF_OUTPUT_WORDS) then                         
	        -- tx_done is asserted when NUMBER_OF_OUTPUT_WORDS numbers of streaming data
	        -- has been out.  
				if(restart = '1') then
				read_pointer <= 0;
				end if;
	        tx_done <= '1';                                                          
	      end  if;                                                                   
	    end  if;                                                                     
	  end  if;                                                                       
	end process;                                                                     


	--FIFO read enable generation 

	tx_en <= in_TEST_TREADY_out and axis_tvalid;                                   
	                                                                                
	-- FIFO Implementation                                                          
	                                                                                
	-- Streaming output data is read from FIFO                                      
	  process(clk)                                                          
	  variable  sig_one : integer := 0;                                             
	  begin                                                                         
	    if (rising_edge (clk)) then                                         
	      if(rst = '0') then                                             
	    	stream_data_out <= std_logic_vector(to_unsigned(sig_one,C_M_AXIS_TDATA_WIDTH));  
			s_tuser <= (others => '1');
	      elsif (tx_en = '1') then -- && in_TEST_TSTRB_in(byte_index)                   
	        stream_data_out <= std_logic_vector( to_unsigned(read_pointer,C_M_AXIS_TDATA_WIDTH) + to_unsigned(131072,C_M_AXIS_TDATA_WIDTH));
			s_tuser <= std_logic_vector(to_unsigned(read_pointer, 4));
	      end if;                                                                   
	     end if;                                                                    
	   end process;                                                                 

	-- Add user logic here

	-- User logic ends

end test_flow;