----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:27:01 05/14/2012 
-- Design Name: 
-- Module Name:    debouncer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer is
		generic (NUMBER_OF_BUTTON : natural := 8; DEBOUNCE_DELAY: natural := 50000);
    Port ( pb_in : in  STD_LOGIC_VECTOR(NUMBER_OF_BUTTON-1 downto 0);
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           pb_out : out  STD_LOGIC_VECTOR(NUMBER_OF_BUTTON-1 downto 0));
end debouncer;

architecture Behavioral of debouncer is
signal FF1, FF2, FF3, en_pb, sclr: STD_LOGIC_VECTOR(NUMBER_OF_BUTTON-1 downto 0);
type tCount is array (NUMBER_OF_BUTTON-1 downto 0) of natural range DEBOUNCE_DELAY-1 to 0;
signal count: tCount;
signal button_index_count, button_index_input : integer;

begin
		--counts the debounce delay
		counter: process(clk)
		begin
			--as default the output is selected to be low

			if clk = '1' and clk'EVENT then
				for button_index_count in 0 to (NUMBER_OF_BUTTON-1) loop
					en_pb(button_index_count) <= '0';
					--reset or clear
					if rst = '0' or sclr(button_index_count) = '1' then
						count(button_index_count) <= 0; --the counter is reset
					-- if the dealay is reached
					elsif count(button_index_count) = DEBOUNCE_DELAY-1 then
						en_pb(button_index_count) <='1'; -- enable output
					-- in any other case increment counter
					else
						count(button_index_count) <= count(button_index_count) + 1;
					end if;
				end loop;
			end if;
		end process counter;
		
		-- clocks the input signal
		clock_input: process(clk)
		begin
			if clk = '1' and clk'EVENT then
				for button_index_input in 0 to NUMBER_OF_BUTTON-1 loop
					if rst = '0' then
						FF1(button_index_input) <= '0'; --take sample of the current input
						FF2(button_index_input) <='0'; -- take sample of the previous input
						FF3(button_index_input) <='0';
					else
						FF1(button_index_input) <= pb_in(button_index_input); --take sample of the current input
						FF2(button_index_input) <=FF1(button_index_input); -- take sample of the previous input
						if en_pb(button_index_input) = '1' then
							FF3(button_index_input) <=FF2(button_index_input); -- take sample of the previous input-1
						end if;
					end if;
				end loop;
			end if;

		end process clock_input;

	concurent:for i in 0 to (NUMBER_OF_BUTTON-1) generate
		sclr(i) <= FF1(i) xor FF2(i); -- xor the current and the previous inputs to produse the counter clear signal if input is bouncing 
		pb_out(i) <= FF3(i);
	end generate;
 end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.ALL;


entity Debouncer_5 is

Port ( pb_in : in  STD_LOGIC_VECTOR(4 downto 0);
   clk : in  STD_LOGIC;
   rst : in  STD_LOGIC;
   pb_out : out  STD_LOGIC_VECTOR(4 downto 0));
end Debouncer_5;
architecture Behavioral_5 of Debouncer_5 is

  component debouncer is
          generic (NUMBER_OF_BUTTON : natural := 8; DEBOUNCE_DELAY: natural := 50000);
      Port ( pb_in : in  STD_LOGIC_VECTOR(NUMBER_OF_BUTTON-1 downto 0);
             clk : in  STD_LOGIC;
             rst : in  STD_LOGIC;
             pb_out : buffer  STD_LOGIC_VECTOR(NUMBER_OF_BUTTON-1 downto 0));
  end component debouncer;
begin

    debounc:debouncer
    generic map(NUMBER_OF_BUTTON => 5, DEBOUNCE_DELAY => 250)
    port map(pb_in => pb_in,
                 clk => clk,
                 rst => rst,
                 pb_out => pb_out);
end Behavioral_5;