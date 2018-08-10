-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    20:48:40 06/28/2018
-- Design Name:
-- Module Name:    sim_gearbox66to32 - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the component gearbox66to32.
--
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_gearbox66to32 is
end sim_gearbox66to32;

architecture Behavioral of sim_gearbox66to32 is

  -- Component Declaration for the Unit Under Test (UUT)
  component gearbox66to32
  generic(
    ratio_g             : integer := 4
  );
  port (
    -- Sys connect
    rst_i               : in  std_logic;
    clk_i               : in  std_logic;
    -- Input
    data66_i            : in  std_logic_vector(65 downto 0);
    -- Output
    data32_o            : out std_logic_vector(31 downto 0);
    data32_valid_o      : out std_logic;
    read_o              : out std_logic
  );
  end component;

  -- Sys connect
  signal rst_i          : std_logic                                := '0';
  signal clk_i          : std_logic                                := '0';

  -- Input
  signal data66_i       : std_logic_vector (65 downto 0)           := (others=>'0');

  --Outputs
  signal data32_o       : std_logic_vector(31 downto 0);
  signal data32_valid_o : std_logic;
  signal read_o         : std_logic;

  -- Generics constants
  constant RATIO : integer := 4;

  -- Clock period definitions
  constant CLK_PERIOD : time := 6 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : gearbox66to32
  generic map (
    ratio_g => RATIO
  )
  port map (
    clk_i => clk_i,
    rst_i => rst_i,
    data66_i => data66_i,
	data32_o => data32_o,
    data32_valid_o => data32_valid_o,
    read_o => read_o
  );

  --Clock process definitions
  Clk_process : process
    begin
    clk_i <= '1';
    wait for CLK_PERIOD/2;
    clk_i <= '0';
    wait for CLK_PERIOD/2;
  end process;

  -- Stimulus process
  stim_proc: process
    variable err_cnt : integer := 0;

    type array1D is array(0 to 32) of std_logic_vector(31 downto 0);
    constant expectedOutput : array1D := (
      x"deadbeef", x"cafebabe", x"37ab6fbb", x"f2bfaeaf", x"8deadbee",
      x"fcafebab", x"e37ab6fb", x"bf2bfaea", x"f8deadbe", x"efcafeba",
      x"be37ab6f", x"bbf2bfae", x"af8deadb", x"eefcafeb", x"abe37ab6",
      x"fbbf2bfa", x"eaf8dead", x"beefcafe", x"babe37ab", x"6fbbf2bf",
      x"aeaf8dea", x"dbeefcaf", x"ebabe37a", x"b6fbbf2b", x"faeaf8de",
      x"adbeefca", x"febabe37", x"ab6fbbf2", x"bfaeaf8d", x"eadbeefc",
      x"afebabe3", x"7ab6fbbf", x"2bfaeaf8"
    );

  begin

    -- reset
    rst_i <= '1';
    wait for CLK_PERIOD;

    -- Initial loop (Some cycles have a partially empty biffer)
    rst_i <= '0';
    data66_i <= x"deadbeefcafebabe" & "00";
    wait for CLK_PERIOD*(RATIO-1);    -- first cycle
    wait for CLK_PERIOD*32*RATIO;     -- other cycles

    -- Place the assertions in a middle of the clock period
    wait for CLK_PERIOD/2 ;

    -- Check all position of the buffer first cycle
    for i in expectedOutput' range loop
      -- check data output
      assert (data32_o = expectedOutput(i))
      report "Cycle 1, count " & integer'image(i) & " not the expected output"
      severity error;
      if data32_o /= expectedOutput(i) then
        err_cnt := err_cnt + 1;
      end if;

      -- check read_data signal
      if i mod 2 = 0 and i /= 32 then
        assert (read_o = '1')
        report "Cycle 1, count " & integer'image(i) & " read not worthing 1"
        severity error;
        if read_o /= '1' then
          err_cnt := err_cnt + 1;
        end if;
      end if;

      wait for CLK_PERIOD*RATIO;
    end loop;

    -- Check all position of the buffer second cycle
    for i in expectedOutput' range loop
      -- check data output
      assert (data32_o = expectedOutput(i))
      report "Cycle 2, count " & integer'image(i) & " not the expected output"
      severity error;
      if data32_o /= expectedOutput(i) then
        err_cnt := err_cnt + 1;
      end if;

      -- check read_data signal
      if i mod 2 = 0 and i /= 32 then
        assert (read_o = '1')
        report "Cycle 2, count " & integer'image(i) & " read not worthing 1"
        severity error;
        if read_o /= '1' then
          err_cnt := err_cnt + 1;
        end if;
      end if;

      wait for CLK_PERIOD*RATIO;
    end loop;

    -- summary
    if (err_cnt = 0) then
      assert false
      report "Testbench sim_gearbox66to32 terminated without any error"
      severity note;
    else
      assert false
      report "Testbench sim_gearbox66to32 terminated with error"
      severity error;
    end if;

    wait;
  end process;

