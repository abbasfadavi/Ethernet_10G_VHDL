----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
library UNISIM;
use UNISIM.VComponents.all;
----------------------------------------------------------------------------------
entity gtx is
	Port
		(
			reset    		 : in std_logic;
			refclk_p         : in std_logic;
			refclk_n    	 : in std_logic;
			clk_adc    	     : in std_logic;
			clk_lan    	     : inout std_logic;
			--
			txp              : out std_logic;
            txn              : out std_logic;
            rxp              : in  std_logic;
            rxn              : in  std_logic;
			LOSS             : in  std_logic;			
			--
			Tx_axis_tready   : out std_logic;
			Tx_axis_aresetn  : in std_logic;
			Tx_axis_tdata    : in std_logic_vector(63 downto 0);
			Tx_axis_tvalid   : in std_logic;
			Tx_axis_tlast    : in std_logic;
			Tx_axis_tuser    : in std_logic_vector(0 downto 0);
			Tx_axis_tkeep    : in std_logic_vector(7 downto 0);
			Tx_ifg_delay     : in std_logic_vector(7 downto 0);
			--
			Rx_axis_aresetn  : in std_logic;
			Rx_axis_tdata    : out std_logic_vector(63 downto 0);  
			Rx_axis_tvalid   : out std_logic;
			Rx_axis_tuser    : out std_logic;  
			Rx_axis_tlast    : out std_logic;  
			Rx_axis_tkeep    : out std_logic_vector(7 downto 0)						
		);
