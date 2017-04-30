function savefig(FileTag,FigFormat,PaperSize)
%ThSavefig(FileTag,FigFormat)
%Save figure with extension in current directory
%
% FigFormat (FIG is embedded):
% - 0: FIG
% - 1: JPEG
% - 2: EPS (with TIFF preview)
% - 3: TIFF
% - 4: BMP
% - 5: PNG
% - otherwise: all formats;
%
% v3.2, Mati Goldberg, 16/8/13, added PNG.
%
% v3.1, Maurizio De Pitta', Tel-Aviv, January, 21st, 2008
% Added <'FileTag',0> as option to save only FIG figure
% 
% v3.0, Maurizio De Pitta', Tel-Aviv, October, 21st, 2008
% Added PaperSize handling (for compatibility with previous figures
%
% v2.0, Maurizio De Pitta', Tel-Aviv, July, 30th, 2008.
% New selective export and defaults. Automatic setting of PaperType to A3.
%
% v1.0, Maurizio De Pitta', Venezia-Mestre, July, 15th, 2007.

set(gcf,'paperpositionmode','auto'); %Change the scales I don't know why!

if nargin<3
    PaperSize = 'A4';
end
if strcmp(PaperSize,'A3')
    set(gcf,'PaperType','A3');  %Maybe is better to comment it
end

eval(['hgsave(''',FileTag,''');']); % Always save figure with FIG extension

if nargin==2
    switch FigFormat
        case 0
            return
        case 1    % JPEG
            eval(['print  -djpeg ',FileTag]);
        case 2  % EPS with TIFF preview
            eval(['print  -depsc -tiff ',FileTag]);
        case 3  % TIFF
            eval(['print  -dtiff ',FileTag]);
        case 4  % BMP
            eval(['print  -dbmp ',FileTag]);
        case 5  % PNG
            eval(['print  -dpng ',FileTag]);
        otherwise % FIG only when FigFormat~={1,2,3,4}
            return;
    end
else
    % If FigFormat is not specified, export in FIG and JPEG,
    % EPS+TIFF(preview), TIFF by default
    eval(['print  -djpeg ',FileTag]);
    eval(['print  -depsc -tiff ',FileTag]);
    eval(['print  -dtiff ',FileTag]);
    eval(['print  -dpng ',FileTag]);
end
    