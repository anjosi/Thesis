----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/13/2015 02:51:28 PM
-- Design Name: 
-- Module Name: tb_QRSDet - Behavioral
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
--use work.ecg_components.QRSDetector;
use work.ecg_components.PQRSTDetector;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_QRSDet is
--  Port ( );
end tb_QRSDet;

architecture Behavioral of tb_QRSDet is
signal threshold_data, data, peak_data_out_x, peak_data_out_r : std_logic_vector(31 downto 0);
signal threshold_addr, peak_addr_out_x : std_logic_vector(6 downto 0);
signal qrs_detected_x, peak_data_valid_out_x, ecg_abn : std_logic;
signal rst : std_logic := '0';
signal clk : std_logic := '0';
signal clk_en : std_logic := '1';
signal counter_1 : integer range 0 to 127 := 0;
type states is (INIT, RUN);
signal current_s, next_s : states;



begin

	clk <= not clk after 10 ns;
	-- DUT: QRSDetector 	generic map	(
										-- C_QRSDET_DATA_WIDTH => 32,
										-- C_QRSDET_ADDR_WIDTH => 7
									-- )
						-- port map 	(	
										-- data_in   => data,
										-- thresholdData_in => threshold_data,
										-- clk      => clk,
										-- rst_n    => rst,
										-- clk_en   => clk_en,
										-- qrs_detected => qrs_detected_x,
										-- thresholdAddr_out => threshold_addr
									-- );                                               
	DUT: PQRSTDetector 	generic map	(
										C_PQRSTDET_DATA_WIDTH => 32,
										C_PQRSTDET_ADDR_WIDTH => 7
									)
						port map 	(	
										data_in   => data,
										thresholdData_in => threshold_data,
										clk      => clk,
										rst_n    => rst,
										clk_en   => clk_en,
										qrs_detected => qrs_detected_x,
										thresholdAddr_out => threshold_addr,
										peak_data_out => peak_data_out_x,
										peak_addr_out => peak_addr_out_x,
										peak_data_valid_out => peak_data_valid_out_x,
										ecg_abn => ecg_abn
									);                                               

-- state register
state_reg:process(clk)
begin

if rising_edge(clk) then

		if rst = '0' then
			current_s <= INIT;
		else
			current_s <= next_s;
		end if;

end if;

end process;
-- DUT otuput capture
scoreboard:process(clk)
begin

if rising_edge(clk) then

		if rst = '0' then
			peak_data_out_r <= (others => '0');
		else
			if peak_data_valid_out_x = '1' then
				peak_data_out_r <= peak_data_out_x;
			end if;
		end if;

end if;


end process;

-- output logic
slave_if:process(clk, current_s, data)
begin
if rising_edge(clk) then

	case current_s is
		when INIT =>
			data <= (others => '0');
		when RUN =>
			case counter_1 is
				when 2 to 12 =>
					qrs_detected_x <= '1';
					data <= std_logic_vector((unsigned(data) + to_unsigned(10,32)));
				when 13 to 23 =>
					qrs_detected_x <= '0';
					data <= std_logic_vector((unsigned(data) - to_unsigned(10,32)));
				when 24 to 34 =>
					data <= std_logic_vector((unsigned(data) + to_unsigned(10,32)));
				when 35 to 45 =>
					data <= std_logic_vector((unsigned(data) - to_unsigned(10,32)));
				when 46 to 56 =>
					qrs_detected_x <= '1';
					data <= std_logic_vector((unsigned(data) + to_unsigned(10,32)));
				when 57 to 67 =>
					data <= std_logic_vector((unsigned(data) - to_unsigned(10,32)));
				when 68 to 78 =>
					data <= std_logic_vector((unsigned(data) + to_unsigned(10,32)));
				when 79 to 89 =>
					data <= std_logic_vector((unsigned(data) - to_unsigned(10,32)));
				when 90 to 100 =>
					data <= std_logic_vector((unsigned(data) + to_unsigned(10,32)));
				when 101 to 111 =>
					qrs_detected_x <= '0';
					data <= std_logic_vector((unsigned(data) - to_unsigned(10,32)));
				when 112 to 122 =>
					data <= std_logic_vector((unsigned(data) + to_unsigned(10,32)));
				when 123 to 126 =>
					qrs_detected_x <= '1';
					data <= std_logic_vector((unsigned(data) - to_unsigned(10,32)));
				when others =>
					data <= (others => '0');
			end case;
	end case;
end if;
end process;

-- combinational logic
combinational_logic:process(current_s, counter_1)
begin
	next_s <= current_s;

	case current_s is
		when INIT =>
			if counter_1 >= 2 then
				rst <= '1';
				next_s <= RUN;
			end if;
		when RUN =>

	end case;
end process;

-- threshold memory
threshold_mem:process(threshold_addr)
begin


	case threshold_addr is
		when "0001000" =>
			threshold_data <= std_logic_vector(to_unsigned(60, 32));
		when "0001100" =>
			threshold_data <= std_logic_vector(to_unsigned(80, 32));
		when "0010000" =>
			threshold_data <= std_logic_vector(to_unsigned(120, 32));
		when others =>
			threshold_data <= std_logic_vector(to_unsigned(0, 32));
	end case;
end process;


-- counter to give some timing in the test sequence
counter:process(clk)
begin

if rising_edge(clk) then

		if counter_1 < 127 then
			counter_1 <= counter_1 + 1;
		else
			counter_1 <= 0;
		end if;

end if;

end process;


end Behavioral;


