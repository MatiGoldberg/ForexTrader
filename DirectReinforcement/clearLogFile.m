function clearLogFile()
if (exist('log.txt','file') == 2)
    delete log.txt
end
end