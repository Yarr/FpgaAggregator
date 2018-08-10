-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    20:48:40 06/28/2018
-- Design Name:
-- Module Name:    sim_serdes8to1 - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the component serdes8to1.
--
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_serdes8to1 is
end sim_serdes8to1;

architecture Behavioral of sim_serdes8to1 is

  -- Component Declaration for the Unit Under Test (UUT)
  component serdes8to1
  port (
    -- Sys connect
    rst_i               : in  std_logic;
    clk_i               : in  std_logic;
    clkhigh_i           : in  std_logic;
    -- Inputs
    data8_i             : in  std_logic_vector(7 downto 0);
    -- Outputs
    dataout_p           : out std_logic;
    dataout_n           : out std_logic
  );
  end component;

  -- Sys connect
  signal rst_i          : std_logic                           := '0';
  signal clk_i          : std_logic                           := '0';
  signal clkhigh_i      : std_logic                           := '0';

  -- Input
  signal data8_i        : std_logic_vector (7 downto 0)       := (others=>'0');

  --Outputs
  signal dataout_p      : std_logic;
  signal dataout_n      : std_logic;

  -- Clock period definitions
  constant CLK_PERIOD     : time := 6ns;
  constant CLKHIGH_PERIOD : time := 1.5ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : serdes8to1
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    clkhigh_i => clkhigh_i,
    data8_i => data8_i,
    dataout_p => dataout_p,
    dataout_n => dataout_n
  );

  --Clock process definitions
  Clk_process : process
    begin
    clk_i <= '1';
    wait for CLK_PERIOD/2;
    clk_i <= '0';
    wait for CLK_PERIOD/2;
  end process;

  --Clock high process definitions
  Clkdiv_process : process
    begin
    clkhigh_i <= '1';
    wait for CLKHIGH_PERIOD/2;
    clkhigh_i <= '0';
    wait for CLKHIGH_PERIOD/2;
  end process;

  -- Stimulus process
  stim_proc: process
    variable err_cnt : integer := 0;
    constant DATA1   : std_logic_vector (7 downto 0) := x"de";
    constant DATA2   : std_logic_vector (7 downto 0) := x"ad";
  begin
    -- reset
    rst_i <= '1';
    wait for CLK_PERIOD;
    rst_i <= '0';

    -- insert data
    data8_i <= DATA1;
    wait for CLK_PERIOD;
    data8_i <= DATA2;
    wait for CLK_PERIOD;

    -- place assert in the middle
    wait for CLKHIGH_PERIOD/4;

    -- check after 2 clock cycles (due to delay)
    for i in DATA1 'range loop
      -- check data output
      assert (dataout_p = DATA1(i) and dataout_n = not DATA1(i) )
      report "Not the expected output"
      severity error;
      if dataout_p /= DATA1(i) or dataout_n /= not DATA1(i) then
        err_cnt := err_cnt + 1;
      end if;

      -- Run
      wait for CLKHIGH_PERIOD/2;
    end loop;

    for i in DATA2 'range loop
      -- check data output
      assert (dataout_p = DATA2(i) and dataout_n = not DATA2(i) )
      report "Not the expected output"
      severity error;
      if dataout_p /= DATA2(i) or dataout_n /= not DATA2(i) then
        err_cnt := err_cnt + 1;
      end if;

      -- Run
      wait for CLKHIGH_PERIOD/2;
    end loop;

    -- summary
    if (err_cnt = 0) then
      assert false
      report "Testbench sim_serdes8to1 terminated without any error"
      severity note;
    else
      assert false
      report "Testbench sim_serdes8to1 terminated with error"
      severity error;
    end if;

    wait;
  end process;

end Behavioral;
