-------------------------------------------------------------------------------------
-- Company:        LBNL / HEIA-FR
-- Engineer:       Queiroz Maic
-- E-Mail:         mqueiroz at lbl.gov
--                 maic.queiroz at edu.hefr.ch
-- Create Date:    19:29:23 08/03/2018
-- Design Name:
-- Module Name:    gtx_top - Behavioral
-- Project Name:   Pixel data-stream aggregator
-- Target Devices: Xilinx Kintex-7 KC705
-- Tool versions:  Xilinx Vivado v2017.4
-- Description:    GTX test
--
-- Additional Comments:  -
--
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;

entity gtx_top is
  Port (
    -- Sys connect
    rst_i            : in  std_logic;
    clkp_i           : in  std_logic;
    clkn_i           : in  std_logic;
    refclkp_i        : in  std_logic;
    refclkn_i        : in  std_logic;
    datain_p         : in  std_logic;
    datain_n         : in  std_logic;
    -- Outputs
    dataout_p        : out std_logic;
    dataout_n        : out std_logic;
    led0_o           : out std_logic;
    led1_o           : out std_logic;
    led2_o           : out std_logic;
    led3_o           : out std_logic;
    led4_o           : out std_logic;
    led5_o           : out std_logic;
    led6_o           : out std_logic;
    led7_o           : out std_logic
  );
end gtx_top;

architecture Behavioral of gtx_top is
  ----------------------------
  -- Components
  ----------------------------
  component clk_gen
  port (
    -- Clock in ports
    clk200_i         : in  std_logic;
    -- Clock out ports
    clk_o            : out std_logic;
    clkidelay_o      : out std_logic;
    clkhigh_o        : out std_logic;
    -- Status and control signals
    reset            : in  std_logic;
    locked           : out std_logic
  );
  end component clk_gen;
  
  -- Gearbox 66 bit to 32 bit
  component gearbox66to32
  generic (
    ratio_g          : integer := 4
  );
  port (
    -- Sys connect
    rst_i            : in  std_logic;
    clk_i            : in  std_logic;
    -- Inputs
    data66_i         : in  std_logic_vector(65 downto 0);
    -- Outputs
    data32_o         : out std_logic_vector(31 downto 0);
    data32_valid_o   : out std_logic;
    read_o           : out std_logic
  );
  end component;
  
  component serdes32to1
  port (
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
  end component serdes32to1;

  component serdes1to32
  port (
    -- Sys connect
    rst_i            : in  std_logic;
    clk_i            : in  std_logic;
    ref_clk_i        : in  std_logic;
    -- Inputs
    datain_p         : in  std_logic;
    datain_n         : in  std_logic;
    -- Outputs
    data32_o         : out std_logic_vector(31 downto 0)
  );
  end component serdes1to32;
  
  ----------------------------
  -- Signals
  ----------------------------
  signal clk200_s        : std_logic;
  signal clk_s           : std_logic;
  signal refclk_s        : std_logic;
  signal data32_s        : std_logic_vector(31 downto 0);
  signal datarx_s        : std_logic_vector(31 downto 0);
  
  ----------------------------
  -- Constants
  ----------------------------
  constant RATIO         : integer := 1;

begin

  Map0IBUFDSclk : IBUFDS
  port map (
    O => clk200_s,
    I => clkp_i,
    IB => clkn_i
  );
  
 Map0IBUFDSrefclk : IBUFDS_GTE2
  port map (
    I => refclkp_i,
    IB => refclkn_i,
    CEB => '0',
    O => refclk_s,
    ODIV2 => open
  );

  Map0clk: clk_gen port map (
    clk200_i => clk200_s,
    clk_o => clk_s,
    clkidelay_o => open,
    clkhigh_o => open,
    reset => rst_i,
    locked => open
  );
  
  Map1gb66to32:gearbox66to32
  generic map (
    ratio_g => RATIO
  )
  port map(
    rst_i => rst_i,
    clk_i => clk_s,
    data66_i => "00" & x"0123456789ABCDEF",
    data32_o => data32_s,
    data32_valid_o => open,
    read_o => open
  );
  
  Map2serdes32to1: serdes32to1 port map (
    rst_i => rst_i,
    clk_i => clk_s,
    ref_clk_i => refclk_s,
    data32_i => data32_s,
    dataout_p => dataout_p,
    dataout_n => dataout_n
  );
  
    
  Map3serdes1to32: serdes1to32 port map (
    rst_i => rst_i,
    clk_i => clk_s,
    ref_clk_i => refclk_s,
    datain_p => datain_p,
    datain_n => datain_n,
    data32_o => datarx_s
  );

  led0_o <= datarx_s(0) or datarx_s(1) or datarx_s(2) or datarx_s(3);
  led1_o <= datarx_s(4) or datarx_s(5) or datarx_s(6) or datarx_s(7);
  led2_o <= datarx_s(8) or datarx_s(9) or datarx_s(10) or datarx_s(11);
  led3_o <= datarx_s(12) or datarx_s(13) or datarx_s(14) or datarx_s(15);
  led4_o <= datarx_s(16) or datarx_s(17) or datarx_s(18) or datarx_s(19);
  led5_o <= datarx_s(20) or datarx_s(21) or datarx_s(22) or datarx_s(23);
  led6_o <= datarx_s(24) or datarx_s(25) or datarx_s(26) or datarx_s(27);
  led7_o <= datarx_s(28) or datarx_s(29) or datarx_s(30) or datarx_s(31);
  
end Behavioral;
