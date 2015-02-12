library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ecg_components.all;

entity ECG_Unit_v1_0_M00_AXIS is
	generic (
		-- Users to add parameters here
        M_TSTRB_EN    : boolean   := false;
        M_TLAST_EN    : boolean   := true;
        M_TUSER_EN  : boolean   := false;
		M_TLAST_GEN	: boolean	:= false;
		M_TLAST_PROP	: boolean	:= false;
		M_PACKET_LENGTH	: integer	:= 5;
		CLOCK_CONV_EN	: boolean := false;
        SYSTEM_CLK_FREQ  : integer   := 100000000;
        SAMPLE_FREQ         : integer := 500;
        C_M_AXIS_TUSER_WIDTH    : integer := 4;
        C_M_FIFO_DEPTH  : integer   := 16;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		-- BEGIN: addition to the Xilinx generated code
		-- Sample data in
		SAMPLE_DATA    : in std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- the axis master IF is ready to write a sample into its tx fifo
		WRITE_SAMPLE    : out std_logic;
		-- Indicates that a valid sample is available in the sample_data port
		SAMPLE_VALID : in std_logic;
		--  The sample in sample_data port at the current cycle is the last sample.
		LAST_SAMPLE    : in std_logic;
        -- TUSER bus input to the TX fifo
		TUSER_DATA_IN		: in std_logic_vector(C_M_AXIS_TUSER_WIDTH-1 downto 0) := (others => '0');
		--TSTRB in
		TSTRB_DATA_IN		: in std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- END: addition to the Xilinx generated code 
		M_AXIS_TUSER      : out std_logic_vector((C_M_AXIS_TUSER_WIDTH-1) downto 0 ) := (others => '0');

		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end ECG_Unit_v1_0_M00_AXIS;

architecture implementation of ECG_Unit_v1_0_M00_AXIS is

begin
samples_out: axis_fifo	generic map(	C_FIFO_DEPTH				=> 		C_M_FIFO_DEPTH,
										C_AXIS_TDATA_WIDTH 			=> 		C_M_AXIS_TDATA_WIDTH,
										C_M_START_COUNT 			=> 		C_M_START_COUNT,
										C_AXIS_TUSER_WIDTH			=>		C_M_AXIS_TUSER_WIDTH,
										TUSER_EN					=>		M_TUSER_EN,
										TSTRB_EN					=>		M_TSTRB_EN,
										TLAST_EN					=>		M_TLAST_EN,
										TLAST_GEN					=>		M_TLAST_GEN,
										TLAST_PROP					=>		M_TLAST_PROP,
										PACKET_LENGTH				=>		M_PACKET_LENGTH,
										CLOCK_CONV_EN				=>		CLOCK_CONV_EN,
										SYSTEM_CLK_FREQ				=>		SYSTEM_CLK_FREQ,
										SAMPLE_FREQ					=>		SAMPLE_FREQ									
										)
										
						port map(		-- Global ports
										-- clock
										AXIS_ACLK					=>		M_AXIS_ACLK,
										-- reset: active low
										AXIS_ARESETN				=>		M_AXIS_ARESETN,
										-- AXIS_SLAVE ports
										S_AXIS_TREADY				=>		WRITE_SAMPLE, 
										-- Data in
										S_AXIS_TDATA				=>		SAMPLE_DATA,
										-- Byte qualifier
										S_AXIS_TSTRB				=>		TSTRB_DATA_IN,
										-- Indicates boundary of last packet
										S_AXIS_TLAST				=>		LAST_SAMPLE,
										-- Data in is valid
										S_AXIS_TVALID				=>		SAMPLE_VALID,
										S_AXIS_TUSER				=>		TUSER_DATA_IN,
										
										
										--THE FOLLOWING PORTS GIVES ACCESS TO THE INPUT FIFO USING AXIS PROTOCOL
										-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
										M_AXIS_TVALID				=>		M_AXIS_TVALID,
										-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
										M_AXIS_TDATA				=>		M_AXIS_TDATA,
										-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
										M_AXIS_TSTRB				=>		M_AXIS_TSTRB,
										-- TLAST indicates the boundary of a packet.
										M_AXIS_TLAST				=>		M_AXIS_TLAST,
										-- TREADY indicates that the slave can accept a transfer in the current cycle.
										M_AXIS_TREADY				=>		M_AXIS_TREADY,
										M_AXIS_TUSER				=>		M_AXIS_TUSER);

end implementation;
