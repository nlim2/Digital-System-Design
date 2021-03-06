-- Analog-to-Digital Converter Model

-- +-----------------------------+
-- | Copyright 1995-2008 DOULOS  |
-- |      Library: analogue      |
-- |    designer : Tim Pagden    |
-- |     opened:  2 Feb 1996     |
-- +-----------------------------+

-- Architectures:
--   02.02.96 original
--   20/05/08 edited to replace vfp_lib with numeric_std

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ADC_8_bit is
  port (analog_in : in real range -15.0 to +15.0;
        digital_out : out std_logic_vector(7 downto 0)
       );
end entity;

architecture original of ADC_8_bit is

  constant conversion_time: time := 25 ns;

  signal instantly_digitized_signal : std_logic_vector(7 downto 0);
  signal delayed_digitized_signal : std_logic_vector(7 downto 0);

  function ADC_8b_10v_bipolar (
    analog_in: real range -15.0 to +15.0
  ) return std_logic_vector is
    constant max_abs_digital_value : integer := 128;
    constant max_in_signal : real := 10.0;
    variable analog_signal: real;
    variable analog_abs: real;
    variable analog_limited: real;
    variable digitized_signal: integer;
    variable digital_out: std_logic_vector(7 downto 0);
  begin
    analog_signal := real(analog_in);
    if (analog_signal < 0.0) then    -- i/p = -ve
      digitized_signal := integer(analog_signal * 12.8);
      if (digitized_signal < -(max_abs_digital_value)) then
        digitized_signal := -(max_abs_digital_value);
      end if;
    else    -- i/p = +ve
      digitized_signal := integer(analog_signal * 12.8);
      if (digitized_signal > (max_abs_digital_value - 1)) then
        digitized_signal := max_abs_digital_value - 1;
      end if;
    end if;
    digital_out := std_logic_vector(to_signed(digitized_signal, digital_out'length));
    return digital_out;
  end ADC_8b_10v_bipolar;

begin

  s0: instantly_digitized_signal <=
        std_logic_vector (ADC_8b_10v_bipolar (analog_in));

  s1: delayed_digitized_signal <=
        instantly_digitized_signal after conversion_time;

  s2: digital_out <= delayed_digitized_signal;

end original;