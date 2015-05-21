----------------------------------------------------
-- VHDL code for n-bit counter (ESD figure 2.6)
-- by Weijun Zhang, 04/2001
--
-- this is the behavior description of n-bit counter
-- another way can be used is FSM model. 
----------------------------------------------------
	
library ieee ;
use ieee.std_logic_1164.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

----------------------------------------------------

entity counter is

generic(n: integer := 32);
port(	clock:	in std_logic;
	clear:	in std_logic;
	count:	in std_logic;
	Q:	out std_logic_vector(n-1 downto 0)
);
end counter;

----------------------------------------------------

architecture behv of counter is		 	  
	
    signal Pre_Q: std_logic_vector(n-1 downto 0);

begin

    -- behavior describe the counter

    process(clock, count, clear)
    begin
	if clear = '0' then
 	    Pre_Q <= (others => '0');
	elsif (clock='1' and clock'event) then
	    if count = '1' then
		Pre_Q <= std_logic_vector(unsigned(Pre_Q) + to_unsigned(1,n));
	    end if;
	end if;
    end process;	
	
    -- concurrent assignment statement
    Q <= Pre_Q;

end behv;

-----------------------------------------------------