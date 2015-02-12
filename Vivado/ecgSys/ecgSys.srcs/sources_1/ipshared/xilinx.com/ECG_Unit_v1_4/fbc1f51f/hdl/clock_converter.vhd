----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Antti Siirilä
-- 
-- Create Date: 12/09/2014 07:29:32 AM
-- Design Name: 
-- Module Name: clock_converter - Behavioral
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
-----------------------------------------------------------------------------
-- mod: 			  
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_converter is
	generic (
			CLOCK_RATE_IN_HZ	: integer := 100000000;
			CLOCK_RATE_OUT_HZ	: integer := 500
	);
	port (
			rst		: in std_logic;
			clk_in	: in std_logic;
			clk_out	: out std_logic
	);
end clock_converter;

architecture clock_behaviour of clock_converter is
constant CLOCK_DIVIDER : integer := ((CLOCK_RATE_IN_HZ/CLOCK_RATE_OUT_HZ));

	signal count	: integer;
	signal r_clk_out	: std_logic;

begin
clk_out <= r_clk_out;
clock_div: process(clk_in)
	begin
		if rising_edge(clk_in) then
			if rst = '0' then
				count <= 0;
				r_clk_out <= '0';
			else
				if count = CLOCK_DIVIDER-1 then
					r_clk_out <= '1';
					count <= 0;
				else
					count <= count + 1;
					r_clk_out <= '0';
				end if;
			end if;
		end if;
		
end process clock_div;

end clock_behaviour;