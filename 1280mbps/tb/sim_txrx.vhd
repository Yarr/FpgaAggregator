-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    20:18:25 07/10/2018
-- Design Name:
-- Module Name:    sim_realsim - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    Testbench for allowing to test the loopback system.
--                 This includes generator, TX Lane, RX lane, comparator  
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim_txrx is
end sim_txrx;

architecture Behavioral of sim_txrx is

  -- Clock period definitions
  constant CLK_PERIOD     : time := 6 ns;
  constant CLKHIGH_PERIOD : time := 1.5ns;
 
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
  signal clkhigh_i        : std_logic                          := '0';

  -- Outputs
  signal dataout_p        : std_logic;
  signal dataout_n        : std_logic;

  -- Component Declaration
  component aurora_rx_lane
  port (
    -- Sys connect
    rst_n_i               : in std_logic;
    clk_rx_i              : in std_logic;
    clk_serdes_i          : in std_logic;
    -- Input
    rx_data_i_p           : in std_logic;
    rx_data_i_n           : in std_logic;
    -- Output
    rx_data_o             : out std_logic_vector(63 downto 0);
    rx_header_o           : out std_logic_vector(1 downto 0);
    rx_valid_o            : out std_logic;
    rx_stat_o             : out std_logic_vector(7 downto 0)
  );
  end component aurora_rx_lane;

  -- outputs
  signal rx_data_o        : std_logic_vector(63 downto 0);
  signal rx_header_o      : std_logic_vector(1 downto 0);
  signal rx_valid_o       : std_logic;
  signal rx_stat_o        : std_logic_vector(7 downto 0);
 
  -- Component Declaration
  component comparator
  port (
    -- Sys connect
    rst_i                 : in  std_logic;
    clk_i                 : in  std_logic;
    -- Inputs
    data66_i              : in  std_logic_vector(65 downto 0);
    data66_valid_i        : in  std_logic;
    -- Outputs
    ok_o                  : out std_logic
  );
  end component;

  -- Inputs
  signal data66_i         : std_logic_vector(65 downto 0);
 
  -- Outputs
  signal ok_o             : std_logic;
 
begin

  data_generator : generator
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    read_i => read_i,
    data_o => data_o
  );

  auroratx_lane : aurora_tx_lane128
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    clkhigh_i => clkhigh_i,
    data66tx_i => data_o,
    read_o => read_i,
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
 
  data66_i <= rx_header_o & rx_data_o;
 
  data_comparator: comparator
  port map (
    rst_i => rst_i,
    clk_i => clk_i,
    data66_i => data66_i,
    data66_valid_i => rx_valid_o,
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
    variable err_cnt : integer := 0;
  begin
    -- reset
    rst_i <= '1';
    wait for CLK_PERIOD;
    rst_i <= '0';
   
    -- MUST be aligned after this point 
    wait for CLK_PERIOD * 35000;
   
    assert (ok_o = '1')
    report "No alignment ... "
    severity error;
    if ok_o /= '1' then
      err_cnt := err_cnt + 1;
    end if;
   
    -- summary
    if (err_cnt = 0) then
      assert false
      report "Testbench sim_txrx terminated without any error"
      severity note;
    else
      assert false
      report "Testbench sim_txrx terminated with error"
      severity error;
    end if;
   
    wait;
  end process;

end Behavioral;