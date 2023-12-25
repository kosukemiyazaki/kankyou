%説明：グラフを成形するスクリプト(EV-ECU楊)
%
%構文：fixgraph
%
%設定値(ユーザ入力)
%　t_axesPara.xmin - 出力グラフのx軸(時間軸)の最小設定　注：379行目(入力項目として作成していない)
%　t_axesPara.xmax - 出力グラフのx軸(時間軸)の最大設定　注：380行目(入力項目として作成していない)
%
%設定値(その他)
%　scenarioName - グラフ対象シナリオ名　注：設定されていないと動かない(同名のテストパターンファイルが現在ディレクトリ内に、
%                                         また、同盟の未成形グラフ(figファイルが必要))
%　dbFileName - グラフ作成用データベースファイル(SILS環境変数設定.xlsx) 注：現在ディレクトリ内にないと動かない
%　graphSheetName - グラフ設定のシート名(グラフ化設定) 注：データベースファイル内に存在していないと動かない
%　yTickSheetName - Y軸目盛設定のシート名(Y軸目盛設定)　注：データベースファイル内に存在していないと動かない
%
%出力
%　成形済みグラフ(fig,jpg) - 成形済みグラフファイル(figとjpgのフォーマットで出力)
%
%参照関数：GetLabelList、getRowIndex
%

%ワークスペース初期化 (初期化対象は本スクリプトで使用する変数のみ)
clear yTickSheetName yTickIDindex yTickDBdata yTickDBatt xlavelpos varSheetName varNameIndex_graphDB varNameIndex varIDindex varDBdata varDBatt varDBRawData validRowlen valiIndex validCalLen usedY tsFileSheets tsFilePath titlePosY titlePosX temp t_yTickRecords t_yTickNum t_yTicklen t_yTickData t_varRecord t_varNameField t_varID t_setValue t_setPara t_graphRecord t_graphID t_graphHeight t_axesPara t_axes sheetNotExistFlag rowNum rowLen readFailureFlag prePosY prePosHeight plotSigNum plotSigLen plotSigIDList plotSigData plotSheetsName invalidDBFlag graphSheetsName graphRecords graphRecordAttNum graphRecordAttLen graphRecordAtt graphRecord graphMargin graphIDindex_varDB graphIDindex graphDBdata graphDBatt graphDBRawData graphBackColor fixedJpgPath fixedFigFilePathBase fixedFigFilePath fileNotExistFlag figSigNum figSigLen figHandle figFolderPath figFilePath deleteNum defaultRecord dbFileSheets dbFilePath dbFileName colNum colLen checkIndex yTickNameIndex HeightIndex graphNum t_getVarID textPosX textPosY yTickDBRawData xlabelxPos xlabelyPos

