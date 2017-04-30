function saveLogFile(filename)
[success,message,~] = movefile('log.txt',['DRTraderLogs\',filename]);

if (~success)
    error(message)
end

end