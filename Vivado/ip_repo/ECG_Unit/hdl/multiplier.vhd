library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
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
end multiplier;


architecture beh of multiplier is
  signal a_r     : signed(MUL_DATA_WIDTH-1 downto 0);
  signal b_r     : signed(MUL_DATA_WIDTH-1 downto 0);
  signal prod, prod_r : signed((MUL_DATA_WIDTH*2)-1 downto 0);
  signal diff          : signed(MUL_DATA_WIDTH downto 0);
  signal acc, diffe    : signed(MUL_DATA_WIDTH+1 downto 0);
  type sample_delay is array (0 to 74) of signed(31 downto 0); -- 150 ms long pipe (75 * (1/500)) = 0.150 s
  signal pipe : sample_delay;

begin

  p    <= std_logic_vector(acc(MUL_DATA_WIDTH-1 downto 0));
  prod <= a_r * b_r;
  mul : process (clk)
  begin
    if rising_edge(clk) then
      if rst = '0' then
        a_r    <= (others => '0');
        b_r    <= (others => '0');
        prod_r <= (others => '0');
      else
        if clk_en = '1' then
          a_r    <= signed(a);
          b_r    <= signed(b);
          prod_r <= prod;
        end if;
      end if;
    end if;
  end process mul;

	diff <= ('0'&prod_r((MUL_DATA_WIDTH*2)-1 downto MUL_DATA_WIDTH))-('0'&pipe(pipe'high));
	process(diff)
	begin
		diffe <= (others=>diff(MUL_DATA_WIDTH));
		-- fill with the sign bit
		diffe(MUL_DATA_WIDTH-1 downto 0) <= diff(MUL_DATA_WIDTH - 1 downto 0);
	end process;

	process(clk)
	-- the accumulator
	begin
		if rising_edge(clk) then
			if rst = '0' then
				acc <= (others => '0');
				for i in pipe'range loop
					pipe(i) <= (others => '0');
				end loop;
			else
				if clk_en = '1' then
					acc <= acc + diffe;
					pipe(0) <= prod_r((MUL_DATA_WIDTH*2)-1 downto MUL_DATA_WIDTH);
					for i in 1 to pipe'high loop
					   pipe(i) <= pipe(i-1);
					end loop;
				end if;
			end if;
		end if;
	end process;

  
end beh;



    