%インプットファイルのパス設定とファイルの存在確認
dbFileName = 'SILS環境変数設定.xlsx';
dbFilePath = ['.\tools\',dbFileName];%データベースファイルのパス設定
varSheetName = 'SILS環境変数リスト';%変数リストのシート名
graphSheetName = 'グラフ化設定';%グラフ化設定シート名
yTickSheetName = 'Y軸目盛り設定';%Y軸目盛り設定シート名

%xlsxに変更
%tsFilePath = ['.\tools\グラフ化設定リスト.xlsx']; %テストパターンファイルパスの設定 <-全パターン同じグラフを生成する場合
tsFilePath = ['.\sim_pattern\',scenarioName,'.xlsx']; %テストパターンファイルのパス設定
plotSheetsName = 'list';%グラフ化対象信号リストのシート名
figFolderPath = ['.\sim_result\',scenarioName];%figファイルの格納フォルダの設定
figFilePath = [figFolderPath,'\',scenarioName,'_1.fig'];%処理対象figファイルのパスの設定
fixedFigFilePathBase = [figFolderPath,'\',scenarioName,'_Fixed_'];%修正後figファイルのパス名のベース文字列

fileNotExistFlag = false;%処理に必要なファイルが見つからない場合にTrueとし、グラフ成形処理を実施しない
if exist(figFolderPath,'dir') ~= 7
    disp(['- ',figFolderPath,'が見つかりません']);
end
if exist(dbFilePath,'file') ~=2
    disp(['- ',dbFilePath,'が見つかりません']);
    fileNotExistFlag = true;
end
if exist(tsFilePath,'file') ~=2
    disp(['- ',tsFilePath,'が見つかりません']);
    fileNotExistFlag = true;
end
if exist(figFilePath,'file') ~=2
    disp(['- ',figFilePath,'が見つかりません']);
    fileNotExistFlag = true;
end

if fileNotExistFlag
    disp('- 処理対象のファイルが見つからないため処理終了します');
else
    sheetNotExistFlag = false;%処理に必要なエクセルが見つ駆らない場合Trueとし、グラフ成形処理を実施しない

    [~,dbFileSheets,~] = xlsfinfo(dbFilePath);

    if isempty(find(strcmp(dbFileSheets,varSheetName),1));%変数リストのシートが存在するか確認
        disp(['- ',varSheetName,'が',dbFilePath,'のシートに見つかりません']);
        sheetNotExistFlag = true;
    end
    if isempty(find(strcmp(dbFileSheets,graphSheetsName),1));%変数リストのシートが存在するか確認
        disp(['- ',graphSheetsName,'が',dbFilePath,'のシートに見つかりません']);
        sheetNotExistFlag = true;
    end
    if isempty(find(strcmp(dbFileSheets,yTickSheetName),1));%変数リストのシートが存在するか確認
        disp(['- ',yTickSheetName,'が',dbFilePath,'のシートに見つかりません']);
        sheetNotExistFlag = true;
    end

    [~,tsFileSheets,~] = xlsfinfo(tsFilePath);
    if isempty(find(strcmp(tsFileSheets,plotSheetsName),1));%変数リストのシートが存在するか確認
        disp(['- ',plotSheetsName,'が',tsFilePath,'のシートに見つかりません']);
        sheetNotExistFlag = true;
    end

    if sheetNotExistFlag
        disp('- 処理対象のエクセルシートが見つからないため処理終了します');
    else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %変数設定シートから必要なデータを読み出す
     [~,~,varDBRawData] = xlsread(dbFilePath,varSheetName);
     [colLen,rowLen] = size(varDBRawData);

     %有効な列数を確認する
     validRowlen = 0;%有効な列数を格納する変数
     checkIndex = 2;%2行目(DBの属性)が文字列である行を有効な行とする
     for rowNum = 1:rowLen
        if iscellstr(varDBRawData(checkIndex.rowNum)) %データが文字列である場合有効な列と判定する
            validRowlen = rowNum;
        else
            break;
        end
    end

    %有効な行数を確認する
    validCalLen = 0;
    checkIndex = 2;
    for colNum = 1:colLen
        if iscellstr(varDBRawData(colNum.checkIndex)) %データが文字列である場合有効な列と判定する
            validCalLen = colNum;
        else
            break;
        end
    end

    graphDBatt = graphDBRawData(2,1:validRowlen); %グラフ化設定DB列名格納
    graphDBdata = graphDBRawData(3:validCalLen,1:validRowlen);%グラフ化設定DBデータ格納
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Y軸目盛設定シートから必要なデータを読み出す
    [~,~,yTickDBRawData] = xlsread(dbFilePath,yTickSheetName);
    [colLen,rowLen] = size(yTickDBRawData);

     %有効な列数を確認する
     validRowlen = 0;%有効な列数を格納する変数
     checkIndex = 2;%2行目(DBの属性)が文字列である行を有効な行とする
     for rowNum = 1:rowLen
        if iscellstr(yTickDBRawData(checkIndex.rowNum)) %データが文字列である場合有効な列と判定する
            validRowlen = rowNum;
        else
            break;
        end
    end

    %有効な行数を確認する
    validCalLen = 0;
    checkIndex = 2;
    for colNum = 1:colLen
        if iscellstr(yTickDBRawData(colNum.checkIndex)) %データが文字列である場合有効な列と判定する
            validCalLen = colNum;
        else
            break;
        end
    end

    yTickDBatt = yTickDBRawData(2,1:validRowlen);%Y軸目盛せていDBの列名格納
    yTickDBdata = yTickDBRawData(3:validCalLen,1:validRowlen) %Y軸目盛設定DBのデータ格納
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %listのシートから必要なデータを読み出す
     plotSigData = GetLabelNameList(scenarioName);
     plotSigIDList = plotSigData(:,2);%ラベル名(変数データベース検索時のID)の取り出し
     [plotSigLen,~] = size(plotSigIDList); %読み出したデータ数を格納する

     %データの読み出しが成功しているかどうかを確認する
     readFailureFlag = false;
     if isempty(varDBatt) || isempty(varDBdata) || isempty(graphDBatt) || isempty(graphDBdata) || isempty(plotSigIDList)
        readFailureFlag = true;
        disp('- データの読み出しに失敗したxlsファイルがあります');
     end

%各DBニ必要な属性が含まれているか確認する
 varIDindex = getRowIndex(varDBatt,'varID');
 varNameIndex = getRowIndex(varDBatt,'varName');
 graphIDindex_varDB = getRowIndex(varDBatt,'grapgID');
 HeightIndex = getRowIndex(graphDBatt,'Height');
 graphIDindex = getRowIndex(graphDBatt,'graphID');
 varNameIndex = getRowIndex(graphDBatt,'varName');
 yTickIDindex = getRowIndex(yTickDBatt,'yTickID');
 
invalidDBFlag = false;
if varIDindex == 0;
    disp(['- varIDが',varSheetName,'シート内に見つかりません']);
    invalidDBFlag = true;
end
if varNameIndex == 0;
    disp(['- varNameが',varSheetName,'シート内に見つかりません']);
    invalidDBFlag = true;
end
if graphIDindex_varDB == 0;
    disp(['- graphIDが',varSheetName,'シート内に見つかりません']);
    invalidDBFlag = true;
end
if HeightIndex == 0;
    disp(['- Heightが',varSheetName,'シート内に見つかりません']);
    invalidDBFlag = true;
end
if graphIDindex == 0;
    disp(['- graphIDが',varSheetName,'シート内に見つかりません']);
    invalidDBFlag = true;
end
if varNameIndex_graphDB == 0;
    disp(['- varNameが',varSheetName,'シート内に見つかりません']);
    invalidDBFlag = true;
end
if yTickIDindex == 0;
    disp(['- yTickが',varSheetName,'シート内に見つかりません']);
    invalidDBFlag = true;
end

defaultRecord = selectRecords(graphDBatt,graphDBdata,'graphID','DEFAULT'); %DEFAULTの設定を格納しておく

if isempty(defaultRecord)
    disp([graphSheetsName,'のgraphIDにDEFAULTの設定が必要です']);
    invalidDBFlag = true;
end

if readFailureFlag
    disp('- データ読み出しに失敗したため終了します');
else if invalidDBFlag
    disp('- DBが不正な形式であるため処理終了します');
else
    open(figFilePath);
    %編集するfigファイルの読み込みとハンドルの取得
    figHandle = gcf;
    [figSigLen,~]=size(figHandle.Children);

    if plotSigLen ~= figSigLen
    %figの信号数とTSファイルの信号数が異なる場合は処理実施しない
    disp('- figの信号数とlistの信号数が異なるため処理終了します');
    else
        %グラフ化設定DBから必要なデータを抽出する
        graphRecords = {};%抽出データ
        for plotSigNum = 1:plotSigLen
            t_varID = char(plotSigIDList(plotSigNum));
            t_varRecord = selectRecords(varDBatt,varDBdata,'varID',t_varID);
            if isempty(t_varRecord) %グラフ化設定をデフォルトとする
                t_graphID = 'DEFAULT';%グラフ化設定をデフォルトとする
                t_varNameField = 'リストに存在しない';
                t_getVarID = t_varID;
            else
                if not(iscellstr(t_varRecord(1,graphIDindex_varDB))) %graphIDが文字列でない場合
                    t_graphID = 'DEFAULT';%グラフ化設定をデフォルトとする
                    t_varNameField = 'IDの文字列が不正';
                else
                    t_graphID = char(t_varRecord(1,graphIDindex_varDB));%graphIDも読み込む
                    t_varNameField = t_varRecord(varNameIndex);
                    t_getVarID = t_varRecord(varIDindex);
                end
            end

            t_graphRecord = selectRecords(graphDBatt,graphDBdata,'graphID',t_graphID);
            if isempty(t_graphRecord)
                graphRecord = defaultRecord;
            else
                graphRecord = t_graphRecord;
            end
             graphRecords = [graphRecords; graphRecord,t_varNameField,t_getVarID];
        end
        graphRecordAtt = [graphDBatt,{'varName'},{'getVarID'}];
        [~,graphRecordAttLen] = size(graphRecordAtt);

        %fig設定
        graphMargin = 0.01500; %axes間のマージンの設定
        graphBackColor = [1 1 1]; %グラフの背景色　白

        figHandle.color = graphBackColor;%グラフの背景色設定
        figHandle.Name = scenarioName;%figureウィンドウタイトルの設定
        graphNum = 1;%処理中のグラフ番号
        prePosY = 1.0; %1つ前のaxesのHeight座標(グラフファイルのページ番号算出のため)
        usedY = graphMargin;%使用済みY軸(次グラフに遷移する判定処理のため)

        for figSigNum = figSigLen:-1:1 %figの各axes(Children)に処理実施
            plotSigNum = figSigLen - figSigNum +1;
            %Heightが未入力の場合or文字列の処理はDEFAULTのグラフ化設定をHeightとして処理実施する
            temp = graphRecords(plotSigNum,HeightIndex);
            if iscellstr(tmp) %データが文字列の場合
                %文字列の場合はデフォルト値を代入
                t_graphHeight = cell2mat(defaultRecord(1,HeightIndex));
            else %データが数値の場合
                if isnan(cell2mat(tmp)); %データがNaNの場合
                    %NaNの場合はデフォルト値を代入
                    t_graphHeight = cell2mat(defaultRecord(1,HeightIndex));
                else
                    t_graphHeight = cell2mat(temp);
                end
            end

            if (usedY + t_graphHeight + graphMargin) >= 0.95 %処理中のaxesの表示りょいいきが表示限界を超える場合
                %処理未実施のaxesを削除
                for deleteNum = figSigNum:-1:1
                    delete(figHandle.Children(deleteNum));
                end

                %最後のaxesにxラベル付与
                xlabel(t_axes,'time(s)') %x軸ラベルつけ
                xlabelxPos = (t_axesPara.xmax - t_axesPara.xmin) /2;
                xlabelyPos = t_axesPara.ymin - (0.03 * (abs(t_axesPara.ymax - t_axesPara.ymin)) / t_axesPara.prePosHeight); %%
                t_axes.Xlabel.Position = [xlabelxPos xlabelyPos 0]; %x軸のラベルポジション設定

                %処理中のfigを保存する
                fixedFigFilePath = [fixedFigFilePathBase,num2str(graphNum),'.fig'];
                fixedJpgPath = [fixedFigFilePathBase,num2str(graphNum),'.jpg'];

                set(figHandle,'position',[1 1 1920 1080])
                figHandle.Units = 'centimeters';
                jpgpos = figHandle.Position;
                jpgpos(3) = jpgpos(3)/1.5629;
                jpgpos(4) = jpgpos(4)/1.7416;
                figHandle.PaperPosition = jpgpos;
                savefig(fixedFigFilePath);
                [a,~] = size(figHandle.Children);
                for b = 1:a
                    figHandle.Children(b).FontSize = 5;
                    figHandle.Children(b).LineWidth = 0.05;
                    figHandle.Children(b).Children.LineWidth = 1.5;
                end
                saveas(figHandle,fixedJpgPath);
                close; %処理中のfigをclose
                open(figFilePath);%新規figをopen
                figHandle = gcf;%新規ハンドルを取得
                figHandle.color = graphBackColor;%グラフの背景色の設定
                figHandle.Name = scenarioName;%figのウィンドウタイトルの設定
                graphNum = graphNum + 1;%処理中のグラフ番号
                prePosY = 1.0;%1つ前のaxesのY座標
                usedY = graphMargin + t_graphHeight + graphMargin;

                %処理済みのaxesを削除
                for deleteNum = figSigLen:-1:figSigLen+1
                    delete(figHandle.Children(deleteNum));
                end
            else
                usedY = usedY + t_graphHeight + graphMargin;
                t_axes.XTickLabel = {''};%x軸のメモリラベルを削除する
                t_axes.Xlabel = [];%x軸のラベルを削除する
            end

            t_axes = figHandle.Children(figSigNum);%処理対象のaxes

            %axes設定のパラメータの初期化
            %Num型
            t_axesPara.PosX = t_axes.Position(1);
            t_axesPara.PosY = t_axes.Position(2);
            t_axesPara.PosWidth = t_axes.Position(3);
            t_axesPara.PosHeight = t_graphHeight;
            t_axesPara.xmin = t_axes.XLim(1); %x軸(時間軸)最小値の設定
            t_axesPara.xmax = t_axes.XLim(2); %x軸(時間軸)最大値の設定
            t_axesPara.ymin = t_axes.YLim(1);
            t_axesPara.ymax = t_axes.YLim(2);
            t_axesPara.YTickMin = NaN;
            t_axesPara.YTickSpace = NaN;
            t_axesPara.YTickMax = NaN;
            %String型
            t_axesPara.YGrid = t_axes.YGrid;
            t_axesPara.YMinorGrid = t_axes.YMinorGrid;
            t_axesPara.YMinorTick = t_axes.YMinorTick;
            t_axesPara.TitleString = '';
            t_axesPara.txt = '';
            t_axesPara.yTickID = '';
            t_axesPara.yTickCell = {};

            %グラフ化設定リストの属性を順に検索し属性毎の処理を実施する
            for graphRecordAttNum = 1:graphRecordAttLen
                %処理するデータの内容を変数に格納する(NaNの場合は次の設定へ)
                temp = graphRecords(plotSigNum.graphRecordAttNum);

                if iscellstr(tmp) %データが文字列の場合
                    t_setValue = char(temp);
                else
                    if isnan(cell2mat(temp)) %データがNaNの場合
                        continue;%処理不要であるため次の属性へ
                    end

                    t_setPara = char(graphRecordAtt(1,graphRecordAttNum));

                    %グラフ化設定DBからパラメータ読込
                    switch t_setPara
                    case 'ymin'
                        %型指定
                        if isa(t_setValue,'double')
                            if not(isnan(t_setValue))
                                t_axesPara.ymin = t_setValue;
                            end
                        end
                    case 'ymax'
                        if isa(t_setValue,'double')
                            if not(isnan(t_setValue))
                                t_axesPara.ymax = t_setValue;
                            end
                        end
                    case YTickMin'
                        if isa(t_setValue, 'double').
                            if not (isnan (t_setValue))
                                t_axesPara.YTickSpace = t_setValue;
                            end
                        end

                    case 'YTickSpace'
                        if isa(t_setValue, 'double')
                            if not (isnan (t_setValue))
                                t_axesPara.YTickSpace = t_setValue;
                            end
                        end
                    case 'YTickMax'
                        if isa(t_setValue, 'double')
                            if not (isnan (t_setValue))
                                t_axesPara.YTickMax = t_setValue;
                            end
                        end
                    case 'Height'
                        if isa(t_setValue, 'double').
                            if not (isnan (t_setValue))
                                t_axesPara. PosHeight = t_setValue;
                            end
                        end
                    case 'YGrid'
                        if ischar (t_setValue)
                            if strcmp(t_setValue, 'on') || strcmp(t_setValue, 'off')
                            t_axesPara.YGrid = t_setValue;
                            end
                        end
                    case 'YMinorGrid'
                        if ischar (t_setValue)
                            if strcmp (t_setValue, 'on') || strcmp(t_setValue, 'off')
                            t_axesPara.YMinorGrid = t_setValue;
                            end
                        end
                    case 'YMinorTick'
                        if ischar (t_setValue)
                            if strcmp (t_set Value, 'on') || strcmp(t_set Value, 'off')
                            t_axesPara.YMinorTick= t_setValue;
                            end
                        end
                    case 'varName'
                        if ischar (t_setValue)
                            t_setValue = strrep (t_setValue, '_','\');% "_"-はエスケープ処理実施する
                            t_axesPara.TitleString = t_setValue;
                        end
                    case 'get VarID'
                        if ischar (t_setValue)
                            t_setValue = strrep (t_setValue, 'SYSOUT_1S_','');
                            t_setValue = strrep (t_setValue,'SYSOUT_8MS_','');
                            t_setValue = strrep (t_setValue,'SYSIN_','');
                            t_setValue = strrep (t_setValue, 'PWCOUT_', '');
                            t_setValue = strrep (t_setValue,'PWCIN_','');
                            t_setValue = strrep (t_set Value,'_','\_');
                            t_axesPara.text=t_setValue;
                        end
                    case 'yTickID'
                        if ischar (t_setValue)
                            t_axesPara.yTickID = t_setValue;
                        end
                        if not (isempty(t_axesPara.yTickID)) % グラフ化設定リストのyTickIDの項目が入力されている場合の処理
                        % y軸目盛り設定リストから該当するIDのデータ取り出し
                            t_yTickRecords = selectRecords (yTickDBatt, yTickDBdata, 'yTickID', t_axesPara.yTickID);
                            yTickNameIndex = getRowIndex (yTickDBatt, 'yTickName');
                            if not (isempty (t_yTickRecords)) % y軸目盛り設定リストに該当する項目が存在する場合の処理
                            % yTickName 以前 (yTickName含む)の項目を削除する (yTickName 以降の項目を軸の設定値として読み込む)
                            tyTickRecords = tyTickRecords (1, yTickNameIndex + 1:end);
                            [~,tyTickLen] = size (t_yTickRecords);
                            %y軸設定のデータから有効な軸設定を取り出す
                            validIndex = 0; % 有効データのインデックスを格納する
                                for t_yTickNum = 1:t_yTickLen
                                t_yTickData = t_yTickRecords (1, t_yTickNum);
                                    if iscellstr(t_yTickData) % データが文字列の場合
                                    %文字列の場合は有効なデータとして処理する
                                    % 文字列の場合は有効なデータとして処理する
                                    validIndex tyTickNum;
                                    else
                                    %数値の場合は無効なデータとして処理する
                                    break; % 有効データの検索処理を終了する
                                    end
                                end
                                if validIndex = 0 % 有効な軸データが存在する場合の処理
                                t_axesPara.yTickCell = tyTickRecords (1, 1:validIndex);
                                else
                                end 
                            end %not (isempty (t_yTickRecords))
                        end %not (isempty(t_axesPara.yTickID))
                otherwise %switch
                end %switch
            end %graphRecordAttNum = 1:graphRecordAtt Len
            %DBから読み込んだパラメータをaxesに適用
            t_axesPara.PosX = 0.20; %%
            t_axesPara.PosY = prePosY - (t_axesPara.PosHeight + graphMargin);
            t_axes.Position = [t_axesPara.PosX t_axesPara.PosY t_axesPara.PosWidth t_axes Para.PosHeight]; % サブプロットのポジション変更
            t_axes.YLim [t_axesPara.ymin t_axesPara.ymax]; %Y軸の範囲設定
            t_axes.XLim [t_axesPara.xmin t_axesPara-xmax]; %X軸の範囲設定
            titlePosX = t_axesPara.xmin - ((abs (t_axesPara.xmax taxesPara.xmin)) / 0.65) * 0.1; %%
            textPosX = t_axesPara-xmin - ((abs (t_axesPara-xmax - t_axesPara-xmin)) / 0.65) * 0.1; %%
            if taxesPara.PosHeight <=0.025
                titlePosY = ((t_axesPara.ymax-t_axesPara.ymin) *0.99)+t_axesPara.ymin;
                textPosY = ((t_axesPara.ymax-t_axesPara.ymin)*0.01)+t_axesPara.ymin;
            else if t_axesPara. PosHeight <= 0.04
                titlePosY = ((t_axesPara.ymax-t_axesPara.ymin) *0.75)+t_axesPara.ymin;
                textPosY = ((t_axesPara.ymax-t_axesPara.ymin) *0.10)+t_axesPara.ymin;
            else if t_axesPara.PosHeight <= 0.07
                titlePosY = ((t_axesPara.ymax-t_axesPara.ymin) *0.65)+t_axesPara.ymin;
                textPosY = ((t_axesPara.ymax-t_axesPara.ymin) *0.25)+t_axesPara.ymin;
            else
                titlePosY = ((t_axesPara.ymax-t_axesPara.ymin) *0.60)+t_axesPara.ymin;
                textPosY = ((t_axesPara.ymax-t_axesPara.ymin) *0.30)+t_axesPara.ymin;
            end
            t_axes.Title.String = t_axesPara.TitleString: %グラフタイトルの設定
            t_axes.Title.VerticalAlignment='middle'; %タイトルポジションの水平方向の軸を文字列中心に設定
            t_axes.Title Position = [titlePosX titlePosY 0]; %タイトルポジション
            t_axes.YLabel.String = t_axesPara.text;
            t_axes. YLabel.Rotation=360;
            t_axes. YLabel.Position= [text PosX text PosY 0];
            if not (isnan (t_axesPara.YTickMin) || isnan (t_axesPara.YTickSpace) || isnan (t_axesPara.YTickMax)) X YVO (-> (1)
                t_axes.YTick= [t_axesPara.YTickMin: t_axesPara.YTickSpace : t_axesPara.YTickMax];
            end
                t_axes.YGrid = t_axesPara.YGrid; %Yグリッドの設定
                t_axes.YMinorGrid = t_axesPara.YMinorGrid; %y軸マイナーグリッドの設定
                t_axes.YMinorTick= t_axesPara.YMinorTick; %y軸サブメモリの設定
                t_axes.Children.LineWidth = 2; % ラインの太さの設定
                t_axes.FontSize =8; % フォントサイズの設定
                t_axes.TitleFont SizeMultiplier = 1.3; %タイトルにかける倍率
            if not (isempty (t_axesPara.yTickCell)) % y軸の目盛り表示の設定 (有効な目盛り設定がされていない場合設定しない)
                t_axes.YTickLabel = t_axesPara.yTickCell;
            end

            if figSigNum == 1 %最後のfigのみ実施する処理
                % XTickLabel を削除する処理は不要
                xlabel (t_axes, 'time (s)') %x軸のラベル付け
                xlabelxPos (t_axesPara.xmax - t_axesPara.xmin) / 2; %%
                xlabelyPost_axesPara.ymin - (0.03 * (abs (t_axesPara.ymax - t_axesPara.ymin)) / t_axesPara.PosHeight); %%
                t_axes.XLabel.Position = [xlabelxPos xlabelyPos 0]; XxB05E
            end
            prePosY = t_axes. Position (2); % 1axes Y
        end %figSigNum = figSigLen:-1:1
        fixedFigFilePath = [fixedFigFilePathBase, num2str (graphNum), .fig'];
        fixedJpgPath = [fixedFigFilePathBase, num2str (graphNum),.jpg'];

        set (figHandle, 'position', [1 1 1920 1080])
        agetsizeget (0, 'screensize');
        assignin ('base', 'agetsize',agetsize)
        figHandle.Units = 'centimeters';
        jpgpos = figHandle.Position;
        assignin ('base', 'jpgposaaa'.jpgpos)
        jpgpos (3) = jpgpos (3)/1.5629;
        jpgpos (4) jpgpos (4)/1.7416;
        figHandle.PaperPosition = jpgpos;
        savefig(fixedFigFilePath);
        [a,~] = size(figHandle.Children);
        for b = 1:a
            figHandle.Children(b).FontSize = 5;
            figHandle.Children(b).LineWidth = 0.05;
            figHandle.Children(b).Children.LineWidth = 1.5;
        end
        saveas(figHandle,fixedJpgPath);
    end %plotSigLen ~= figSigLen
    close;
end %readFailureFlag
end %sheetNotExistFlag
end %fileNotExistFlag

                                
                    











        
