----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/09/2015 09:10:40 AM
-- Design Name: 
-- Module Name: mul_tb - Behavioral
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mul_tb is
--  Port ( );
end mul_tb;

architecture Behavioral of mul_tb is

component multiplier
  generic(
    MUL_DATA_WIDTH       : integer := 32;
    MUL_FRACTION_PORTION : integer := 16

    );

  port(
    clk    : in  std_logic;
  rst    : in  std_logic;
  clk_en : in  std_logic;
--  d_valid_in: in std_logic;
--  t_last_in : in std_logic;
--  t_last_out : out std_logic;
--  d_valid_out:out std_logic;
  a      : in  std_logic_vector(MUL_DATA_WIDTH-1 downto 0);
  b      : in  std_logic_vector(MUL_DATA_WIDTH-1 downto 0);
  p      : out std_logic_vector(MUL_DATA_WIDTH-1 downto 0)
    );
end component multiplier;
signal a, b, p, p_r : std_logic_vector(31 downto 0);
signal clk_en, rst, d_valid_in, d_valid_out, t_last_in, t_last_out : std_logic := '0';
signal clk : std_logic := '1';
signal i : integer;
begin

--dut: multiplier generic map (MUL_DATA_WIDTH => 32, MUL_FRACTION_PORTION => 0)
--                port map(clk => clk, rst => rst, clk_en => clk_en, 
--                d_valid_in => d_valid_in, d_valid_out => d_valid_out,
--                t_last_in => t_last_in, t_last_out => t_last_out,
--                a => a, b => b, p => p);

dut: multiplier generic map (MUL_DATA_WIDTH => 32, MUL_FRACTION_PORTION => 0)
                port map(clk => clk, rst => rst, clk_en => clk_en,
                a => a, b => b, p => p);
                
                
                clk <= not clk after 10 ns;
                
                tb_flow:process
                begin
                    a <= (17 => '1', others => '0');
                    b <= (17 => '1', others => '0');
                    wait for 20 ns;
                    rst <= '1';
                    wait for 20 ns;
                    clk_en <= '1';
                    wait for 20 ns;
                    d_valid_in <= '1';
                    wait for 60 ns;
                     a <= (18 => '1', others => '0');
                     t_last_in <= '1';
                     wait for 20 ns;
                     b <= (18 => '1', others => '0');
                     clk_en <= '0';
                     wait for 40 ns;
                     clk_en <= '1';
                     --for i in 0 to 80 loop
                     
                    wait for 1600 ns;
                    t_last_in <= '0';
                    d_valid_in <= '0';
                    wait;
                    
                
                end process;
                
                reg_proc:process(clk)
                begin
                if rising_edge(clk) then
                    if rst = '0' then
                        p_r <= (others => '0');
                     else
                        if d_valid_out = '1' then
                         p_r <= p;
                         end if;
                         
                      end if;
                  end if;
                  end process reg_proc;

end Behavioral;
