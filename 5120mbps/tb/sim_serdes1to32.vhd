-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    22:18:25 08/02/2018
-- Design Name:
-- Module Name:    sim_serdes1to32 - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the component serdes1to32
--                 Note: no automatic testing in this Testbench
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_serdes1to32 is
end sim_serdes1to32;

architecture Behavioral of sim_serdes1to32 is
  -- Clock period definitions
  constant CLK_PERIOD     : time := 6 ns;

  -- Component Declaration
  component serdes1to32
  Port (
    -- Sys connect
    rst_i                 : in  std_logic;
    clk_i                 : in  std_logic;
    ref_clk_i             : in  std_logic;
    -- Inputs
    datain_p              : in  std_logic;
    datain_n              : in  std_logic;
    -- Outputs
    data32_o              : out std_logic_vector(31 downto 0)
  );
  end component;

  -- Sys connect
  signal rst_i            : std_logic                          := '0';
  signal clk_i            : std_logic                          := '0';
  
  -- Inputs
  signal datain_p         : std_logic;
  signal datain_n         : std_logic;

  --Outputs
  signal data32_o         : std_logic_vector(31 downto 0);

begin
  -- Instantiate the Unit Under Test (UUT)
  uut : serdes1to32
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    ref_clk_i => clk_i,
    datain_p => datain_p,
    datain_n => datain_n,
    data32_o => data32_o
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
  begin

    -- reset
    rst_i <= '1';
    wait for CLK_PERIOD;
    rst_i <= '0';
    
    -- keep switching data
    for i in 0 to 10000 loop
      datain_p <= '1';
      datain_n <= '0';
      wait for CLK_PERIOD/8;
      datain_p <= '0';
      datain_n <= '1';
      wait for CLK_PERIOD/8;
    end loop;

    wait;

  end process;

end Behavioral;

