library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_tx is
  generic(
    CLK_HZ     : integer := 50000000; -- 50 MHz
    BAUD_RATE  : integer := 115200
  );
  port(
    clk        : in  std_logic;
    rst_n      : in  std_logic;

    tx_valid   : in  std_logic;                     -- 1 clk pulse: start sending
    tx_data    : in  std_logic_vector(7 downto 0);  -- byte to send
    tx_ready   : out std_logic;                     -- 1=can accept new byte (idle)

    txd        : out std_logic                      -- UART TX line
  );
end entity;

architecture rtl of uart_tx is

  constant BAUD_DIV : integer := CLK_HZ / BAUD_RATE;
  -- 50MHz/115200=434 Clock/bit
  type state_type is (IDLE, START, DATA, STOP);
  signal state : state_type := IDLE;

  signal tx_reg  : std_logic_vector(7 downto 0) := (others => '0');
  
  signal bit_idx : integer range 0 to 7 := 0;     		-- data bit index
  signal baud_cnt  : integer range 0 to 1000000 := 0;	-- bit time counter
  signal baud_tick : std_logic := '0';					-- bit time pulse = 434 Clock 

  signal txd_r : std_logic := '1'; --txd register

begin
  -- ready only in IDLE
  tx_ready <= '1' when state = IDLE else '0';
  txd <= txd_r;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        state     <= IDLE;
        tx_reg    <= (others => '0');
        bit_idx   <= 0;
        baud_cnt  <= 0;
        baud_tick <= '0';
        txd_r     <= '1';
      else
        baud_tick <= '0';

        
        if state /= IDLE then
          if baud_cnt = (BAUD_DIV - 1) then
            baud_cnt  <= 0;
            baud_tick <= '1';
          else
            baud_cnt <= baud_cnt + 1;
          end if;
        else
          baud_cnt <= 0;
        end if;

        case state is

          when IDLE =>
            txd_r <= '1';
            if tx_valid = '1' then
              tx_reg  <= tx_data;
              bit_idx <= 0;
              state   <= START;
            end if;

          when START =>
            txd_r <= '0';
            if baud_tick = '1' then
              state <= DATA;
            end if;

          when DATA =>
            txd_r <= tx_reg(bit_idx);
            if baud_tick = '1' then
              if bit_idx = 7 then
                state <= STOP;
              else
                bit_idx <= bit_idx + 1;
              end if;
            end if;

          when STOP =>
            txd_r <= '1';
            if baud_tick = '1' then
              state <= IDLE;
            end if;

        end case;
      end if;
    end if;
  end process;

end architecture;
