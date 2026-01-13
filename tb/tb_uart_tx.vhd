library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart_tx is
end entity;

architecture sim of tb_uart_tx is

  constant CLK_HZ    : integer := 50000000;
  constant BAUD_RATE : integer := 115200;
  constant BAUD_DIV  : integer := CLK_HZ / BAUD_RATE; -- clocks per UART bit (~434)

  signal clk   : std_logic := '0';
  signal rst_n : std_logic := '0';

  signal tx_valid : std_logic := '0';
  signal tx_data  : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_ready : std_logic;
  signal txd      : std_logic;

  procedure wait_cycles(n : natural) is
  begin
    for i in 1 to n loop
      wait until rising_edge(clk);
    end loop;
  end procedure;

begin

  -- DUT
  dut: entity work.uart_tx
    generic map(
      CLK_HZ    => CLK_HZ,
      BAUD_RATE => BAUD_RATE
    )
    port map(
      clk      => clk,
      rst_n    => rst_n,
      tx_valid => tx_valid,
      tx_data  => tx_data,
      tx_ready => tx_ready,
      txd      => txd
    );

  -- 50 MHz clock
  clk <= not clk after 10 ns;

  stim: process
    variable got : std_logic_vector(7 downto 0);
  begin
    -- Reset
    rst_n <= '0';
    wait_cycles(20);
    rst_n <= '1';
    wait_cycles(20);

    -- Send A5
    tx_data <= x"A5";

    -- Wait until TX can accept a new byte
    wait until rising_edge(clk) and tx_ready = '1';

    -- Pulse tx_valid for 1 clock
    tx_valid <= '1';
    wait until rising_edge(clk);
    tx_valid <= '0';

    -- Wait for start bit (line goes low)
    wait until txd = '0';

    -- Sample at mid start bit
    wait_cycles(BAUD_DIV/2);
    assert txd = '0'
      report "Start bit not stable low at mid-bit!"
      severity failure;

    -- Move to the middle of the first data bit
    wait_cycles(BAUD_DIV);

    -- Sample 8 data bits (LSB first)
    for i in 0 to 7 loop
      got(i) := txd;
      wait_cycles(BAUD_DIV);
    end loop;

    -- Stop bit should be 1
    assert txd = '1'
      report "Stop bit error (expected 1)!"
      severity failure;

    assert got = x"A5"
      report "TX BYTE MISMATCH! Expected A5"
      severity failure;

    report "PASS: UART TX sent A5 correctly." severity note;
    report "ALL TX TESTS PASSED." severity note;
    wait;
  end process;

end architecture;
