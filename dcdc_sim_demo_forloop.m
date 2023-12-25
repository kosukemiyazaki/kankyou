%=====================================================
%Sim実行スクリプト simの実行～excel結果ファイルの作成
%=====================================================

%ワークスペース変数の初期化(Forループ用変数以外)

clearvars -except ptn scenarioName trycnt error_cnt errorcomment txt raw msg cnt

%パラメータ展開

try
 %参照モデルのパラメータ定義
 OTHER_IGSW_param;
 OTHER_SYSSEI_param;
 OPE_PANEL_param;
 EX_BODY_BSW_parameter;
 APSC_EPMNZ_parameter;
 HV_ECU_BSW_parameter;
 HVSET_parameter;
 sisusei_parameter;
 OTHER_DRVREC_param;
 CGW_parameter;
 OTHER_HBAT_param;
 OTHER_LBAT_param;
catch exception
 error_cnt = error_cnt+1;
 trycnt = 1;
 errorcomment{end+1,1} = [num2str(error_cnt),'.',char(scenarioName),'参照モデルのパラメータ定義でエラー。パラメータファイルの定義方法、定義漏れを確認してください。'];
end

%テストパターンファイルの読込
xlsData=xlsread(['.\sim_pattern\',scenarioName,'.xlsx']);

for i = 2:size(xlsData,2);
 data{i - 1} = [xlData(1:size(xlsData,1),1),xlsData(1:size(xlsData,1),i)];
end

%SILSパラメータ定義
 SILS_param;
 
if trycnt == 0
 try
 %テスト実行
 sim('AUXBATCHG_SILS',[],simset('SrcWorkspace','current'));
 catch exception
  error_cnt = error_cnt+1;
  trycnt = 1;
  errorcomment{end+1,1} = [num2str(error_cnt),'. ',char(scenarioName),'パターン実行時のエラーです。'];
  errorcomment{end+1,1} = [' ',exception.message];
 end
end


if trycnt == 0
 %モデルのwaitbarを閉じる
 close;
 %モデル実行終了時間計測
 MODELENDTIME = fix(clock);
 
 %データ保存用フォルダの作成
 folder_name = [scenarioName];
 if exist(['.\sim_result\',folder_name],'dir') == 0
  mkdir(['.\sim_result\',folder_name]);
 end
 
 %matファイル保存
 matFileName = ['.\sim_result\',folder_name,'\',scenarioName,'.mat'];
 
 %simtimeOutputData;
 
 try
  %テスト結果作成
  ScopeDtTemp=ScopeData;
  writeData = table(ScopeDtTemp.time,'VariableNames',{'time'});
  
  for i = 1:(size(ScopeDtTemp.signals,2))
   tempLabel = strrep(ScopeDtTemp.signals(i).label,'<','');
   tempLabel = strrep(temp_Label,'>','');
   addData = table(ScopeDtTemp.signals(i).values,'VariableNames',{tempLabel});
   writeData = [writeData addData];
  end
  
  delete(['.\sim_result\',folder_name,'\',scenarioName,'_simput.xlsx']);
  writetable(writeData,['.\sim_result\',folder_name,'\',scenarioName,'_simput.xlsx']);
 catch
  disp([scenarioName,'_simput.xlsxが生成できません'])
 end
 try
    close(msg)
    clear('msg')
 catch
 end   
 try
  save(matFileName);
 catch
  error_cnt = error_cnt+1;
  trycnt = 1;
  errorcomment{end+1,1} = [num2str(error_cnt),'. ',char(scenarioName),'のmatファイルを保存できません。'];
 end
 end 