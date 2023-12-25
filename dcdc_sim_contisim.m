%=====================================================
%環境実行スクリプト
%=====================================================%

%ワークスペース初期化
clear;

%パス追加
addpath(genpath('.'));

%テストデータリストの格納
[num,txt,raw] = xlsread('.\sim_pattern\testdata_list.xlsx');

%テストパターン数確認
ptn = size(raw,1);

errorcomment = {'連続実行エラー項目'};
err_cnt = 0;

for cnt = 2:ptn
 cnt_str = num2str(cnt-1);
 ptn_str = num2str(ptn-1);
 msg = waitbar((cnt-2)/((ptn-1)),['連続シミュレーション実行中...(',cnt_str,'/',ptn_str,')']); %waitbarの表示
 trycnt = 0;
 senarioName = cell2mat(raw(cnt,1)); %テストパターン名定義
 
 for listchk = 2:2 %testdata_listの設定ミスをチェック
  %テストパターン名未記入、設定値未記入、設定値に数字以外を記入した場合エラー
  if isnan(cell2mat(raw(cnt,1)))
  err_cnt = err_cnt + 1;
  trycnt = 1;
  errorcomment{end+1,1} = [num2str(error_cnt),'.testdata_listの',num2str(cnt),'列目のパターン名に誤りがあります。未記入になっていないかなどを確認してください。'];
  break;
  end
 end
 
 if trycnt == 0
  try 
   dcdc_sim_demo_forloop; %sim実行
  catch
  end
 end
 if trycnt == 0
  try
   dcdc_sim_graph; %sim結果のプロット
  catch
  end
 end
 try
  close(msg);
 catch
 end
 
 try
  if trycnt == 1
   %データ保存用フォルダの作成
   folder_name = [scenarioName,'_エラー'];
    if exist(['.\sim_result\',folder_name],'dir') == 0
     mkdir(['.\sim_result\',folder_name]);
     end
     %matファイルを保存
     matFileName = ['.\sim_result\',folder_name,'\',scenarioName,'_error.mat'];
     save(matFileName);
    end
 catch
 end
 
 end
 
 %error_log_for_loop;%エラーログの作成
 
 try
  close all hidden
 catch
 end
 
 %シミュレーション終了の表示
 msgbox('シミュレーションが完了しました','dcdc_sim_demo');
  