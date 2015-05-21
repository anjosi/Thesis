----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2015 09:31:03 AM
-- Design Name: 
-- Module Name: peakDetector - Behavioral
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity peakDetector is
  generic (
    C_PEAKDET_DATA_WIDTH : integer := 32

    );
  port (

		data_in 			: in	std_logic_vector (C_PEAKDET_DATA_WIDTH-1 downto 0);
		threshold			: in	std_logic_vector(C_PEAKDET_DATA_WIDTH-1 downto 0);
        clk      			: in	std_logic;
        rst_n    			: in	std_logic;
        clk_en   			: in	std_logic;
		peak_value 			: out	std_logic_vector (C_PEAKDET_DATA_WIDTH-1 downto 0);
		peak_delay 			: out	std_logic_vector (C_PEAKDET_DATA_WIDTH-1 downto 0);
		peak_detected		: out	std_logic);
end peakDetector;

architecture Behavioral of peakDetector is

  signal data_in_r, data_in_x, half_peak_x, peak_r, peak_delayed		: std_logic_vector(C_PEAKDET_DATA_WIDTH-1 downto 0);
  type fsm_states is (INIT, IDLE, RISE, FALL);
  signal current_state, next_state									: fsm_states;
  signal sample_count												: integer range 0 to 1023;
  signal peak_detected_r, peak_detected_x, peak_state : std_logic;
begin


	-- define which value 
	data_in_x <= data_in_r when (peak_detected_x = '1') else data_in;
	
	half_peak_x <= '0' & peak_r(C_PEAKDET_DATA_WIDTH-1 downto 1);
	
	peak_delay <= std_logic_vector( to_unsigned(sample_count, C_PEAKDET_DATA_WIDTH));
	peak_value <= peak_delayed;
	peak_detected <= peak_detected_r;

pipeline_regs:process(clk)

	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				data_in_r 	<= (others => '0');									
				peak_r 		<= data_in;										-- init the max value to the initial input
				peak_delayed <= (others => '0');
				peak_detected_r <= '0';
				peak_state <= '0';
			else
				peak_detected_r <= peak_detected_r;
				if peak_detected_x = '1' then
					peak_detected_r <= '1';
					peak_delayed <= peak_r;
				end if;
				if clk_en = '1' then
					data_in_r <= data_in;									-- always store the current input
					if peak_detected_r = '1' then
						peak_state <= '1';
						peak_detected_r <= '0';
					end if;
					if peak_state = '1' then
						
						peak_state <= '0';
						peak_delayed <= (others => '0');
					end if;

					if next_state = RISE or peak_detected_x = '1' then		-- only store the candidate peak if input is greater than previous input or a peak was detected
						peak_r <= data_in_x;
					end if;
				end if; 
			
			end if;
		
		end if;
	
end process;
 
state_reg:process(clk)

	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				current_state <= INIT;
			else
				current_state <= next_state;
			
			end if;
		
		end if;
	
end process; 

combinational_logic:process(current_state, rst_n, half_peak_x, data_in_r, data_in, peak_r, threshold)

	begin
	--default assignments
	next_state <= current_state;
	peak_detected_x <= '0';
	
	case current_state is
		when INIT =>
			if rst_n = '1' then
				next_state <= IDLE;				-- when reset is done move to IDLE
			end if;
		when IDLE =>
			if data_in > data_in_r then			-- if the current input data is greater than the previous then move to MAX
				next_state <= RISE;
			end if;
		when RISE =>
			if data_in < data_in_r then			-- if then current input is less than then previous move back to IDLE
				next_state <= FALL;
			end if;
		when FALL =>
			if half_peak_x > data_in_r then		-- peak was detected here then move to PEAK
				if threshold < peak_r then
					peak_detected_x <= '1';
					next_state <= IDLE;
				end if;
			elsif data_in > data_in_r then		-- if then current input is less than then previous move back to IDLE
				next_state <= RISE;
			end if;
		when others =>
			next_state <= current_state;
	end case;
	
end process;

delay_counter:process(clk)

	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				sample_count <= 1;
			else
				if clk_en = '1' then
					if data_in > peak_r then					-- reset the sample counter whenever the peak candidate is updated
						sample_count <= 1;
					elsif data_in < peak_r then			-- count the delay when in the IDLE
						sample_count <= sample_count + 1;
					else										-- otherwise keep the current count
						sample_count <= sample_count;
					end if;
				end if;		
			end if;
		
		end if;
	
end process; 
 
 end Behavioral;
