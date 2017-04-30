function forex_data = getForexData(currency, start_date, end_date)
D = loadRange(currency, start_date, end_date);
D = fixData(D);
forex_data.CP   = D.close;
forex_data.SEMA = getIndicator('EMA',D,8);
forex_data.LEMA = getIndicator('EMA',D,34);
forex_data.RSI  = getIndicator('RSI',D,60);
end