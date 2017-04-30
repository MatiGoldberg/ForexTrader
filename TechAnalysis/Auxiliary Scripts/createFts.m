function fts = createFts(D)

fts = fints(D.time, [D.high,D.low,D.open,D.close], {'High','Low','Open','Close'},0 ,D.curr);

end