clear all
rng default
input_data = inputdlg({'可转债代码','待预测起始日期  yyyy-mm-dd','待预测终止日期  yyyy-mm-dd'});

w = windmatlab;
[bond_codes1,~,~,~,~,~] = w.wset('sectorconstituent','date=2019-07-25;sectorid=a101010206000000;field=wind_code'); % 上交所可转债代码
[bond_codes2,~,~,~,~,~] = w.wset('sectorconstituent','date=2019-07-25;sectorid=a101010306000000;field=wind_code'); % 深交所可转债代码
bond_codes = [bond_codes1;bond_codes2]; % 所有可转债代码
if sum(strcmp(bond_codes,input_data(1)))==0
    errordlg('警告：可转债代码错误！','错误')
end

[stock_codes,~,~,~,~,~]=w.wsd(input_data(1),'underlyingcode',input_data(3),input_data(3)); % 可转债对应股票代码
% 获取指定正股待预测区间的 股价、固定波动率
[data_stock,~,~,times_stock,~,~] = w.wsd(stock_codes,'close,annualstdevr_24m',input_data(2),input_data(3));
% 获取指定可转债待预测区间的 到期日、发行日、回售开始日、最新债项评级、转股价、距下一付息日天数、收盘价(全价)、利率说明、债券名称
[data_bond,~,~,times_bond,~,~] = w.wsd(input_data(1),'maturitydate,clause_conversion_2_swapsharestartdate,clause_putoption_conditionalputbackstartenddate,amount,convprice,nxcupn2,dirtyprice,coupontxt,sec_name',cell2mat(input_data(3)),cell2mat(input_data(4)));

discount = [0.032591,0.033751,0.035340,0.035999,0.036493,0.037185;  % 贴现率
    0.046304,0.047977,0.048168,0.049424,0.050393,0.050948;
    0.047304,0.048977,0.049168,0.050524,0.051493,0.052248;
    0.048504,0.050177,0.050568,0.052024,0.053193,0.053948;
    0.050704,0.052377,0.053368,0.054824,0.055993,0.056948;
    0.059504,0.061377,0.064268,0.066624,0.067793,0.069248];
rank = {'无风险','AAA','AAA-','AA+','AA','AA-'}; % 债券评级
bond_predict = zeros(size(times_stock)); % 预测可转债价值
bond_true = cell2mat(data_bond(:,7)); % 真实可转债价值
T_end = datenum(cell2mat(data_bond(1,1))); % 到期
T_start = datenum(cell2mat(data_bond(1,2))); % 发行
T_put = datenum(cell2mat(data_bond(1,3))); % 回售
u = 0.0175; % 无风险利率 一年定存
sigma = data_stock(1,2)/100; % 固定波动率
N = 1000; % 模拟路径数
V = 106; % 赎回价&偿还价
t = 1/250;  % 时间间隔（步长）
rate = str2double(regexp(string(data_bond(1,8)),'\d*\.\d*(?=%)','match'))/100; % 利率
years = length(rate); % 可转债年限

for m = 1:length(times_stock)
    disp(m)
    T = T_end - times_stock(m); % 到期天数
    TD = round(T*250/365); % 折算交易日
    K = cell2mat(data_bond(m,5))*ones(TD+1,N); % 转股价
    S = zeros(TD+1,N); % 路径
    S(1,:) = data_stock(m,1); % 股价
    P = zeros(2,N); % [现期，到期]可转债价值
    v = discount(strcmp(rank,cell2mat(data_bond(m,4))),:); % 贴现率
    already_day = times_stock(m) - T_start;  % 可转债已开始天数
    already_year = floor(already_day/365)+1;  % 第？个付息年
    nxcupn2 = double(cell2mat(data_bond(m,6)))/365;  % 距下一付息日年数
    index1 = zeros(1,N); % 最近一次下修时间
    index2 = []; % 回售路径
    index3 = []; % 转股路径
    index4 = []; % 赎回路径
        
    for j = 1:N % 第j条模拟
        for i = 1:TD % 第i步
            if ismember(j,index2) || ismember(j,index3)
                continue
            end
            S(i+1,j) = S(i,j)*min(max(exp((u-0.5*sigma^2)*t + sigma*sqrt(t)*randn()),0.9),1.1); % B-S模型，控制10%涨停跌停
            
            % 转股
            if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*1.3>=0)>=15 % 任何连续三十个交易日中至少十五个交易日的收盘价格不低于当期转股价格的130%（含130%）
                index3 = [index3,j];
                P(2,j) = S(i+1,j)*100/K(i+1,j);
                n = floor(i/250-nxcupn2)+1;% 判断拿了多少次利息
                P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
                if n
                    P(1,j) = P(1,j) + sum(100*rate(already_year:already_year+n-1)./(1+v(1:1+n-1)).^(nxcupn2:n-1+nxcupn2));
                end
            end
            
            % 下修
