library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_top is
  generic (
    CLK_HZ 		  : integer := 50000000;
    BAUD_RATE     : integer := 115200;

    -- 1 = internal loopback (txd -> rxd), 0 = external rxd input
    LOOPBACK : integer := 1
  );
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;

    -- TX user interface
    tx_valid : in  std_logic;                   	  -- 1 clk pulse: start send
    tx_data  : in  std_logic_vector(7 downto 0);	  -- byte to send
    tx_ready : out std_logic;                    	  -- 1=can accept new byte

    -- RX user interface
    rx_valid     : out std_logic;                     -- 1 clk pulse: byte ready
    rx_data      : out std_logic_vector(7 downto 0);  -- received byte
    rx_frame_err : out std_logic;                     -- 1 clk pulse: stop bit error

    -- UART serial pins/signals
    txd : out std_logic;
    rxd : in  std_logic
  );
end entity;

architecture rtl of uart_top is

  signal txd_int : std_logic := '1';
  signal rxd_int : std_logic := '1';

begin

  -- drive top output
  txd <= txd_int;

  -- choose RX source: loopback or external input
  rxd_int <= txd_int when LOOPBACK = 1 else rxd;

  --------------------------------------------------------------------
  -- TX instance
  --------------------------------------------------------------------
  u_tx : entity work.uart_tx
    generic map (
      CLK_HZ	   => CLK_HZ,
      BAUD_RATE    => BAUD_RATE
    )
    port map (
      clk          => clk,
      rst_n        => rst_n,
      tx_valid     => tx_valid,
      tx_data      => tx_data,
      tx_ready     => tx_ready,
      txd          => txd_int
    );

  --------------------------------------------------------------------
  -- RX instance
  --------------------------------------------------------------------
  u_rx : entity work.uart_rx
    generic map (
      CLK_HZ	   => CLK_HZ,
      BAUD_RATE    => BAUD_RATE
    )
    port map (
      clk          => clk,
      rst_n        => rst_n,
      rxd          => rxd_int,
      rx_valid     => rx_valid,
      rx_data      => rx_data,
      rx_frame_err => rx_frame_err
    );

end architecture;
