module Token
  DEFAULT_LENGTH = 8
  POSSIBLE_UPCASE_CHARACTERS = ('A'..'Z').to_a
  POSSIBLE_DOWNCASE_CHARACTERS = ('a'..'z').to_a
  POSSIBLE_NUMBERS = ('0'..'9').to_a
  
  def self.generate(requested_length=DEFAULT_LENGTH, options={})
    domain = []
    domain.concat POSSIBLE_UPCASE_CHARACTERS unless options[:with_characters] == false
    domain.concat POSSIBLE_DOWNCASE_CHARACTERS unless options[:upcase] == false or options[:with_characters] == false
    domain.concat POSSIBLE_NUMBERS if options[:with_numbers]
    
    raise ArgumentError, "Can't generate a token without any characters or numbers, please select either :with_characters, :with_numbers, or both." if domain.empty?
    
    length = requested_length.odd? ? requested_length + 1 : requested_length
    token = (1..length).map { |i| domain.rand }.join
    token = token[0...requested_length]
    token.upcase! if options[:upcase]
    token
  end
end