end gtx;
----------------------------------------------------------------------------------
architecture Behavioral of gtx is
----------------------------------------------------------------------------------	
    COMPONENT TGMAC
    PORT
        (
            tx_clk0 : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            tx_axis_aresetn : IN STD_LOGIC;
            tx_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            tx_axis_tvalid : IN STD_LOGIC;
            tx_axis_tlast : IN STD_LOGIC;
            tx_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            tx_ifg_delay : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            tx_axis_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            tx_axis_tready : OUT STD_LOGIC;
            tx_statistics_vector : OUT STD_LOGIC_VECTOR(25 DOWNTO 0);
            tx_statistics_valid : OUT STD_LOGIC;
            rx_axis_aresetn : IN STD_LOGIC;
            rx_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
            rx_axis_tvalid : OUT STD_LOGIC;
            rx_axis_tuser : OUT STD_LOGIC;
            rx_axis_tlast : OUT STD_LOGIC;
            rx_axis_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            rx_statistics_vector : OUT STD_LOGIC_VECTOR(29 DOWNTO 0);
            rx_statistics_valid : OUT STD_LOGIC;
            pause_val : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            pause_req : IN STD_LOGIC;
            tx_configuration_vector : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
            rx_configuration_vector : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
            status_vector : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            tx_dcm_locked : IN STD_LOGIC;
            xgmii_txd : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
            xgmii_txc : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            rx_clk0 : IN STD_LOGIC;
            rx_dcm_locked : IN STD_LOGIC;
            xgmii_rxd : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            xgmii_rxc : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT; 
----------------------------------------------------------------------------------
COMPONENT ten_gig_eth_pcs_pma_0
  PORT (
    refclk_p : IN STD_LOGIC;
    refclk_n : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    resetdone_out : OUT STD_LOGIC;
    coreclk_out : OUT STD_LOGIC;
    rxrecclk_out : OUT STD_LOGIC;
    dclk : IN STD_LOGIC;
    txp : OUT STD_LOGIC;
    txn : OUT STD_LOGIC;
    rxp : IN STD_LOGIC;
    rxn : IN STD_LOGIC;
    sim_speedup_control : IN STD_LOGIC;
    txusrclk_out : OUT STD_LOGIC;
    txusrclk2_out : OUT STD_LOGIC;
    areset_coreclk_out : OUT STD_LOGIC;
    areset_datapathclk_out : OUT STD_LOGIC;
    gttxreset_out : OUT STD_LOGIC;
    gtrxreset_out : OUT STD_LOGIC;
    txuserrdy_out : OUT STD_LOGIC;
    reset_counter_done_out : OUT STD_LOGIC;
    qpll0lock_out : OUT STD_LOGIC;
    qpll0outclk_out : OUT STD_LOGIC;
    qpll0outrefclk_out : OUT STD_LOGIC;
    xgmii_txd : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    xgmii_txc : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    xgmii_rxd : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    xgmii_rxc : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    mdc : IN STD_LOGIC;
    mdio_in : IN STD_LOGIC;
    mdio_out : OUT STD_LOGIC;
    mdio_tri : OUT STD_LOGIC;
    prtad : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    core_status : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal_detect : IN STD_LOGIC;
    tx_fault : IN STD_LOGIC;
    drp_req : OUT STD_LOGIC;
    drp_gnt : IN STD_LOGIC;
    core_to_gt_drpen : OUT STD_LOGIC;
    core_to_gt_drpwe : OUT STD_LOGIC;
    core_to_gt_drpaddr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    core_to_gt_drpdi : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    gt_drprdy : OUT STD_LOGIC;
    gt_drpdo : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    gt_drpen : IN STD_LOGIC;
    gt_drpwe : IN STD_LOGIC;
    gt_drpaddr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    gt_drpdi : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    core_to_gt_drprdy : IN STD_LOGIC;
    core_to_gt_drpdo : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    tx_disable : OUT STD_LOGIC;
    pma_pmd_type : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
  );
END COMPONENT;
    ----------------------------------------------------------------------------------  
    signal coreclk     : std_logic; 
    signal drp_req     : std_logic; 
   
    signal xgmii_txd   : std_logic_vector(63 downto 0) := (others => '0');
    signal xgmii_txdR  : std_logic_vector(63 downto 0) := (others => '0');
    signal xgmii_txc   : std_logic_vector(7 downto 0) := (others => '0');
    signal xgmii_txcR  : std_logic_vector(7 downto 0) := (others => '0');
    signal xgmii_rxd   : std_logic_vector(63 downto 0) := (others => '0');
    signal xgmii_rxdR  : std_logic_vector(63 downto 0) := (others => '0');
    signal xgmii_rxc   : std_logic_vector(7 downto 0) := (others => '0');
    signal xgmii_rxcR  : std_logic_vector(7 downto 0) := (others => '0');                                           
    ----------------------------------------------------------------------------------
begin
    ----------------------------------------------------------------------------------
    Inst_Core2MACCLK_bufg: BUFG
        port map
            (
                I => coreclk,
                O => clk_lan
            ); 
       process(clk_lan)
       begin
       if(rising_edge(clk_lan)) then
                xgmii_txdR <= xgmii_txd;
                xgmii_txcR <= xgmii_txc;
                xgmii_rxdR <= xgmii_rxd;
                xgmii_rxcR <= xgmii_rxc;  
       end if;                                                                  
       end process;
        
    Inst_TGMAC: TGMAC
    PORT MAP
    (
        tx_clk0                 => clk_lan,
        reset                   => reset,
        tx_axis_aresetn         => Tx_axis_aresetn,
        tx_axis_tdata           => Tx_axis_tdata,
        tx_axis_tvalid          => Tx_axis_tvalid,
        tx_axis_tlast           => Tx_axis_tlast,
        tx_axis_tuser           => Tx_axis_tuser,
        tx_ifg_delay            => Tx_ifg_delay,
        tx_axis_tkeep           => Tx_axis_tkeep,
        tx_axis_tready          => Tx_axis_tready,
        rx_axis_aresetn         => Rx_axis_aresetn,
        rx_axis_tdata           => Rx_axis_tdata,
        rx_axis_tvalid          => Rx_axis_tvalid,
        rx_axis_tuser           => Rx_axis_tuser,
        rx_axis_tlast           => Rx_axis_tlast,
        rx_axis_tkeep           => Rx_axis_tkeep,
        pause_val               => Conv_Std_Logic_Vector(1,16),
        pause_req               => '0',
        tx_configuration_vector => x"0605040302DA_0000_0302",
        rx_configuration_vector => x"0605040302DA_05EE_C6B6",
        tx_dcm_locked           => '1',
        rx_clk0                 => coreclk,
        rx_dcm_locked           => '1',
        --
        xgmii_txd               => xgmii_txd,
        xgmii_txc               => xgmii_txc,
        xgmii_rxd               => xgmii_rxdR,
        xgmii_rxc               => xgmii_rxcR        
    );    
    ----------------------------------------------------------------------------------                                          
    pcs_pma: ten_gig_eth_pcs_pma_0
      PORT map
        (
            refclk_p                        => refclk_p,
            refclk_n                        => refclk_n,
            dclk                            => clk_adc,
            reset                           => reset,
            sim_speedup_control             => '1',
            --
            xgmii_txd                       => xgmii_txdR,
            xgmii_txc                       => xgmii_txCR,
            xgmii_rxd                       => xgmii_rxd,
            xgmii_rxc                       => xgmii_rxc,
            --
            txp                             => txp,
            txn                             => txn,
            rxp                             => rxp,
            rxn                             => rxn,
            --
            signal_detect                   => not(LOSS),
            tx_fault                        => '0',
            drp_req                         => drp_req,
            drp_gnt                         => drp_req,
            --
            core_to_gt_drprdy               => '0',
            core_to_gt_drpdo                => (others => '0'),
            
            gt_drpen                        => '0',
            gt_drpwe                        => '0',
            gt_drpaddr                      => (others => '0'),
            gt_drpdi                        => (others => '0'),
            mdc                             => '0',
            mdio_in                         => '0',
            prtad                           => "00001",
            pma_pmd_type                    => "110",
            txusrclk2_out                   => coreclk
        );  
----------------------------------------------------------------------------------
end Behavioral;