%             if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % 任意连续三十个交易日中至少有十五个交易日的收盘价低于当期转股价格的80%
%                 if rand() < 0.51 % 下修概率
%                     K(i+1:end,j) = max(mean(S(i-18:i+1,j)),S(i+1,j)); % 修正后的转股价格应不低于本次股东大会召开日前二十个交易日公司股票交易均价和前一交易日均价之间的较高者
%                     index1(j) = i+1;
%                 end
%             end
            
            % 回售  
            if i>=max(T_put - times_stock(m),29)... % 已到回售起始日
                && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % 任何连续三十个交易日的收盘价格低于当期转股价格的70%
%                 if i+1-index1(j)>=30 % 如果出现转股价格向下修正的情况，则上述“连续三十个交易日”须从转股价格调整之后的第一个交易日起重新计算
                    index2 = [index2,j];
                    P(2,j) = 100*(1+rate(min(ceil((already_day+i*365/250)/365),years))); % 可转换公司债券持有人按面值加上当期应计利息的价格回售给公司
                    n = floor(i/250-nxcupn2)+1;% 判断拿了多少次利息
                    P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
                    if n
                        P(1,j) = P(1,j) + sum(100*rate(already_year:already_year+n-1)./(1+v(1:1+n-1)).^(nxcupn2:n-1+nxcupn2)); % 加上已拿利息的折现
                    end
%                 end
            end
            
        end
    end
    
    for s = 1:N
        if P(2,s)==0 % 到期
            P(1,s) = sum(rate(already_year:end)./(1+v(already_year:years)).^(nxcupn2:years-already_year+nxcupn2)); % 到期前利息折现
            if S(TD+1,s)*100/K(TD+1,s)>V % 到期转股
                P(1,s) = P(1,s) + S(TD+1,s)*100/K(TD+1,s)/(1+v(end))^(T/365);
            else % 到期赎回
                index4 = [index4,s];
                P(1,s) = P(1,s) + V/(1+v(end))^(T/365);
            end
        end
    end
    
    bond_predict(m) = mean(P(1,:));
end
%% 真实vs预测 价格折线图
figure()
hold on
plot(bond_true,'LineWidth',1.5);
plot(bond_predict,'LineWidth',1.5);
h1 = plot(bond_true,'s','MarkerFaceColor',[0,0.45,0.74],'MarkerEdgeColor',[0,0.45,0.74]);
h2 = plot(bond_predict,'d','MarkerFaceColor',[0.85,0.33,0.1],'MarkerEdgeColor',[0.85,0.33,0.1]);
legend([h1,h2],'实际价格','预测价格')
title([cell2mat(data_bond(1,9)),'  ',cell2mat(input_data(2)),'至',cell2mat(input_data(3))],'FontName','黑体','FontSize',15,'FontWeight','bold')
set(gca,'xtick',1:length(times_stock))
set(gca,'xticklabel',cellstr(datestr(times_stock,'yyyy/mm/dd')))
xtickangle(40)
table(bond_true,bond_predict)
% figure(),bar(bond_true-bond_predict)
disp(['标准差 ',num2str(std(bond_true-bond_predict,1))])