-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    19:59:23 07/25/2018
-- Design Name:
-- Module Name:    serdes32to1 - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    GTX serializer wrapper
--
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity serdes32to1 is
  Port (
    -- Sys connect
    rst_i            : in  std_logic;
    clk_i            : in  std_logic;
    ref_clk_i        : in  std_logic;
    -- Inputs
    data32_i         : in  std_logic_vector(31 downto 0); 
    -- Outputs
    dataout_p        : out std_logic;
    dataout_n        : out std_logic
  );
end serdes32to1;

architecture Behavioral of serdes32to1 is
  ----------------------------
  -- Components
  ----------------------------
  component tx_transceiver 
  port
  (
      SYSCLK_IN                               : in   std_logic;
      SOFT_RESET_TX_IN                        : in   std_logic;
      DONT_RESET_ON_DATA_ERROR_IN             : in   std_logic;
      GT0_TX_FSM_RESET_DONE_OUT               : out  std_logic;
      GT0_RX_FSM_RESET_DONE_OUT               : out  std_logic;
      GT0_DATA_VALID_IN                       : in   std_logic;
  
      --_________________________________________________________________________
      --GT0  (X0Y0)
      --____________________________CHANNEL PORTS________________________________
      --------------------------------- CPLL Ports -------------------------------
      gt0_cpllfbclklost_out                   : out  std_logic;
      gt0_cplllock_out                        : out  std_logic;
      gt0_cplllockdetclk_in                   : in   std_logic;
      gt0_cpllreset_in                        : in   std_logic;
      -------------------------- Channel - Clocking Ports ------------------------
      gt0_gtrefclk0_in                        : in   std_logic;
      gt0_gtrefclk1_in                        : in   std_logic;
      ---------------------------- Channel - DRP Ports  --------------------------
      gt0_drpaddr_in                          : in   std_logic_vector(8 downto 0);
      gt0_drpclk_in                           : in   std_logic;
      gt0_drpdi_in                            : in   std_logic_vector(15 downto 0);
      gt0_drpdo_out                           : out  std_logic_vector(15 downto 0);
      gt0_drpen_in                            : in   std_logic;
      gt0_drprdy_out                          : out  std_logic;
      gt0_drpwe_in                            : in   std_logic;
      --------------------------- Digital Monitor Ports --------------------------
      gt0_dmonitorout_out                     : out  std_logic_vector(7 downto 0);
      --------------------- RX Initialization and Reset Ports --------------------
      gt0_eyescanreset_in                     : in   std_logic;
      -------------------------- RX Margin Analysis Ports ------------------------
      gt0_eyescandataerror_out                : out  std_logic;
      gt0_eyescantrigger_in                   : in   std_logic;
      --------------------- Receive Ports - RX Equalizer Ports -------------------
      gt0_rxmonitorout_out                    : out  std_logic_vector(6 downto 0);
      gt0_rxmonitorsel_in                     : in   std_logic_vector(1 downto 0);
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      gt0_gtrxreset_in                        : in   std_logic;
      --------------------- TX Initialization and Reset Ports --------------------
      gt0_gttxreset_in                        : in   std_logic;
      gt0_txuserrdy_in                        : in   std_logic;
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      gt0_txusrclk_in                         : in   std_logic;
      gt0_txusrclk2_in                        : in   std_logic;
      ------------------ Transmit Ports - TX Data Path interface -----------------
      gt0_txdata_in                           : in   std_logic_vector(31 downto 0);
      ---------------- Transmit Ports - TX Driver and OOB signaling --------------
      gt0_gtxtxn_out                          : out  std_logic;
      gt0_gtxtxp_out                          : out  std_logic;
      ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
      gt0_txoutclk_out                        : out  std_logic;
      gt0_txoutclkfabric_out                  : out  std_logic;
      gt0_txoutclkpcs_out                     : out  std_logic;
      ------------- Transmit Ports - TX Initialization and Reset Ports -----------
      gt0_txresetdone_out                     : out  std_logic;
  
  
      --____________________________COMMON PORTS________________________________
       GT0_QPLLOUTCLK_IN  : in std_logic;
       GT0_QPLLOUTREFCLK_IN : in std_logic
  
  );
  end component;
  
   ----------------------------
   -- Signals
   ----------------------------
   signal   gt0_txoutclk_i : std_logic; -- CDR clock
   signal   gt0_txusrclk_i : std_logic; -- BUFG CDR clock

  ----------------------------
  -- Constants
  ----------------------------
  constant TIED_TO_GND_C   : std_logic := '0';
  constant TIED_TO_VCC_C   : std_logic := '1';

