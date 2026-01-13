library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart_rx is
end entity;

architecture sim of tb_uart_rx is

  constant CLK_HZ    : integer := 50000000;
  constant BAUD_RATE : integer := 115200;
  constant BAUD_DIV  : integer := CLK_HZ / BAUD_RATE;

  signal clk   : std_logic := '0';
  signal rst_n : std_logic := '0';

  signal rxd          : std_logic := '1';
  signal rx_valid     : std_logic;
  signal rx_data      : std_logic_vector(7 downto 0);
  signal rx_frame_err : std_logic;

  procedure wait_cycles(n : natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

  -- Drive one UART frame on rxd (8N1, LSB-first)
  procedure drive_uart_byte(
    signal   line     : out std_logic;
    constant b        : std_logic_vector(7 downto 0);
    constant bad_stop : boolean
  ) is
  begin
    -- idle
    line <= '1';
    wait_cycles(BAUD_DIV);

    -- start bit
    line <= '0';
    wait_cycles(BAUD_DIV);

    -- 8 data bits
    for i in 0 to 7 loop
      line <= b(i);
      wait_cycles(BAUD_DIV);
    end loop;

    -- stop bit
    if bad_stop then
      line <= '0';
    else
      line <= '1';
    end if;
    wait_cycles(BAUD_DIV);

    -- back to idle
    line <= '1';
    wait_cycles(BAUD_DIV);
  end procedure;

begin

  -- DUT
  dut: entity work.uart_rx
    generic map(
      CLK_HZ    => CLK_HZ,
      BAUD_RATE => BAUD_RATE
    )
    port map(
      clk          => clk,
      rst_n        => rst_n,
      rxd          => rxd,
      rx_valid     => rx_valid,
      rx_data      => rx_data,
      rx_frame_err => rx_frame_err
    );

  -- 50 MHz clock
  clk <= not clk after 10 ns;

  stim: process
  begin
    -- Reset
    rst_n <= '0';
    rxd   <= '1';
    wait_cycles(20);
    rst_n <= '1';
    wait_cycles(20);

    -- Test 1: good frame A5
    drive_uart_byte(rxd, x"A5", false);

    wait until rising_edge(clk) and rx_valid = '1';

    assert rx_data = x"A5"
      report "RX DATA MISMATCH! Expected A5"
      severity failure;

    assert rx_frame_err = '0'
      report "Unexpected rx_frame_err on good frame!"
      severity failure;

    report "PASS: RX received A5 with no frame error." severity note;

    -- Test 2: bad stop bit on 3C
    drive_uart_byte(rxd, x"3C", true);

    wait until rising_edge(clk) and rx_valid = '1';

    assert rx_data = x"3C"
      report "RX DATA MISMATCH! Expected 3C (even with bad stop)"
      severity failure;

    assert rx_frame_err = '1'
      report "Expected rx_frame_err=1 for bad stop bit, but got 0!"
      severity failure;

    report "PASS: RX detected frame error on bad stop bit (3C)." severity note;
    report "ALL RX TESTS PASSED." severity note;

    wait;
  end process;

end architecture;
