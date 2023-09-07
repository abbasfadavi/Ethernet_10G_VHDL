----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
LIBRARY xpm;
USE xpm.vcomponents.ALL;
----------------------------------------------------------------------------------
ENTITY eth_manager IS
	PORT 
	(
		reset    : IN STD_LOGIC;
		refclk_p : IN STD_LOGIC;
		refclk_n : IN STD_LOGIC;
		usr_clk  : IN STD_LOGIC;
		LOSS     : in  std_logic;
		txp      : out std_logic;
        txn      : out std_logic;
        rxp      : in  std_logic;
        rxn      : in  std_logic;
		tx_en    : IN STD_LOGIC;
		tx_rd    : OUT STD_LOGIC;
		tx_data  : IN STD_LOGIC_VECTOR(63 DOWNTO 0)
	);
END eth_manager;
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF eth_manager IS
	----------------------------------------------------------------------------------	
  COMPONENT fifo_generator_0
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC;
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;
	----------------------------------------------------------------------------------
COMPONENT ila_0
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

	COMPONENT ila_1
		PORT 
		(
			clk : IN STD_LOGIC;
			probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			probe3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			probe4 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
		);
	END COMPONENT;
	----------------------------------------------------------------------------------
COMPONENT gtx
  PORT 
  (
    reset : IN STD_LOGIC;
    refclk_p : IN STD_LOGIC;
    refclk_n : IN STD_LOGIC;
    clk_adc : IN STD_LOGIC;
    clk_lan : INOUT STD_LOGIC;
    txp : OUT STD_LOGIC;
    txn : OUT STD_LOGIC;
    rxp : IN STD_LOGIC;
    rxn : IN STD_LOGIC;
    LOSS : IN STD_LOGIC;
    Tx_axis_tready : OUT STD_LOGIC;
    Tx_axis_aresetn : IN STD_LOGIC;
    Tx_axis_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    Tx_axis_tvalid : IN STD_LOGIC;
    Tx_axis_tlast : IN STD_LOGIC;
    Tx_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    Tx_axis_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    Tx_ifg_delay : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    Rx_axis_aresetn : IN STD_LOGIC;
    Rx_axis_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    Rx_axis_tvalid : OUT STD_LOGIC;
    Rx_axis_tuser : OUT STD_LOGIC;
    Rx_axis_tlast : OUT STD_LOGIC;
    Rx_axis_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;
	----------------------------------------------------------------------------------    	

    --
	constant ps : INTEGER := 1512/8;
	--
	SIGNAL sTx_axis_tdata    : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sTx_axis_tdata1   : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sTx_axis_tdata2   : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    signal sTx_axis_tvalid   : std_logic := '0';
    signal sTx_axis_tlast    : std_logic := '0';
    signal sTx_axis_tkeep    : std_logic_vector(7 downto 0) := (others => '0');
    signal sTx_axis_tready   : std_logic := '0';
    signal sRx_axis_aresetn  : std_logic := '0';
    signal sRx_axis_tdata    : std_logic_vector(63 downto 0) := (others => '0');
    signal sRx_axis_tvalid   : std_logic := '0';
    signal sRx_axis_tlast    : std_logic := '0';
    signal sRx_axis_tuser    : std_logic := '0';
    signal sRx_axis_tkeep    : std_logic_vector(7 downto 0) := (others => '0');
    --
	SIGNAL full              : STD_LOGIC := '0';
    SIGNAL sit               : STD_LOGIC := '0';
    SIGNAL pack_cnt          : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL prog_full         : STD_LOGIC;
    SIGNAL prog_fullR        : STD_LOGIC;
    SIGNAL lan_clk           : STD_LOGIC;
    SIGNAL rd_en             : STD_LOGIC:= '0';
    SIGNAL read_cnt          : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	----------------------------------------------------------------------------------
BEGIN
	----------------------------------------------------------------------------------
    mem : fifo_generator_0
    PORT MAP 
    (
        rst       => '0',
        wr_clk    => usr_clk,
        din       => tx_data,
        wr_en     => tx_en,
        rd_clk    => lan_clk,
        dout      => sTx_axis_tdata,
        rd_en     => rd_en,
        prog_full => prog_full,
        full      => full
    );
    ---------------------------------------------------------------------------------- 
	xpm_Full : xpm_cdc_single
	GENERIC MAP
	(
		DEST_SYNC_FF => 2,
		INIT_SYNC_FF => 0,
		SIM_ASSERT_CHK => 0,
		SRC_INPUT_REG => 1
	)
	PORT MAP
	(
		src_clk  => usr_clk,
		src_in   => prog_full,
		dest_clk => lan_clk,
		dest_out => prog_fullR
	);
	----------------------------------------------------------------------------------
    sTx_axis_tvalid <= '1' when (sit = '1') else '0';
    sTx_axis_tkeep <= x"FF" when (sit = '1') else x"00";
    sTx_axis_tlast <= '1' when (read_cnt = ps-1) else '0';
	rd_en <= '1' when (sit = '1' and sTx_axis_tready = '1' AND read_cnt < ps-1)else '0';
	
	PROCESS (lan_clk)
	BEGIN
		IF (rising_edge(lan_clk)) then
		    if((prog_fullR = '1' and sit = '0'))then
		      sit <= '1';
		      pack_cnt <= pack_cnt +1;
		    end if;      
			IF (sit = '1' and sTx_axis_tready = '1' AND read_cnt < ps-1) THEN
			    read_cnt <= read_cnt + 1;
			END IF;
			IF (read_cnt = ps-1) THEN
		        read_cnt <= (OTHERS => '0');
		        sit <= '0';
			END IF;		
		END IF;
	END PROCESS;

	sTx_axis_tdata1 <= x"F1F1" & x"F0F0" & pack_cnt & x"AAAA" when (read_cnt = 0)else sTx_axis_tdata;	
	----------------------------------------------------------------------------------
	ila_lan : ila_1
	PORT MAP
	(
		clk       => lan_clk,
		probe0(0) => sTx_axis_tready,
		probe1(0) => sTx_axis_tvalid,
		probe2    => read_cnt,
		probe3    => sTx_axis_tdata1(15 downto 0),
		probe4    => sTx_axis_tkeep,
		probe5(0) => prog_fullR,
		probe6(0) => sit,
		probe7(0) => sTx_axis_tlast,
		probe8(0) => rd_en
	);
	----------------------------------------------------------------------------------
    sTx_axis_tdata2(63 downto 56) <= sTx_axis_tdata1( 7 downto  0);
    sTx_axis_tdata2(55 downto 48) <= sTx_axis_tdata1(15 downto  8);
    sTx_axis_tdata2(47 downto 40) <= sTx_axis_tdata1(23 downto 16);
    sTx_axis_tdata2(39 downto 32) <= sTx_axis_tdata1(31 downto 24);
    sTx_axis_tdata2(31 downto 24) <= sTx_axis_tdata1(39 downto 32);
    sTx_axis_tdata2(23 downto 16) <= sTx_axis_tdata1(47 downto 40);
    sTx_axis_tdata2(15 downto  8) <= sTx_axis_tdata1(55 downto 48);
    sTx_axis_tdata2( 7 downto  0) <= sTx_axis_tdata1(63 downto 56);
    
	tx_rd <= NOT reset;	

	    Inst_gtx : gtx
        Port map
		(
			reset    		 => reset,
			refclk_p         => refclk_p,
			refclk_n    	 => refclk_n,
			clk_adc    	     => usr_clk,
			clk_lan          => lan_clk,
			txp              => txp,
            txn              => txn,
            rxp              => rxp,
            rxn              => rxn,
			LOSS             => LOSS,
			
			Tx_axis_tready   => sTx_axis_tready, 
			Tx_axis_aresetn  => '1',
			Tx_axis_tdata    => sTx_axis_tdata2,  
			Tx_axis_tvalid   => sTx_axis_tvalid, 
			Tx_axis_tlast    => sTx_axis_tlast,  
			Tx_axis_tuser    => "0",  
			Tx_axis_tkeep    => sTx_axis_tkeep,  
			Tx_ifg_delay     => x"0F", 
			  
			Rx_axis_aresetn  => sRx_axis_aresetn,  
			Rx_axis_tdata    => sRx_axis_tdata,    
			Rx_axis_tvalid   => sRx_axis_tvalid,   
			Rx_axis_tuser    => sRx_axis_tuser,    
			Rx_axis_tlast    => sRx_axis_tlast,    
			Rx_axis_tkeep    => sRx_axis_tkeep     
		);
	----------------------------------------------------------------------------------
END Behavioral;