end Behavioral;

------------------------------------
-- Buffer life cycle:
------------------------------------
--cycle   |action          |hex output | buffer (output)                       | buffer (remaining data)
----------+----------------+-----------+---------------------------------------+--------------------------------------------------------------------------------------
--32      |shift           |unknown    |unknown (depends on previous cycle)
--0       |shift & insert  |deadbeef   |1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--1       |shift           |cafebabe   |1100 1010 1111 1110 1011 1010 1011 1110 00
--2       |shift & insert  |37ab6fbb   |0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--3       |shift           |f2bfaeaf   |1111 0010 1011 1111 1010 1110 1010 1111 1000
--4       |shift & insert  |8deadbee   |1000 1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--5       |shift           |fcafebab   |1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--6       |shift & insert  |e37ab6fb   |1110 0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--7       |shift           |bf2bfaea   |1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--8       |shift & insert  |f8deadbe   |1111 1000 1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--9       |shift           |efcafeba   |1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--10      |shift & insert  |be37ab6f   |1011 1110 0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--11      |shift           |bbf2bfae   |1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--12      |shift & insert  |af8deadb   |1010 1111 1000 1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--13      |shift           |eefcafeb   |1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--14      |shift & insert  |abe37ab6   |1010 1011 1110 0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--15      |shift           |fbbf2bfa   |1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--16      |shift & insert  |eaf8dead   |1110 1010 1111 1000 1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--17      |shift           |beefcafe   |1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--18      |shift & insert  |babe37ab   |1011 1010 1011 1110 0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--19      |shift           |6fbbf2bf   |0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--20      |shift & insert  |aeaf8dea   |1010 1110 1010 1111 1000 1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--21      |shift           |dbeefcaf   |1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--22      |shift & insert  |ebabe37a   |1110 1011 1010 1011 1110 0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--23      |shift           |b6fbbf2b   |1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--24      |shift & insert  |faeaf8de   |1111 1010 1110 1010 1111 1000 1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--25      |shift           |adbeefca   |1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--26      |shift & insert  |febabe37   |1111 1110 1011 1010 1011 1110 0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--27      |shift           |ab6fbbf2   |1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--28      |shift & insert  |bfaeaf8d   |1011 1111 1010 1110 1010 1111 1000 1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--29      |shift           |eadbeefc   |1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
--30      |shift & insert  |afebabe3   |1010 1111 1110 1011 1010 1011 1110 0011 0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--31      |shift           |7ab6fbbf   |0111 1010 1011 0110 1111 1011 1011 1111 0010 1011 1111 1010 1110 1010 1111 1000
--32      |shift           |2bfaeaf8   |0010 1011 1111 1010 1110 1010 1111 1000
--0       |shift & insert  |deadbeef   |1101 1110 1010 1101 1011 1110 1110 1111 1100 1010 1111 1110 1011 1010 1011 1110 00