begin

  MapTXGTX: tx_transceiver port map (
    SYSCLK_IN                     => clk_i,
    SOFT_RESET_TX_IN              => rst_i,
    DONT_RESET_ON_DATA_ERROR_IN   => TIED_TO_GND_C,
    GT0_TX_FSM_RESET_DONE_OUT     => open,
    GT0_RX_FSM_RESET_DONE_OUT     => open,
    GT0_DATA_VALID_IN             => TIED_TO_GND_C,
   
    --_________________________________________________________________________
    --GT0  (X0Y0)
    --____________________________CHANNEL PORTS________________________________
    --------------------------------- CPLL Ports -------------------------------
    gt0_cpllfbclklost_out         => open,
    gt0_cplllock_out              => open,
    gt0_cplllockdetclk_in         => clk_i,
    gt0_cpllreset_in              => TIED_TO_GND_C,
    -------------------------- Channel - Clocking Ports ------------------------
    gt0_gtrefclk0_in              => TIED_TO_GND_C,
    gt0_gtrefclk1_in              => ref_clk_i,
    ---------------------------- Channel - DRP Ports  --------------------------
    gt0_drpaddr_in                => '0' & x"00",
    gt0_drpclk_in                 => clk_i,
    gt0_drpdi_in                  => X"0000",
    gt0_drpdo_out                 => open,
    gt0_drpen_in                  => TIED_TO_GND_C,
    gt0_drprdy_out                => open,
    gt0_drpwe_in                  => TIED_TO_GND_C,
    --------------------------- Digital Monitor Ports --------------------------
    gt0_dmonitorout_out           => open,
    --------------------- RX Initialization and Reset Ports --------------------
    gt0_eyescanreset_in           => TIED_TO_GND_C,
    -------------------------- RX Margin Analysis Ports ------------------------
    gt0_eyescandataerror_out      => open,
    gt0_eyescantrigger_in         => TIED_TO_GND_C,
    --------------------- Receive Ports - RX Equalizer Ports -------------------
    gt0_rxmonitorout_out          => open,
    gt0_rxmonitorsel_in           => "00",
    ------------- Receive Ports - RX Initialization and Reset Ports ------------
    gt0_gtrxreset_in              => TIED_TO_GND_C, 
    --------------------- TX Initialization and Reset Ports --------------------
    gt0_gttxreset_in              => rst_i, 
    gt0_txuserrdy_in              => TIED_TO_VCC_C,
    ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
    gt0_txusrclk_in               => gt0_txusrclk_i,
    gt0_txusrclk2_in              => gt0_txusrclk_i,
    ------------------ Transmit Ports - TX Data Path interface -----------------
    gt0_txdata_in                 => data32_i,
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    gt0_gtxtxn_out                => dataout_n,
    gt0_gtxtxp_out                => dataout_p,
    ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    gt0_txoutclk_out              => gt0_txoutclk_i,
    gt0_txoutclkfabric_out        => open,
    gt0_txoutclkpcs_out           => open,
    ------------- Transmit Ports - TX Initialization and Reset Ports -----------
    gt0_txresetdone_out           => open,
    --____________________________COMMON PORTS________________________________
    GT0_QPLLOUTCLK_IN             => TIED_TO_GND_C,
    GT0_QPLLOUTREFCLK_IN          => TIED_TO_GND_C
  );
  
  -- Uses internal feedback for improved jitter performance, and to avoid consuming an 
  -- additional BUFG
  txoutclk_bufg0_i : BUFG
  port map
  (
      I                           => gt0_txoutclk_i,
      O                           => gt0_txusrclk_i
  );
  
end Behavioral;
