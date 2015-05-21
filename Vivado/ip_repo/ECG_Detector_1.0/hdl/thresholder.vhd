----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2015 09:31:03 AM
-- Design Name: 
-- Module Name: thresholder - Behavioral
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
--use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity thresholder is
  generic (
    C_THRESH_DATA_WIDTH : integer := 32;
	C_THRESH_ADDR_WIDTH	: integer := 7

    );
  port (data_in   : in  std_logic_vector (C_THRESH_DATA_WIDTH-1 downto 0);
         data_out : out std_logic_vector (C_THRESH_DATA_WIDTH-1 downto 0);
		 threshold_data_in : in  std_logic_vector (C_THRESH_DATA_WIDTH-1 downto 0);
		 threshold_data_addr : out std_logic_vector (C_THRESH_ADDR_WIDTH-1 downto 0);
         clk      : in  std_logic;
         rst_n    : in  std_logic;
         clk_en   : in  std_logic);
end thresholder;

architecture Behavioral of thresholder is

  signal data_in_r, data_out_x, data_out_r : std_logic_vector(C_THRESH_DATA_WIDTH-1 downto 0);
begin


  data_out_x <= data_in_r when (data_in_r >= threshold_data_in) else (others => '0');
  data_out   <= data_out_r;
  threshold_data_addr <= (others => '0'); -- read the r-threshold from the ctrl_axi's threshold memory
  process(clk)
-- the accumulator
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        data_in_r  <= (others => '0');
        data_out_r <= (others => '0');
      else
        if clk_en = '1' then
          data_in_r  <= data_in;
          data_out_r <= data_out_x;
        end if;
      end if;
    end if;
  end process;


end Behavioral;
