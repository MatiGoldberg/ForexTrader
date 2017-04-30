function plotCandle(D)

candle(D.high,D.low,D.close,D.open,'k',D.time);
ch = get(gca,'children');
set(ch(1),'FaceColor','r')
set(ch(2),'FaceColor','g')
title(['\bf\it',D.curr,' Data ',D.start_date,'-',D.end_date])
grid on

end