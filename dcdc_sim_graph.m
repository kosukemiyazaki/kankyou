%=====================================================
%Sim結果グラフ化
%=====================================================

%エクセルファイルからデータを取り出す
%dcdc_sim_demo実行時にScenarioNameに対象エクセルファイル名が記載されている

Folder = ['.\sim_result\',scenarioName];

 if exist(['.\sim_result\',scenarioName],'dir') == 0
  mkdir(['.\sim_result\',scenarioName]);
 end
 
exelData = GetLabelNameList(scenarioNme);

[labelNameNum,~] = size(excelData);%読み出したデータ数

IN_OUTList = excelData(:,1); %IN/OUT
labelNameList = excelData(:,2); %ラベル名
IFNameList = excelData(:,2); %IF名 データ数

wsHeader = {'OUT_'};

errorData = [];
plotData = [];
plotFlag = 0;
graphNum = 0;

for i = 1:labelNameNum
 char(labelNameList(i));
  if strcmp('-',char(labelNameList(i)))
   plotFlag = 1;
  else
   plotData = [plotData,i];
  end
  
  if i = labelNameNum
   plotFlag = 1;
  end
  
  if plotFlag == 1
   graphNum = graphNum +1;
   graphTitle = [scenarioName,'_',num2str(graphNum)];
   callerHeader = ['savetimeSeriesGraph(',num2str(length(plotData)),',''',graphTitle,''',Folder,0'];
   callerBody = [];
   for j = plotData
    %線色設定
     if strcmp('IN',char(IN_OUTList(j)))
        lineColor = '''b''';
     else
        lineColor = '''r''';
     end
     blank = '';
     %ラベル名
     labelName = char(labelNameList(j));
     %ワークスペース名
     wsName = ['OUT_',labelName];
     %IF名
     IFName = char(IFNameList(j));

     callerBody = [callerBody,',''',wsName,''',''',blank,''',''-'',-inf,inf,''',labelName,''',''',IFName,''',',lineColor];
    end
    callerFooter = '):';
    callerData = [callerHeader,callerBody,callerFooter];
    evalin('base',callerData);
    plotFlag = 0;
    plotData = [];
  end
end

%グラフ成形ファイル実行
fixGraoh;



 