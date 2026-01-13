library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart_top is
end entity;

architecture sim of tb_uart_top is
  constant CLK_HZ    : integer := 50_000_000;
  constant BAUD_RATE : integer := 115_200;
  constant BAUD_DIV  : integer := CLK_HZ / BAUD_RATE;

  signal clk   : std_logic := '0';
  signal rst_n : std_logic := '0';

  -- UART external pins
  signal txd : std_logic;
  signal rxd : std_logic := '1';

  -- TX interface
  signal tx_valid : std_logic := '0';
  signal tx_data  : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_ready : std_logic;

  -- RX interface
  signal rx_valid     : std_logic;
  signal rx_data      : std_logic_vector(7 downto 0);
  signal rx_frame_err : std_logic;

  procedure wait_cycles(n : natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

  procedure send_byte(
    signal s_tx_data  : out std_logic_vector(7 downto 0);
    signal s_tx_valid : out std_logic;
    signal s_tx_ready : in  std_logic;
    constant b        : std_logic_vector(7 downto 0)
  ) is
  begin
    -- wait until ready
    wait until rising_edge(clk) and s_tx_ready = '1';

    -- 1-cycle valid pulse
    s_tx_data  <= b;
    s_tx_valid <= '1';
    wait until rising_edge(clk);
    s_tx_valid <= '0';
  end procedure;

begin
  -- clock 50 MHz
  clk <= not clk after 10 ns;

  -- DUT
  dut: entity work.uart_top
    generic map (
      CLK_HZ    => CLK_HZ,
      BAUD_RATE => BAUD_RATE,
      LOOPBACK  => 1              
    )
    port map (
      clk          => clk,
      rst_n        => rst_n,
      tx_valid     => tx_valid,
      tx_data      => tx_data,
      tx_ready     => tx_ready,
      rx_valid     => rx_valid,
      rx_data      => rx_data,
      rx_frame_err => rx_frame_err,
      txd          => txd,
      rxd          => rxd
    );

  stim: process
  begin
    -- reset
    rst_n <= '0';
    wait_cycles(20);
    rst_n <= '1';
    wait_cycles(20);

    -- Send A5 and expect A5 back via internal loopback
    send_byte(tx_data, tx_valid, tx_ready, x"A5");
    wait until rising_edge(clk) and rx_valid = '1';
    assert rx_data = x"A5"
      report "LOOPBACK FAIL: expected A5"
      severity failure;
    assert rx_frame_err = '0'
      report "Unexpected frame error on A5"
      severity failure;

    report "PASS: LOOPBACK A5" severity note;

    -- Send 3C and expect 3C
    send_byte(tx_data, tx_valid, tx_ready, x"3C");
    wait until rising_edge(clk) and rx_valid = '1';
    assert rx_data = x"3C"
      report "LOOPBACK FAIL: expected 3C"
      severity failure;
    assert rx_frame_err = '0'
      report "Unexpected frame error on 3C"
      severity failure;

    report "PASS: LOOPBACK 3C" severity note;
    report "ALL TOP LOOPBACK TESTS PASSED." severity note;
    wait;
  end process;

end architecture;
