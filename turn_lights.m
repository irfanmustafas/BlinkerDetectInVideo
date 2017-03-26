function []=turn_lights(obraz) %wybor jaki obrazek

%G�rne i dolne granice w przestrzeni HSV �wiate� pozycyjnych Hue Saturation
%Value
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Wp�czynnik odleg�o�ci migacza od �wiat�a
turn_r_upper=5;

%Wczytanie obrazu po przycieciu granic
A = crop(obraz); 
%Konwersja obrazu na HSV
B= uint16(rgb2hsv(A)*255);
B=uint8(B);

%Inicjalizacja map obiekt�w
map=zeros(size(B,1), size(B,2), 1);
map_turn=map;

%Utworzenie map na podstawie granic podanych w parametrach
%Mapa �wiate� tylnich
map( (((h_lower<B(:,:,1)) | (B(:,:,1)<=h_upper)) & s_lower<B(:,:,2) & B(:,:,2)<=s_upper & v_lower<B(:,:,3) & B(:,:,3)<=v_upper) )=1; %wykrycie obiektow czerwonych i danie im bialych punktow na czarnej do tej pory mapie obiektow
map( (110<B(:,:,1)& B(:,:,1)<=130 & s_lower<B(:,:,2) & B(:,:,2)<=s_upper & v_lower<B(:,:,3) & B(:,:,3)<=v_upper) )=1;

%Mapa migacza
map_turn( (turn_h_lower<B(:,:,1)& B(:,:,1)<=turn_h_upper & turn_s_lower<B(:,:,2) & B(:,:,2)<=turn_s_upper & turn_v_lower<B(:,:,3) & B(:,:,3)<=turn_v_upper) )=1;

%Uworzenie elementu strukturalnego
se = strel('disk',10); %tworzy okrag/kolo o promieniu 10
%Morfologiczna operacja zemkni�cia
map = imclose(map,se); %zlewa wykryte na mapie elementy
map_turn = imclose(map_turn,se);

%Usuni�cie z mapy migacza obiekt�w nale��cych do �wiate� tylnich
map_turn(map==1)=0;

%Wyszukanie obiekt�w �wiate� tylnich
cc = bwconncomp(map); %Find connected components in binary image
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Wy�wietlenie zdj�cia oryginalnego
figure(3), imshow(A)
%Narysowanie oznacze� �wiate� na obrazie
%'T' dla kierunkowskazu
for i=1:n
text(lights_turn(i,1), lights_turn(i,2), 'T', 'Color', 'g','FontWeight', 'bold');
end
