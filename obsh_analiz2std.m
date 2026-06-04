% Запрашиваем несколько файлов у пользователя
[filenames, pathname] = uigetfile(...
    {'*.mat;*.csv;*.txt', 'Допустимые форматы (*.mat, *.csv, *.txt)'}, ...
    'Выберите файлы для обработки', ...
    'MultiSelect', 'on');
r=length(filenames);
 [filenames1,pathname1]=uigetfile(...
    {'*.mat;*.csv;*.txt', 'Допустимые форматы (*.mat, *.csv, *.txt)'}, ...
    'Выберите файлы для обработки', ...
     'MultiSelect', 'on');
 filenames=[filenames,filenames1];
% Если выбран только один файл, преобразуем в cell array

if ischar(filenames)
    filenames = {filenames};
end

time_massiv=zeros(length(filenames),3);
amplitude_massiv=zeros(length(filenames),3);
%%
% Обрабатываем каждый файл
for i = 1:r
    fullPath = fullfile(pathname, filenames{i});
    
    % Определяем тип файла и загружаем
    [~, ~, ext] = fileparts(fullPath);
    
    switch lower(ext)
        case '.mat'
            data = load(fullPath);
        case {'.csv', '.txt'}
            data = readtable(fullPath);
        otherwise
            warning('Формат файла %s не поддерживается', fullPath);
            continue;
    end
    
    
    % Работаем с данными...
    disp(['Обрабатывается файл: ', fullPath]);
    %Разобъем массив частот на 3 части(от 0.1 до 0.5, от 0.5 до 2, от 2 до 20,
 %от 30 до + бесконечности)


 f_X_=cell(length(data.f_X),3);
 for j=1:length(f_X_)
    f_X_{j,1}=data.f_X(j,1);
 end

 [fs1,t1,hs1] = find(data.hs_X);
 

for l=1:length(fs1)
    f_X_{fs1(l,1),2}{end+1}=hs1(l,1);
    f_X_{fs1(l,1),3}{end+1}=data.t_X(t1(l,1),1);
end

% f_X_1=f_X_(2:3,:);
% f_X_2=f_X_(4:9,:);
% f_X_3=f_X_(10:81,:);
%интерполируем амплитуды и время при определённых частотах на единую сетку
interpSignals = NaN(length(data.t_X), 81);
for l = 2:81
    try
        t_i = cell2mat(f_X_{l,3});
        y_i = cell2mat(f_X_{l,2});
        interpSignals(:, l) = interp1(transpose(t_i), transpose(y_i), data.t_X);
    catch
        warning("Ошибка %d", l);
    end
end
f_X_1=interpSignals(:,2:3);
f_X_2=interpSignals(:,4:9);
f_X_3=interpSignals(:,10:81);
f_X_1=f_X_1(151:length(data.t_X)-149,:);
f_X_2=f_X_2(151:length(data.t_X)-149,:);
f_X_3=f_X_3(151:length(data.t_X)-149,:);

%Находим среднее зависимочти амплитуды от времени на каждом диапазоне
sr=NaN(length(f_X_1),3);
sr(:,1) = transpose(mean(transpose(f_X_1),'omitnan'));
sr(:,2)=transpose(mean(transpose(f_X_2),'omitnan'));
sr(:,3)=transpose(mean(transpose(f_X_3),'omitnan'));

%делаем среднее сигнала нулевым
sr_0=sr-mean(sr);
%считаем стандартные отклонения
std_=transpose(std(sr_0,'omitnan'));
%Берём модуль от этого сигнала
mod_sr=abs(sr_0);
index=zeros(1,3);
for j=1:3
    try
        c=find(mod_sr(:,j)>2*std_(j,1));
        index(1,j) = c(1,1);
    catch
        index(1,j) = NaN;
    end
end

for u=1:3
    time_massiv(i,u)=(index(1,u)+150)*0.02;
end

end

for i = (r+1):length(filenames)
    fullPath = fullfile(pathname1, filenames{i});
    
    % Определяем тип файла и загружаем
    [~, ~, ext] = fileparts(fullPath);
    
    switch lower(ext)
        case '.mat'
            data = load(fullPath);
        case {'.csv', '.txt'}
            data = readtable(fullPath);
        otherwise
            warning('Формат файла %s не поддерживается', fullPath);
            continue;
    end
    
    
    % Работаем с данными...
    disp(['Обрабатывается файл: ', fullPath]);
    %Разобъем массив частот на 3 части(от 0.1 до 0.5, от 0.5 до 2, от 2 до 20,
 %от 30 до + бесконечности)


 f_X_=cell(length(data.f_X),3);
 for j=1:length(f_X_)
    f_X_{j,1}=data.f_X(j,1);
 end

 [fs1,t1,hs1] = find(data.hs_X);
 

