-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    17:06:20 08/02/2018
-- Design Name:
-- Module Name:    sim_gtx_txrx - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the components serdes32to1 and serdes1to32
--                 Note: no automatic testing in this Testbench
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_gtx_txrx is
end sim_gtx_txrx;

architecture Behavioral of sim_gtx_txrx is
  -- Clock period definitions
  constant CLK_PERIOD     : time := 6 ns;
  
  -- Component Declaration
  component serdes32to1
  Port (
    -- Sys connect
    rst_i                 : in  std_logic;
    clk_i                 : in  std_logic;
    ref_clk_i             : in  std_logic;
    -- Inputs
    data32_i              : in  std_logic_vector(31 downto 0); 
    -- Outputs
    dataout_p             : out std_logic;
    dataout_n             : out std_logic
  );
  end component;

  -- Sys connect
  signal rst_i            : std_logic                          := '0';
  signal clk_i            : std_logic                          := '0';
  
  -- Inputs
  signal data32_i         : std_logic_vector (31 downto 0);

  --Outputs
  signal dataout_p        : std_logic;
  signal dataout_n        : std_logic;

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

  --Outputs
  signal data32_o         : std_logic_vector(31 downto 0);

begin

  -- serial
  serial : serdes32to1
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    ref_clk_i => clk_i,
    data32_i => data32_i,
    dataout_p => dataout_p,
    dataout_n => dataout_n
  );
  
  -- deserial
  deserial : serdes1to32
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    ref_clk_i => clk_i,
    datain_p => dataout_p,
    datain_n => dataout_n,
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
    for i in 0 to 100000 loop
      data32_i <= x"AAAAAAAA";
      wait for CLK_PERIOD;
      data32_i <= x"CCCCCCCC";
      wait for CLK_PERIOD;
    end loop;
    
    wait;
  end process;

end Behavioral;