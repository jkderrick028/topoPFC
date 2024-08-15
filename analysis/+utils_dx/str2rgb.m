function rgb = str2rgb(color)
% for a given string, return the rgb values as a row vector
% 
% last modified: 2023.04.22

switch color
    case 'light_grey'
        rgb = [200      200     200]/255; 
    case 'dark_grey'
        rgb = [120      120     120]/255; 
    case 'cyan'
        rgb = [0        1       1]; 
    case 'red'
        rgb = [1        0       0];
    case 'light_blue'
        rgb = [0.3010   0.7450  0.9330]; 
    case 'dark_blue'
        rgb = [0        0.4470  0.7410];
    case 'toronto_blue'
        rgb = [19, 74, 142]/255; 
end

end % function str2rgb