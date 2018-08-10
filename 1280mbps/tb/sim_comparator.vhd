-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    23:09:13 07/10/2018
-- Design Name:
-- Module Name:    sim_realsim - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the component comparator
--
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_comparator is
end sim_comparator;

architecture Behavioral of sim_comparator is
  -- Clock period definitions
  constant CLK_PERIOD     : time := 6 ns;

  -- Component Declaration
  component comparator
  port (
    -- Sys connect
    rst_i                : in  std_logic;
    clk_i                : in  std_logic;
    -- Inputs
    data66_i             : in  std_logic_vector(65 downto 0);
    data66_valid_i       : in  std_logic;
    -- Outputs
    ok_o                 : out std_logic
  );
  end component;

  -- Sys connect
  signal rst_i            : std_logic                          := '0';
  signal clk_i            : std_logic                          := '0';

  -- Inputs
  signal data66_i         : std_logic_vector(65 downto 0);
  signal data66_valid_i   : std_logic;

  -- Outputs
  signal ok_o             : std_logic;
  
begin
  -- Instantiate the Unit Under Test (UUT)
  uut : comparator
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    data66_i => data66_i,
    data66_valid_i => data66_valid_i,
    ok_o => ok_o
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
begin

  -- Test 1, sequence of correct values followed by a wrong value (with a valid header)
  rst_i <= '0';
  data66_i <= "01" & x"ff00ff00ff00ff00";
  data66_valid_i <= '0';
  wait for CLK_PERIOD;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*5;
  data66_i <= "01" & x"ff00ff00ff00ff01";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*5;
  data66_i <= "01" & x"ff00ff00ff00ff02";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*5;
  data66_i <= "01" & x"ff00ff00ff00ff03";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  assert (ok_o = '1')
  report "Test 1, not the expected output (1)"
  severity error;
  if (ok_o /= '1') then
    err_cnt := err_cnt + 1;
  end if;
  wait for CLK_PERIOD*5;
  data66_i <= "01" & x"ff00ff00ff00ff05";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*10;
  assert (ok_o = '0')
  report "Test 1, not the expected output (0)"
  severity error;
  if (ok_o /= '0') then
    err_cnt := err_cnt + 1;
  end if;
  
  -- Test 2, end of sequence
  rst_i <= '1';
  wait for CLK_PERIOD;
  rst_i <= '0';
  data66_i <= "01" & x"fffffffffffffffe";
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*5;
  assert (ok_o = '1')
  report "Test 2, not the expected output (1)"
  severity error;
  if (ok_o /= '1') then
    err_cnt := err_cnt + 1;
  end if;
  data66_i <= "01" & x"ffffffffffffffff";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*10;
  assert (ok_o = '1')
  report "Test 2, not the expected output (1)"
  severity error;
  if (ok_o /= '1') then
    err_cnt := err_cnt + 1;
  end if;
  
  -- Test 3, wrong header
  rst_i <= '1';
  wait for CLK_PERIOD;
  rst_i <= '0';
  data66_i <= "01" & x"ff00ff00ff00ff00";
  data66_valid_i <= '0';
  wait for CLK_PERIOD;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*5;
  data66_i <= "01" & x"ff00ff00ff00ff01";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*5;
  data66_i <= "01" & x"ff00ff00ff00ff02";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*5;
  data66_i <= "01" & x"ff00ff00ff00ff03";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  assert (ok_o = '1')
  report "Test 3, not the expected output (1)"
  severity error;
  if (ok_o /= '1') then
    err_cnt := err_cnt + 1;
  end if;
  wait for CLK_PERIOD*5;
  data66_i <= "11" & x"ff00ff00ff00ff04";
  wait for CLK_PERIOD*5;
  data66_valid_i <= '1';
  wait for CLK_PERIOD;
  data66_valid_i <= '0';
  wait for CLK_PERIOD*10;
  assert (ok_o = '0')
  report "Test 3, not the expected output (0)"
  severity error;
  if (ok_o /= '0') then
    err_cnt := err_cnt + 1;
  end if;
  
  -- summary
  if (err_cnt = 0) then
    assert false
    report "Testbench sim_comparator terminated without any error"
    severity note;
  else
    assert false
    report "Testbench sim_comparator terminated with error"
    severity error;
  end if;

  wait;
end process;

end Behavioral;
