library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_rx is
  generic(
    CLK_HZ       : integer := 50000000; -- 50 MHz
    BAUD_RATE    : integer := 115200
  );
  port(
    clk          : in  std_logic;
    rst_n        : in  std_logic;

    rxd          : in  std_logic;                     -- UART RX line

    rx_valid     : out std_logic;                     -- 1 clk pulse: byte ready
    rx_data      : out std_logic_vector(7 downto 0);  -- received byte
    rx_frame_err : out std_logic                      -- 1 clk pulse: stop bit error
  );
end entity;

architecture rtl of uart_rx is

  constant BAUD_DIV      : integer := CLK_HZ / BAUD_RATE; 
  constant HALF_BAUD_DIV : integer := BAUD_DIV / 2;

  type state_type is (IDLE, START, DATA, STOP);
  signal state : state_type := IDLE;

  -- 2FF synchronizer
  signal rxd_sync1 : std_logic := '1';
  signal rxd_sync2 : std_logic := '1';

  -- timing counter
  signal baud_cnt : integer range 0 to 1000000 := 0;

  -- data assembly
  signal rx_reg  : std_logic_vector(7 downto 0) := (others => '0');
  signal bit_idx : integer range 0 to 7 := 0;

  -- registered outputs (pulses)
  signal rx_valid_r     : std_logic := '0';
  signal rx_data_r      : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_frame_err_r : std_logic := '0';

begin

  rx_valid     <= rx_valid_r;
  rx_data      <= rx_data_r;
  rx_frame_err <= rx_frame_err_r;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state <= IDLE;

        rxd_sync1 <= '1';
        rxd_sync2 <= '1';

        baud_cnt <= 0;

        rx_reg  <= (others => '0');
        bit_idx <= 0;

        rx_valid_r     <= '0';
        rx_data_r      <= (others => '0');
        rx_frame_err_r <= '0';

      else
        -- default pulse outputs
        rx_valid_r     <= '0';
        rx_frame_err_r <= '0';

        -- sync input
        rxd_sync1 <= rxd;
        rxd_sync2 <= rxd_sync1;

        case state is

          when IDLE =>
            baud_cnt <= 0;
            bit_idx  <= 0;

            -- detect start bit (line goes low)
            if rxd_sync2 = '0' then
              baud_cnt <= 0;
              state    <= START;
            end if;

          when START =>
            -- wait half bit, then confirm still low
            if baud_cnt = (HALF_BAUD_DIV - 1) then
              baud_cnt <= 0;

              if rxd_sync2 = '0' then
                bit_idx <= 0;
                state   <= DATA;
              else
                state <= IDLE; -- false start
              end if;

            else
              baud_cnt <= baud_cnt + 1;
            end if;

          when DATA =>
            -- wait full bit time, sample in the middle
            if baud_cnt = (BAUD_DIV - 1) then
              baud_cnt <= 0;

              rx_reg(bit_idx) <= rxd_sync2;

              if bit_idx = 7 then
                state <= STOP;
              else
                bit_idx <= bit_idx + 1;
              end if;

            else
              baud_cnt <= baud_cnt + 1;
            end if;

          when STOP =>
            -- wait stop bit time, then check stop bit
            if baud_cnt = (BAUD_DIV - 1) then
              baud_cnt <= 0;

              if rxd_sync2 = '1' then
                rx_frame_err_r <= '0';
              else
                rx_frame_err_r <= '1';
              end if;

              rx_data_r  <= rx_reg;
              rx_valid_r <= '1';

              state <= IDLE;

            else
              baud_cnt <= baud_cnt + 1;
            end if;

        end case;
      end if;
    end if;
  end process;

end architecture;
