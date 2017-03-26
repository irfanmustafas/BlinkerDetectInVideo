function [C] = maskowanie(film)

%Wczytanie filmu (zapis klatek do BMP i wektor indeks�w nazw) B(4,:)
%Przyci�cie klatek do wymaganych wymiar�w
[B, ilosc] = wczytaj(film);
%Pierwsze 9 klatek jest zawsze czarne wi�c nie ma czego tam szuka�
for a=12:1:ilosc

%wykrycie r�nic miedzy klatkami
Bin8 = binaryzacja(a,a-2);
%rysowanie map migaczy
obrazek = migacz(B(a,:));

%maskowanie obraz�w
obrazek(~Bin8) = 0;

imwrite(obrazek,a,'bmp');

C = [C; a];
end




