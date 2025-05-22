% 2025/05/21. eprimetxt2cell
% A function used for importing eprime generated text file into a cell matrix that can easily be saved as csv or used directly in matlab
% The original function was probably written sometime around 2013 or 2014 (when I was an RA at Penn)
% I've finally decided to document it and make the error codes more useful to understand.
% To be honest though, it's worked so well for a long time and I haven't looked at the code so I'm not 100% sure how it works..
% - Arthur Lee
%
% Input
% filename: text string of the file name to be opened. E.g., 'myeprime.txt'
%
% Output
% data: cell array

function data = eprimetxt2cell(filename)
    file=fileread(filename);
    logframestart = '*** LogFrame Start ***';
    logframeend = '*** LogFrame End ***';
    starts = strfind(file, logframestart);
    ends = strfind(file, logframeend);
    header = {};
    data = {};
    rownum = 2;
    if length(starts) ~= length(ends)
        disp('Every logframe start needs to be paired with a logframe end.')
        disp(strcat('File seems to be broken...terminating file import for ', filename))
    else
        for f = 1:length(starts)-1
            log = file(starts(f):ends(f)+length(logframeend));
            endLine=strfind(log,  sprintf('\n'));
            colons = strfind(log, ':');
            thisorthat = 0;
            indice = [];
            for sorter = 1:length(colons)+length(endLine)
                if ~isempty(colons) && ~isempty(endLine)
                    if min(endLine) < min(colons)
                        if thisorthat == 2
                            endLine(1) = [];
                        else
                            thisorthat = 2;
                            indice(end+1) = min(endLine);
                            endLine(1) = [];
                        end
                    elseif min(endLine) > min(colons)
                        if thisorthat == 1
                            colons(1) = [];
                        else
                            thisorthat = 1;
                            indice(end+1) = min(colons);
                            colons(1) = [];
                        end
                    end
                else
                    if thisorthat == 2 && ~isempty(colons)
                        indice(end+1) = colons(1);
                    elseif thisorthat == 1 && ~isempty(endLine)
                        indice(end+1) = endLine(1);
                    end
                end
            end

            q = 2;
            while q <= length(indice)
                snip = log(indice(q-1):indice(q));
                if length(snip) == strfind(snip,':') %colon is at the end. This is variable name
                    snip2 = log(indice(q):indice(q+1)); % this should be the corresponding value
                    if strfind(snip2,':') ~= 1
                        disp('unhandled exception: varname not followed by value');
                        keyboard
                    else
                        varname = strtrim(snip(1:end-1));
                        value = strtrim(snip2(2:end));
                        if isstrprop(value, 'digit')
                            value = str2double(value);
                        end
                        where = find(strcmp(varname, header));
                        if rownum == 2 || isempty(where)
                            data{1,end+1} = varname;
                            data{rownum,end} = value;
                            header = data(1,1:end);
                        else
                            data{rownum,where} = value;
                        end
                    end
                    q = q+2;
                elseif strfind(snip,':') == 1 %colon is at the beginning. This is a variable
                    disp('unhandled exception: value detected before varname')
                    keyboard
                else %unnecessary case
                end
            end
            rownum = rownum+1;
        end
    end
end