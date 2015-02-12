library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ecg_components.all;

entity ECG_Unit_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here
        S_TSTRB_EN    : boolean   := false;
        S_TLAST_EN    : boolean   := true;
        S_TUSER_EN    : boolean   := false;
		S_TLAST_GEN	: boolean	:= false;
		S_TLAST_PROP	: boolean	:= false;
		S_PACKET_LENGTH	: integer	:= 5;
		CLOCK_CONV_EN	: boolean := false;
        SYSTEM_CLK_FREQ  : integer   := 100000000;
        SAMPLE_FREQ         : integer := 500;
        C_S_AXIS_TUSER_WIDTH    : integer := 4;
        C_S_FIFO_DEPTH          : integer := 16;
        C_S_START_COUNT         : integer := 32;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
		-- Sample data out
		SAMPLE_DATA    : out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- The next sample is read from the rx fifo and available at the sample_data-port at the same cycle when READ_SAMPLE -port goes high
		READ_SAMPLE    : in std_logic;
		-- Indicates that a valid sample is available in the sample_data port
		SAMPLE_VALID : out std_logic;
		--  The sample in sample_data port at the current cycle is the last sample.
		LAST_SAMPLE    : out std_logic;
        -- TUSER bus output from the RX fifo
		TUSER_DATA_OUT		: out std_logic_vector(C_S_AXIS_TUSER_WIDTH-1 downto 0);
		--TSTRB out
		TSTRB_DATA_OUT		: out std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
        -- END: addition to the Xilinx generated code 
		S_AXIS_TUSER      : in std_logic_vector((C_S_AXIS_TUSER_WIDTH-1) downto 0 ) := (others => '0');
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end ECG_Unit_v1_0_S00_AXIS;

architecture arch_imp of ECG_Unit_v1_0_S00_AXIS is
begin


samples_in: axis_fifo	generic map(	C_FIFO_DEPTH				=> 		C_S_FIFO_DEPTH,
										C_AXIS_TDATA_WIDTH 			=> 		C_S_AXIS_TDATA_WIDTH,
										C_M_START_COUNT 			=> 		C_S_START_COUNT,
										C_AXIS_TUSER_WIDTH			=>		C_S_AXIS_TUSER_WIDTH,
										TUSER_EN					=>		S_TUSER_EN,
										TSTRB_EN					=>		S_TSTRB_EN,
										TLAST_EN					=>		S_TLAST_EN,
										TLAST_GEN					=>		S_TLAST_GEN,
										TLAST_PROP					=>		S_TLAST_PROP,
										PACKET_LENGTH				=>		S_PACKET_LENGTH,
										CLOCK_CONV_EN				=>		CLOCK_CONV_EN,
										SYSTEM_CLK_FREQ				=>		SYSTEM_CLK_FREQ,
										SAMPLE_FREQ					=>		SAMPLE_FREQ									
										)
										
						port map(		-- Global ports
										-- clock
										AXIS_ACLK					=>		S_AXIS_ACLK,
										-- reset: active low
										AXIS_ARESETN				=>		S_AXIS_ARESETN,
										-- AXIS_SLAVE ports
										S_AXIS_TREADY				=>		S_AXIS_TREADY, 
										-- Data in
										S_AXIS_TDATA				=>		S_AXIS_TDATA,
										-- Byte qualifier
										S_AXIS_TSTRB				=>		S_AXIS_TSTRB,
										-- Indicates boundary of last packet
										S_AXIS_TLAST				=>		S_AXIS_TLAST,
										-- Data is in valid
										S_AXIS_TVALID				=>		S_AXIS_TVALID,
										S_AXIS_TUSER				=>		S_AXIS_TUSER,
										
										
										--THE FOLLOWING PORTS GIVES ACCESS TO THE INPUT FIFO USING AXIS PROTOCOL
										-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
										M_AXIS_TVALID				=>		SAMPLE_VALID,
										-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
										M_AXIS_TDATA				=>		SAMPLE_DATA,
										-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
										M_AXIS_TSTRB				=>		TSTRB_DATA_OUT,
										-- TLAST indicates the boundary of a packet.
										M_AXIS_TLAST				=>		LAST_SAMPLE,
										-- TREADY indicates that the slave can accept a transfer in the current cycle.
										M_AXIS_TREADY				=>		READ_SAMPLE,
										M_AXIS_TUSER				=>		TUSER_DATA_OUT);

end arch_imp;
