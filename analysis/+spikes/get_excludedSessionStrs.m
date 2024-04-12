function excludedSessionStrs = get_excludedSessionStrs
% all the sessions that will be excluded from the analyses. 
% 
% last modified: 2023.04.14 

excludedSessionStrs = { '20171227', ... % Buzz, Ketamine_KeyMapWM2, too few correct trials
                        '20180112', ... % Buzz, Ketamine_KeyMapWM2, too few correct trials
                        '20170623', ... % Theo, Ketamine_KeyMapWM, only 2 columns
                        '20170704', ... % Theo, Ketamine_KeyMapWM, only 2 columns
                        '20170710', ... % Theo, Saline_KeyMapWM3, only 3 correct trials
                        '20170720'  ... % Theo, KM, low performance 
                       };

end 