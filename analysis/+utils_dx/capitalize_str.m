function Capitalized_String = capitalize_str(input_string)
    Capitalized_String = [upper(input_string(1)) input_string(2:length(input_string))];
end