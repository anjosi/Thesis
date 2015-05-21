----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/19/2015 18:31:03 PM
-- Design Name: 
-- Module Name: PQRSTDetector - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: The PQRSTDetector module detects the R-wave and validates whether it fall into normal or abnormal range.
--				The R-wave detection is only enable when the QRS detected singal is high. The detection is done over the de-noised ECG signal which is delayed
--				so that in the arrival of the QRS_detected signal the de-noised ECG signal is rising towards the maximum value of R-wave. If the peak value of R-wave
--				falls between the minimum and maximum threshold the peak_data_valid_out is set to high. Conversely, if the threshold check up fails, the ecg_abn signal is
--				set high. 
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
use work.ecg_components.counter;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PQRSTDetector is
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
end PQRSTDetector;

architecture Behavioral of PQRSTDetector is
signal peak_amp_x, peak_amp_r, peak_delay_x, peak_delay_r, amp_threshold_r, delay_x		:	std_logic_vector(C_PQRSTDET_DATA_WIDTH-1 downto 0);
signal r_max_r, r_min_r											:	std_logic_vector(C_PQRSTDET_DATA_WIDTH-1 downto 0);
signal thresholdAddr_r											:	std_logic_vector(C_PQRSTDET_ADDR_WIDTH-1 downto 0);
signal qrs_detected_x, r_detected_x, r_detected_r, peak_data_valid_r, enable_delay, ecg_abn_r 				:	std_logic;
type threshold_state is (INIT, PEAK, R_MIN, R_MAX);
signal c_state, n_state											:	threshold_state;

begin

R_wave_detection:	peakDetector 	generic map	( 	C_PEAKDET_DATA_WIDTH => C_PQRSTDET_DATA_WIDTH
												)
									port map	(	clk => clk,
													rst_n => (rst_n and qrs_detected_x),				-- the R-wave detection is only allowed when the QRS detected signal is high
													clk_en => clk_en,
													data_in => data_in,
													threshold => amp_threshold_r,
													peak_value => peak_amp_x,
													peak_delay => peak_delay_x,
													peak_detected => r_detected_x
												);
									
delay_counter:		counter			generic map	(	n => C_PQRSTDET_DATA_WIDTH
												)
									port map	(
													clock 	=> clk,
													clear 	=> (rst_n and enable_delay),
													count	=> (clk_en and enable_delay),
													Q		=> delay_x
												);
thresholdAddr_out <= thresholdAddr_r;
qrs_detected_x <= qrs_detected;
peak_data_valid_out <= peak_data_valid_r;						-- indicate the statistic unit about the valid data in the peak_data_out bus
ecg_abn <= ecg_abn_r;											-- signal the statistic unit with abn signal in case of an abnormal detection
peak_data_out <= peak_amp_r;
enable_delay <= '0';
	
R_wave_validation:process(clk)

		begin
		
		if rising_edge(clk) then
		
			if rst_n = '0' then								-- reset all registers
				r_detected_r <= '0';
				peak_data_valid_r <= '0';
				ecg_abn_r <= '0';
				peak_amp_r <= (others => '0');
				peak_delay_r <= (others => '0');
			else
				ecg_abn_r <= '0';							-- set the abnormal ecg detected signal to zero as default.
				
				if r_detected_x = '1' then					-- capture the R-wave from the peakDetector
					r_detected_r <= '1';
					peak_amp_r <= peak_amp_x;
					peak_delay_r <= peak_delay_x;
				end if;
				
					
				if r_detected_r = '1' then					-- validate the R-wave
					r_detected_r <= '0';					-- make sure that you only visit once here for each detected R-wave 
					if peak_amp_r > r_max_r then
						ecg_abn_r <= '1';					-- the peak value of R-wave exceeds the max-threshold.
					elsif peak_amp_r < r_min_r then
						ecg_abn_r <= '1';					-- the peak value of R-wave goes under the min-threshold.
					else
						peak_data_valid_r <= '1';			-- the R-wave is valid, and its peak value is ready to be read from the peak_data_out bus.
					end if;
				end if;
				
				if peak_data_valid_r = '1' then
					peak_data_valid_r <= '0';				-- peak value is only available for one clock cycle.
					peak_amp_r <= (others => '0');
					peak_delay_r <= (others => '0');
				end if;
				

			end if;
		end if;
end process;
												
threshold_state_reg:process(clk)							-- state register of the threshold memory controller
	
		begin
		
		if rising_edge(clk) then
		
			if rst_n = '0' then
				c_state <= INIT;
			
			else
				c_state <= n_state;
			end if;
		end if;
end process;

threshold_output:process(clk)												-- this process constantly updates the threshold values from the control unit.

		begin
		
		if rising_edge(clk) then
		
			if rst_n = '0' then
				amp_threshold_r <= (others => '0');
				r_max_r <= (others => '0');
				r_min_r <= (others => '0');
			else
				case c_state is
				
					when INIT =>
						thresholdAddr_r <= (3 => '1', others => '0');			-- assign the address for the peakDetector's threshold value	(2)
					when PEAK =>
						amp_threshold_r <= thresholdData_in;					-- read the peakDetector's threshold
						thresholdAddr_r <= (3 => '1', 2 => '1', others => '0');	-- assign the address for the threshold of minimum R wave		(3)
					when R_MIN =>
						r_min_r <= thresholdData_in;							-- read the threshold value for R_min
						thresholdAddr_r <= (4 => '1', others => '0');			-- assign the address for the threshold of maximum R wave		(4)
					when R_MAX =>
						r_max_r <= thresholdData_in;							-- read the threshold value for R_max
						thresholdAddr_r <= (3 => '1', others => '0');			-- assign the address for the peakDetector's threshold value	(2)
					when others =>
						r_max_r <= r_max_r;										-- keep the current values
						r_min_r <= r_min_r;
						amp_threshold_r <= amp_threshold_r;
				end case;
			end if;
		end if;
end process;

threshold_comb:process(c_state)													-- the combinational logic of the threshold memory controller

	begin
		case c_state is
			when INIT =>
				n_state <= PEAK;
			when PEAK =>
				n_state <= R_MIN;				
			when R_MIN =>
				n_state <= R_MAX;			
			when R_MAX =>
				n_state <= PEAK;			
			when others =>
				n_state <= INIT;
		
		
		end case;
		
end process;

 
  
 end Behavioral;
