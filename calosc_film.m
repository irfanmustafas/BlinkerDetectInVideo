function [C] = calosc_film(film)

%%
%Init
C=[];

h_upper=round(0.01*255); %130;
h_lower=round(0.93*255); %110;
s_upper=round(1.00*255);
s_lower=round(0.27*255);
v_upper=round(1.00*255);
v_lower=round(0.31*255);

%G�rne i dolne granice w przestrzeni HSV kierunkowskaz�w
turn_h_lower=round(0.05*255); %140; %160
turn_h_upper=round(0.24*255); %190
turn_s_lower=(0.55*255); %140
turn_s_upper=(1.00*255); %255
turn_v_lower=round(0.55*255); %140
turn_v_upper=round(1.00*255); %255

turn_r_upper=5; %od czego to zalezy?


%wczytanie filmu
[B, ilosc] = wczytaj(film);

for a=12:1:ilosc
    %%
    
    klatka1 = B(a,:);
    klatka2 = B(a-2,:);
    %%
    %Por�wnywanie klatek
    mapa = porownanie(klatka1,klatka2); 
    
    %%
    %Konwersja do skali szaro�ci
    mapa = rgb2gray(mapa);
    %Binaryzacja
    mapa = im2bw(mapa, 0.1);
    %Stworzenie elementu strukturalnego i operacja otwarcia w celu usuni�cia
    %zanieczyszcze�
    se = strel('disk',1);
    Bin = imopen(mapa,se);
	%Operacja zamkni�cia w celu zgrupowania i uszczelnienia
    se = strel('disk',5);
    Bin = imclose(Bin,se);
    %Zmiana typu zmiennej z logical na uint8
    Bin8 = im2uint8(Bin);%r�nice miedzy klatkami w postaci binarnej

    %%
    %rysowanie map migaczy
    [map_turn,map] = migacz(klatka1); %12 klatka

    %maskowanie obraz�w
    map_turn(~Bin8) = 0;

    %%
    
    klatka1 = crop(klatka1);
    
    cc = bwconncomp(map); %bwconncomp znajduje grup� 8 po��czonych element�w w obrazie binarnym
    %Pobranie parametr�w obiekt�w
    stats = regionprops(cc, {'Centroid', 'Area', 'EquivDiameter'});
    %Liczba kierunkowskaz�w
    n=0;
    %Sprawdzenie wszystkich kombinacji
    for i=1:cc.NumObjects
        %Inicjalizacja tymczasowej mapy migacza
        map_turn_temp=zeros(size(map_turn));
        %migacz, zale�nej promienia �wiat�a wsp. turn_r_upper
        x=floor(stats(i).Centroid(1) - turn_r_upper * stats(i).EquivDiameter/2) : floor(stats(i).Centroid(1) + turn_r_upper * stats(i).EquivDiameter/2);
        y=floor(stats(i).Centroid(2) - turn_r_upper * stats(i).EquivDiameter/2) : floor(stats(i).Centroid(2) + turn_r_upper * stats(i).EquivDiameter/2);

        %Ograniczenie obszaru do rozmiaru obrazu
        x( x>size(map_turn,2 ))=[];
        y( y>size(map_turn,1 ))=[];
        x( x<1 )=[];
        y( y<1 )=[];

        %Utworzenie mapy obiekt�w migacza w wyznaczonym obszarze
        map_turn_temp(y,x)=map_turn(y,x)*1;
        %Wyszukanie obiektu migacza
        turn_light=bwconncomp( map_turn_temp );
        %Je�li znaleziono obiekt zapisanie go do macierzy kierunkowskaz�w

        if turn_light.NumObjects~=0
        n=n+1;
        temp_stats = regionprops(turn_light, 'Centroid');
        lights_turn(n,1)=temp_stats(1).Centroid(1);
        lights_turn(n,2)=temp_stats(1).Centroid(2);
        end
    end
figure(a-11), imshow(klatka1)
    for i=1:n
        text(lights_turn(i,1), lights_turn(i,2), 'T', 'Color', 'g','FontWeight', 'bold');
    end
    
    %%
    % Pobrac to co wyswietla
    %print( figure(3), '-djpeg', a-1);
    %imwrite(klatka1,a,'bmp');
    saveas(gcf, sprintf('%d.jpg', a-11));
    C = [C; a];
    close all
    %saveas(figure(3),C(a-11),'.jpg');
end

