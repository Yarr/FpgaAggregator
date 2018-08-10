-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    02:11:33 07/03/2018
-- Design Name:
-- Module Name:    sim_aurora_txrx_lane - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for the components aurora_tx_lane
--                 and aurora_rx_lane. A transmission error
--                 is present in order to see if the RX gearbox is
--                 able to catch again the alignment
--                 NOTE: no automatic testing on this testbench
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sim_aurora_txrx_lane is
end sim_aurora_txrx_lane;

architecture Behavioral of sim_aurora_txrx_lane is

  -- Clock period definitions
  constant CLK_PERIOD     : time := 6 ns;
  constant CLKHIGH_PERIOD : time := 1.5ns;

  -- Component Declaration
  component aurora_tx_lane128
  port (
    -- Sys connect
    rst_i                 : in  std_logic;
    clk_i                 : in  std_logic;
    clkhigh_i             : in  std_logic;
    -- Inputs
    data66tx_i            : in  std_logic_vector(65 downto 0);
    -- Outputs
    read_o                : out std_logic;
    dataout_p             : out std_logic;
    dataout_n             : out std_logic
  );
  end component;

  -- Sys connect
  signal rst_i            : std_logic                          := '0';
  signal clk_i            : std_logic                          := '0';
  signal clkhigh_i        : std_logic                          := '0';

  -- Input
  signal data66tx_i       : std_logic_vector (65 downto 0)     := (others=>'0');

  -- Outputs
  signal read_o           : std_logic;
  signal dataout_p        : std_logic;
  signal dataout_n        : std_logic;

  -- Component Declaration
  component aurora_rx_lane
    port (
      -- Sys connect
      rst_n_i             : in std_logic;
      clk_rx_i            : in std_logic;
      clk_serdes_i        : in std_logic;
      -- Input
      rx_data_i_p         : in std_logic;
      rx_data_i_n         : in std_logic;
      -- Output
      rx_data_o           : out std_logic_vector(63 downto 0);
      rx_header_o         : out std_logic_vector(1 downto 0);
      rx_valid_o          : out std_logic;
      rx_stat_o           : out std_logic_vector(7 downto 0)
    );
  end component aurora_rx_lane;

  -- outputs
  signal rx_data_o        : std_logic_vector(63 downto 0);
  signal rx_header_o      : std_logic_vector(1 downto 0);
  signal rx_valid_o       : std_logic;
  signal rx_stat_o        : std_logic_vector(7 downto 0);

begin

  auroratx_lane : aurora_tx_lane128
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    clkhigh_i => clkhigh_i,
    data66tx_i => data66tx_i,
    read_o => read_o,
    dataout_p => dataout_p,
    dataout_n => dataout_n
  );

  aurorarx_lane: aurora_rx_lane
  port map (
    rst_n_i => not rst_i,
    clk_rx_i => clk_i,
    clk_serdes_i => clkhigh_i,
    rx_data_i_p => dataout_p,
    rx_data_i_n => dataout_n,
    rx_data_o => rx_data_o,
    rx_header_o => rx_header_o,
    rx_valid_o => rx_valid_o,
    rx_stat_o => rx_stat_o
  );

  --Clock process definitions
  Clk_process : process
    begin
    clk_i <= '1';
    wait for CLK_PERIOD/2;
    clk_i <= '0';
    wait for CLK_PERIOD/2;
  end process;

  --Clock div process definitions
  Clkdiv_process : process
    begin
    clkhigh_i <= '1';
    wait for CLKHIGH_PERIOD/2;
    clkhigh_i <= '0';
    wait for CLKHIGH_PERIOD/2;
  end process;

  -- Stimulus process
  stim_proc: process
  begin

    -- reset
    rst_i <= '1';
    wait for CLK_PERIOD;
    rst_i <= '0';

    -- Simple counter
    for i in 1 to 4000 loop
      wait until read_o = '1';
      -- Offset the tx new value to not change it while scrambling
      data66tx_i <= "01" & std_logic_vector(to_unsigned(i, 64)) after CLK_PERIOD*2;
    end loop;
    
    --Error
    for i in 1 to 10 loop
      wait until read_o = '1';
      -- Offset the tx new value to not change it while scrambling
      data66tx_i <= "11" & std_logic_vector(to_unsigned(i, 64)) after CLK_PERIOD*2;
    end loop;

    -- Simple counter
    for i in 1 to 3200 loop
      wait until read_o = '1';
      -- Offset the tx new value to not change it while scrambling
      data66tx_i <= "01" & std_logic_vector(to_unsigned(i, 64)) after CLK_PERIOD*2;
    end loop;
    
    wait;
  end process;

end Behavioral;
