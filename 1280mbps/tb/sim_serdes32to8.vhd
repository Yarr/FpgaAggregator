-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    20:43:11 07/02/2018
-- Design Name:
-- Module Name:    sim_serdes32to8 - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the component serdes32to8.
--
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_serdes32to8 is
end sim_serdes32to8;

architecture Behavioral of sim_serdes32to8 is

  -- Component Declaration for the Unit Under Test (UUT)
  component serdes32to8
  port (
    -- Sys connect
    rst_i               : in  std_logic;
    clk_i               : in  std_logic;
    -- Inputs
    data32_i            : in  std_logic_vector(31 downto 0);
    data32_valid_i      : in  std_logic;
    --Outputs
    data8_o             : out std_logic_vector(7 downto 0)
  );
  end component;

  -- Sys connect
  signal rst_i          : std_logic                           := '0';
  signal clk_i          : std_logic                           := '0';

  -- Input
  signal data32_i       : std_logic_vector (31 downto 0)      := (others=>'0');
  signal data32_valid_i : std_logic;

  --Outputs
  signal data8_o        : std_logic_vector(7 downto 0);

  -- Generics constants
  constant RATIO        : integer := 1;

  -- Clock period definitions
  constant CLK_PERIOD   : time := 6 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : serdes32to8
  port map (
    clk_i => clk_i,
    rst_i => rst_i,
    data32_i => data32_i,
    data32_valid_i => data32_valid_i,
    data8_o => data8_o
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
    variable err_cnt : integer                        := 0;
    constant DATA1   : std_logic_vector (31 downto 0) := x"deadbeef";
    constant DATA2   : std_logic_vector (31 downto 0) := x"cafebabe";
  begin

    -- reset
    rst_i <= '1';
    wait for CLK_PERIOD;

    -- Initial value and run
    rst_i <= '0';
    data32_i <= DATA1;
    data32_valid_i <= '1';
    wait for CLK_PERIOD/2;     --Place the assert in the middle of a clock cycle
    data32_valid_i <= '0';

    for i in 0 to 3 loop
      -- check data output
      assert (data8_o = DATA1(31 - (i*8) downto 24 - (i*8)))
      report "Not the expected output"
      severity error;
      if data8_o /= DATA1(31 - (i*8) downto 24 - (i*8)) then
        err_cnt := err_cnt + 1;
      end if;

      -- Run
      wait for CLK_PERIOD*RATIO;
    end loop;

   wait for CLK_PERIOD/2;      -- Compensate the 1/2 clock cycle

   data32_i <= DATA2;
   data32_valid_i <= '1';
   wait for CLK_PERIOD/2;      --Place the assert in the middle of a clock cycle;
   data32_valid_i <= '0';

    for i in 0 to 3 loop
     -- check data output
     assert (data8_o = DATA2(31 - (i*8) downto 24 - (i*8)))
     report "Not the expected output"
     severity error;
     if data8_o /= DATA2(31 - (i*8) downto 24 - (i*8)) then
       err_cnt := err_cnt + 1;
     end if;

     -- Run
     wait for CLK_PERIOD*RATIO;
   end loop;

    -- summary
    if (err_cnt = 0) then
      assert false
      report "Testbench sim_serdes32to8 terminated without any error"
      severity note;
    else
      assert false
      report "Testbench sim_serdes32to8 terminated with error"
      severity error;
    end if;

    wait;
  end process;

end Behavioral;
