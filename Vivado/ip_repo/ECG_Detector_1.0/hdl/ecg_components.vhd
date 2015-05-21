----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/09/2014 10:43:50 AM
-- Design Name: 
-- Module Name: ecg_components - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.all;

package ecg_components is

component axis_fifo
	generic (
		-- Users to add parameters here
		C_FIFO_DEPTH	: integer := 10;
		C_AXIS_TUSER_WIDTH	: integer	:= 8;
		TUSER_EN	: boolean	:= false;
		TSTRB_EN	: boolean	:= false;
		TLAST_EN	: boolean   := true;
		TLAST_GEN	: boolean	:= false;
		TLAST_PROP	: boolean	:= false;
		PACKET_LENGTH	: integer	:= 5;
		CLOCK_CONV_EN	: boolean := false;
        SYSTEM_CLK_FREQ  : integer   := 100000000;
        SAMPLE_FREQ         : integer := 500;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_AXIS_TDATA_WIDTH.
		C_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic := '0';
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic;
		
		S_AXIS_TUSER	: in std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0) := (others => '0');
		M_AXIS_TUSER	: out std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0);
		SAMPLE_VALID    : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		AXIS_ACLK	: in std_logic;
		-- 
		AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
	

end component;

component multiplier
  generic(
    MUL_DATA_WIDTH       : integer := 32;
    MUL_FRACTION_PORTION : integer := 16

    );

  port(
    clk    : in  std_logic;
    clk_en : in  std_logic;
    rst    : in  std_logic;
    a      : in  std_logic_vector(MUL_DATA_WIDTH-1 downto 0);
    b      : in  std_logic_vector(MUL_DATA_WIDTH-1 downto 0);
    p      : out std_logic_vector(MUL_DATA_WIDTH-1 downto 0)
    );
end component multiplier;


component thresholder
	generic (
            C_THRESH_DATA_WIDTH : integer := 32;
			C_THRESH_ADDR_WIDTH	: integer := 7
            );
    Port ( data_in : in STD_LOGIC_VECTOR (C_THRESH_DATA_WIDTH-1 downto 0);
         data_out : out std_logic_vector (C_THRESH_DATA_WIDTH-1 downto 0);
		 threshold_data_in : in  std_logic_vector (C_THRESH_DATA_WIDTH-1 downto 0);
		 threshold_data_addr : out std_logic_vector (C_THRESH_ADDR_WIDTH-1 downto 0);
         clk      : in  std_logic;
         rst_n    : in  std_logic;
         clk_en   : in  std_logic);
end component thresholder;

component peakDetector
  generic (
    C_PEAKDET_DATA_WIDTH : integer := 32

    );
  port (

		data_in 		: in  std_logic_vector (C_PEAKDET_DATA_WIDTH-1 downto 0);
		threshold 		: in std_logic_vector(C_PEAKDET_DATA_WIDTH-1 downto 0);
        clk      		: in  std_logic;
        rst_n    		: in  std_logic;
        clk_en   		: in  std_logic;
		peak_value 		: out std_logic_vector (C_PEAKDET_DATA_WIDTH-1 downto 0);
		peak_delay 		: out std_logic_vector (C_PEAKDET_DATA_WIDTH-1 downto 0);
		peak_detected	: out std_logic);
end component peakDetector;

component QRSDetector
  generic (
    C_QRSDET_DATA_WIDTH : integer := 32;
	C_QRSDET_ADDR_WIDTH	: integer := 7
	
    );
  port (

		 data_in : in  std_logic_vector (C_QRSDET_DATA_WIDTH-1 downto 0);
		 thresholdData_in : in  std_logic_vector (C_QRSDET_DATA_WIDTH-1 downto 0):= (others => '0');
         clk      : in  std_logic;
         rst_n    : in  std_logic;
         clk_en   : in  std_logic;
		 thresholdAddr_out : out std_logic_vector (C_QRSDET_ADDR_WIDTH-1 downto 0);
		 qrs_detected	: out std_logic);
end component QRSDetector;

component counter

generic(n: integer := 32);
port(	clock:	in std_logic;
	clear:	in std_logic;
	count:	in std_logic;
	Q:	out std_logic_vector(n-1 downto 0)
);
end component counter;

component PQRSTDetector is
  generic (
    C_PQRSTDET_DATA_WIDTH : integer := 32;
	C_PQRSTDET_ADDR_WIDTH	: integer := 7
	
    );
  port (

		 data_in 				: in  std_logic_vector (C_PQRSTDET_DATA_WIDTH-1 downto 0);
		 thresholdData_in 		: in  std_logic_vector (C_PQRSTDET_DATA_WIDTH-1 downto 0);
         clk      				: in  std_logic;
         rst_n    				: in  std_logic;
         clk_en   				: in  std_logic;
		 qrs_detected	 		: in std_logic;
		 thresholdAddr_out 		: out std_logic_vector (C_PQRSTDET_ADDR_WIDTH-1 downto 0);
		 peak_data_out			: out std_logic_vector(C_PQRSTDET_DATA_WIDTH-1 downto 0);
		 peak_addr_out			: out std_logic_vector (C_PQRSTDET_ADDR_WIDTH-1 downto 0);
		 peak_data_valid_out	: out std_logic;
		 ecg_abn 	: out std_logic);
end component PQRSTDetector;


end package;
