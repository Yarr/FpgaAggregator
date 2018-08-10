-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    22:29:43 07/10/2018
-- Design Name:
-- Module Name:    sim_generator - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the component generator
--
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_generator is
end sim_generator;

architecture Behavioral of sim_generator is
  -- Clock period definitions
  constant CLK_PERIOD     : time := 6 ns;

  -- Component Declaration
  component generator
  port (
    -- Sys connect
    rst_i                 : in  std_logic;
    clk_i                 : in  std_logic;
    -- Inputs
    read_i                : in  std_logic;
    -- Outputs
    data_o                : out std_logic_vector(65 downto 0)
  );
  end component;

  -- Sys connect
  signal rst_i            : std_logic                          := '0';
  signal clk_i            : std_logic                          := '0';

  -- Inputs
  signal read_i           : std_logic;

  -- Outputs
  signal data_o           : std_logic_vector(65 downto 0);

begin
  -- Instantiate the Unit Under Test (UUT)
  uut : generator
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    read_i => read_i,
    data_o => data_o
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
    read_i <= '0';
    
    -- reset
    rst_i <= '1';
    wait for CLK_PERIOD;
    rst_i <= '0';
    wait for CLK_PERIOD;

    wait for CLK_PERIOD/2;
    -- first run
    read_i <= '1';
    wait for CLK_PERIOD;
    read_i <= '0';
    wait for CLK_PERIOD;
    
    -- check data output
    assert (data_o = "01" & x"0000000000000001")
    report "Not the expected output (01)"
    severity error;
    if (data_o /= "01" & x"0000000000000001") then
      err_cnt := err_cnt + 1;
    end if;
    
    -- second run
    read_i <= '1';
    wait for CLK_PERIOD;
    read_i <= '0';
    wait for CLK_PERIOD;
    
    -- check data output
    assert (data_o = "01" & x"0000000000000002")
    report "Not the expected output (02)"
    severity error;
    if (data_o /= "01" & x"0000000000000002") then
      err_cnt := err_cnt + 1;
    end if;
    
    -- third run
    read_i <= '1';
    wait for CLK_PERIOD;
    read_i <= '0';
    wait for CLK_PERIOD*100;
    
    -- check data output
    assert (data_o = "01" & x"0000000000000003")
    report "Not the expected output (03)"
    severity error;
    if (data_o /= "01" & x"0000000000000003") then
      err_cnt := err_cnt + 1;
    end if;
 
    -- summary
    if (err_cnt = 0) then
      assert false
      report "Testbench sim_generator terminated without any error"
      severity note;
    else
      assert false
      report "Testbench sim_generator terminated with error"
      severity error;
    end if;
 
    wait;
  end process;
end Behavioral;
