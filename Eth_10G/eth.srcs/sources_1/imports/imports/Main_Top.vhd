----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
library UNISIM;
use UNISIM.VComponents.all;
----------------------------------------------------------------------------------
entity Main_Top is
    Port
     (      
      PL_CLK0_P        : in STD_LOGIC;
      PL_CLK0_N        : in STD_LOGIC; 
      --
      refclk_p         : in std_logic;
      refclk_n         : in std_logic;
      txp              : out std_logic;
      txn              : out std_logic;
      rxp              : in  std_logic;
      rxn              : in  std_logic;
      TX_DIS           : out  std_logic;
      LOSS             : in  std_logic;
      --
      LED1             : out  std_logic;
      LED2             : out  std_logic;
      LED3             : out  std_logic;
      LED4             : out  std_logic
    );
end Main_Top;
----------------------------------------------------------------------------------
architecture Behavioral of Main_Top is
    ----------------------------------------------------------------------------------
component clk_wiz_0
port
 (
  clk_110M          : out    std_logic;
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;
    signal cou_led  : std_logic_vector(27 downto 0) := (others => '0');
    signal cou_led1 : std_logic_vector(27 downto 0) := (others => '0');
    signal cou_led2 : std_logic_vector(27 downto 0) := (others => '0');
    ----------------------------------------------------------------------------------
    component eth_manager
        Port
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
    end component;    
    --------------------------------------------------------------------------------------  
    signal reset            : std_logic := '1'; 
    signal clk_adc          : std_logic := '0';  
    signal tx_en            : std_logic := '0';
    signal tx_en1           : std_logic := '0';
    signal tx_data          : std_logic_vector(63 downto 0) := (others => '0');           
    signal clk_lan          : std_logic := '0';
    signal tx_rd            : std_logic:= '0';
    signal locked           : std_logic;
   ---------------------------------------------------------------------------------- 
   COMPONENT ila_0
PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;    
   ----------------------------------------------------------------------------------     
begin
----------------------------------------------------------------------------------         
   clk_wiz : clk_wiz_0
   port map 
   ( 
   clk_110M => clk_adc,            
   reset => '0',
   locked => locked,
   clk_in1_p => PL_CLK0_P,
   clk_in1_n => PL_CLK0_N
 );
    ----------------------------------------------------------------------------------
        process(clk_adc) 
        variable cnt : integer := 0;   
        begin
            if(rising_edge(clk_adc)) then  
            cnt := cnt + 1;
               if(cnt > 100e6 and locked = '1')then
                    reset <= '0';
               end if; 
            end if;
        end process;                   
    ----------------------------------------------------------------------------------                 
    cou_led  <= cou_led  + 1  when rising_edge(clk_adc);
    LED1     <= cou_led(27); 
    LED2     <= LOSS; 
    LED3     <= '0';   
    LED4     <= '0';  
    TX_DIS   <= '0';
    ----------------------------------------------------------------------------------
        process(clk_adc) 
        variable cnt : integer := 0; 
        variable sit : integer := 0;  
        variable cnt1 : integer := 0;   
        begin
            if(rising_edge(clk_adc)) then  
               tx_en  <= '0';
               if(tx_rd = '1')then
                    tx_en  <= '1';  
                    tx_data <= tx_data + 1; 
               end if; 
            end if;
        end process;
    ---------------------------------------------------------------------------------- 
     Inst_eth_manager : eth_manager                    
     Port map
     (                  
         reset    => reset,
         refclk_p => refclk_p,
		 refclk_n => refclk_n,
         usr_clk  => clk_adc,
         LOSS     => LOSS,
         txp      => txp,
         txn      => txn,
         rxp      => rxp,
         rxn      => rxn,
         tx_rd    => tx_rd,
         tx_en    => tx_en,
         tx_data  => tx_data          
     );      
    ----------------------------------------------------------------------------------    
    end Behavioral;
    


   