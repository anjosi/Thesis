----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2015 09:31:03 AM
-- Design Name: 
-- Module Name: QRSDetector - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.ecg_components.peakDetector;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QRSDetector is
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
end QRSDetector;

architecture Behavioral of QRSDetector is

  signal threshold_r, threshold_data_in_x : std_logic_vector(C_QRSDET_DATA_WIDTH-1 downto 0);
  signal threshold_addr_r : std_logic_vector(C_QRSDET_ADDR_WIDTH-1 downto 0);
  signal suspension_delay, sus_threshold : unsigned(C_QRSDET_DATA_WIDTH-1 downto 0);
  signal peak_detected_x, peak_detected_r, rst_x, threshold_state : std_logic;
begin

qrs_peakDetector:	peakDetector 	generic map	( 	C_PEAKDET_DATA_WIDTH => C_QRSDET_DATA_WIDTH
												)
									port map	(	clk => clk,
													rst_n => rst_x,
													clk_en => clk_en,
													data_in => data_in,
													threshold => threshold_r,
													peak_value => open,
													peak_delay => open,
													peak_detected => peak_detected_x
												);
									
rst_x <= rst_n;
qrs_detected <= peak_detected_r;	
threshold_data_in_x <= thresholdData_in;
thresholdAddr_out <= threshold_addr_r;

	delay_proc:process(clk)
  begin
    if rising_edge(clk) then
		if rst_n = '0' then
			peak_detected_r <= '0';
			suspension_delay <= (0 => '1', others => '0');
			sus_threshold <= (others => '0');
			threshold_r <= (others => '0');
			threshold_addr_r <= (2 => '1', others => '0');
		else
			if peak_detected_x = '1' and peak_detected_r = '0' then
				peak_detected_r <= '1';				
			end if;
			
			if threshold_addr_r(2) = '1' then
				threshold_addr_r <= (others => '0');
				sus_threshold <= unsigned(threshold_data_in_x);
			else
				threshold_addr_r <= (2 => '1', others => '0');
				threshold_r <= threshold_data_in_x;
			end if;
			
			if clk_en = '1' then
				if peak_detected_r = '1' then
					suspension_delay <= suspension_delay + to_unsigned(1, C_QRSDET_DATA_WIDTH);
				end if;
				if suspension_delay >= sus_threshold then
					peak_detected_r <= '0';
					suspension_delay <= (0 => '1', others => '0');
				end if;
			end if;
		end if;
	end if;
end process;
 
  
 end Behavioral;
