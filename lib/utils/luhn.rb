#c.f. http://en.wikipedia.org/wiki/Luhn_mod_N_algorithm
#this is specialized to handle the case where our string represents a hexadecimal number

module Medusa
  class Luhn

    def self.check_character(string)
      factor = 2
      sum = 0
      n = number_of_valid_input_characters
      strip_string(string).chars.to_a.reverse.each do |char|
        addend = factor * character_to_code_point(char)
        addend = (addend / n) + (addend % n)
        sum += addend
        factor = 3 - factor
      end
      remainder = sum % n
      check_code_point = n - remainder
      check_code_point %= n
      code_point_to_character(check_code_point)
    end

    def self.add_check_character(string, separator = '-')
      string + separator + check_character(string)
    end

    def self.verify(string_plus_check_digit)
      string = strip_string(string_plus_check_digit)
      check_digit = string.slice!(-1, 1)
      check_digit == check_character(string)
    end

    protected

    CHAR_TO_CODE_MAP = (('a'..'f').to_a + ('0'..'9').to_a).inject({}) { |acc, char| acc[char] = char.hex; acc }
    CODE_TO_CHAR_MAP = CHAR_TO_CODE_MAP.invert

    def self.code_point_to_character(code_point)
      CODE_TO_CHAR_MAP[code_point]
    end

    def self.character_to_code_point(char)
      CHAR_TO_CODE_MAP[char]
    end

    def self.number_of_valid_input_characters
      16
    end

    def self.strip_string(string)
      string.gsub(/[^0-9a-f]/, '')
    end

  end
end