for l=1:length(fs1)
    f_X_{fs1(l,1),2}{end+1}=hs1(l,1);
    f_X_{fs1(l,1),3}{end+1}=data.t_X(t1(l,1),1);
end

% f_X_1=f_X_(2:3,:);
% f_X_2=f_X_(4:9,:);
% f_X_3=f_X_(10:81,:);
%интерполируем амплитуды и время при определённых частотах на единую сетку
interpSignals = NaN(length(data.t_X), 81);
for l = 2:81
    try
        t_i = cell2mat(f_X_{l,3});
        y_i = cell2mat(f_X_{l,2});
        interpSignals(:, l) = interp1(transpose(t_i), transpose(y_i), data.t_X);
    catch
        warning("Ошибка %d", l);
    end
end
f_X_1=interpSignals(:,2:3);
f_X_2=interpSignals(:,4:9);
f_X_3=interpSignals(:,10:81);
f_X_1=f_X_1(151:length(data.t_X)-149,:);
f_X_2=f_X_2(151:length(data.t_X)-149,:);
f_X_3=f_X_3(151:length(data.t_X)-149,:);

%Находим среднее зависимочти амплитуды от времени на каждом диапазоне
sr=NaN(length(f_X_1),3);
sr(:,1) = transpose(mean(transpose(f_X_1),'omitnan'));
sr(:,2)=transpose(mean(transpose(f_X_2),'omitnan'));
sr(:,3)=transpose(mean(transpose(f_X_3),'omitnan'));

%делаем среднее сигнала нулевым
sr_0=sr-mean(sr);
%считаем стандартные отклонения
std_=transpose(std(sr_0,'omitnan'));
%Берём модуль от этого сигнала
mod_sr=abs(sr_0);
index=zeros(1,3);
for j=1:3
    try
        c=find(mod_sr(:,j)>2*std_(j,1));
        index(1,j) = c(1,1);
    catch
        index(1,j) = NaN;
    end
end

for u=1:3
    time_massiv(i,u)=(index(1,u)+150)*0.02;
end
end

rowNames = transpose(filenames);
colNames = {'Вестибуляр+зрение','мозжечок','проприорецепция'};

% Создаем таблицу с подписями
time_table = array2table(time_massiv, 'RowNames', rowNames, 'VariableNames', colNames);

% Выводим результат
disp('Молодые')
disp('Момент времени максимальной активации сенсомоторной системы испытуемых в VR-шлеме на мягкой поверхности');
disp(time_table);


vectors = time_massiv;


%  Оценка кластеризации
eva = evalclusters(vectors, 'kmeans', 'CalinskiHarabasz', 'KList', 1:5);

%Оптимальное число кластеров
optimalK = eva.OptimalK;
disp(['Оптимальное число кластеров: ', num2str(optimalK)]);


[idx, centers] = kmeans(vectors, optimalK);
time_table.Cluster = idx;
mark=strings(length(idx),1);
mark(1:r,1)='+';
mark((r+1):end,1)='*';
%Визуализация
vectors_mol=vectors(1:r,:);
vectors_star=vectors((r+1):length(idx),:);
figure;
hold on
scatter3(vectors_mol(:,1), vectors_mol(:,2), vectors_mol(:,3),60,idx(1:r,1),"+");
scatter3(vectors_star(:,1), vectors_star(:,2), vectors_star(:,3),60,idx(r+1:end,1),'*');
title(['Кластеризация (K = ', num2str(optimalK), ')']);
xlabel('X');
ylabel('Y');
zlabel('Z');
col_mas=jet(optimalK);
colormap(col_mas);
colorbar;
%%
figure
hold on
for i =1:length(r)
    rectangle('Position', [0, i-0.3, 60, 0.6], ...
          'FaceColor', col_mas(idx(i,1),:), ... % Цвет заливки
          'EdgeColor', 'red', ...    % Цвет контура
          'LineWidth', 3);          % Толщина контура
    plot(time_massiv(i,1),i,'*',time_massiv(i,2),i,'s',time_massiv(i,3),i,'^')
    
end
for i =(r+1):length(idx)
    rectangle('Position', [0, i-0.3, 60, 0.6], ...
          'FaceColor', col_mas(idx(i,1),:), ... % Цвет заливки
          'EdgeColor', 'green', ...    % Цвет контура
          'LineWidth', 3);          % Толщина контура
    plot(time_massiv(i,1),i,'*',time_massiv(i,2),i,'s',time_massiv(i,3),i,'^')
    
end
ax=gca;
a=zeros(length(idx),1);
for i=1:length(a)
    a(i,1)=i;
end
ax.YTick=a;
ax.YTickLabel=rowNames;