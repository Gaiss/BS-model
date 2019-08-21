clear all
rng default
input_data = inputdlg({'��תծ����','��Ԥ����ʼ����  yyyy-mm-dd','��Ԥ����ֹ����  yyyy-mm-dd'});

w = windmatlab;
[bond_codes1,~,~,~,~,~] = w.wset('sectorconstituent','date=2019-07-25;sectorid=a101010206000000;field=wind_code'); % �Ͻ�����תծ����
[bond_codes2,~,~,~,~,~] = w.wset('sectorconstituent','date=2019-07-25;sectorid=a101010306000000;field=wind_code'); % �����תծ����
bond_codes = [bond_codes1;bond_codes2]; % ���п�תծ����
if sum(strcmp(bond_codes,input_data(1)))==0
    errordlg('���棺��תծ�������','����')
end

[stock_codes,~,~,~,~,~]=w.wsd(input_data(1),'underlyingcode',input_data(3),input_data(3)); % ��תծ��Ӧ��Ʊ����
% ��ȡָ�����ɴ�Ԥ������� �ɼۡ��̶�������
[data_stock,~,~,times_stock,~,~] = w.wsd(stock_codes,'close,annualstdevr_24m',input_data(2),input_data(3));
% ��ȡָ����תծ��Ԥ������� �����ա������ա����ۿ�ʼ�ա�����ծ��������ת�ɼۡ�����һ��Ϣ�����������̼�(ȫ��)������˵����ծȯ����
[data_bond,~,~,times_bond,~,~] = w.wsd(input_data(1),'maturitydate,clause_conversion_2_swapsharestartdate,clause_putoption_conditionalputbackstartenddate,amount,convprice,nxcupn2,dirtyprice,coupontxt,sec_name',cell2mat(input_data(3)),cell2mat(input_data(4)));

discount = [0.032591,0.033751,0.035340,0.035999,0.036493,0.037185;  % ������
    0.046304,0.047977,0.048168,0.049424,0.050393,0.050948;
    0.047304,0.048977,0.049168,0.050524,0.051493,0.052248;
    0.048504,0.050177,0.050568,0.052024,0.053193,0.053948;
    0.050704,0.052377,0.053368,0.054824,0.055993,0.056948;
    0.059504,0.061377,0.064268,0.066624,0.067793,0.069248];
rank = {'�޷���','AAA','AAA-','AA+','AA','AA-'}; % ծȯ����
bond_predict = zeros(size(times_stock)); % Ԥ���תծ��ֵ
bond_true = cell2mat(data_bond(:,7)); % ��ʵ��תծ��ֵ
T_end = datenum(cell2mat(data_bond(1,1))); % ����
T_start = datenum(cell2mat(data_bond(1,2))); % ����
T_put = datenum(cell2mat(data_bond(1,3))); % ����
u = 0.0175; % �޷������� һ�궨��
sigma = data_stock(1,2)/100; % �̶�������
N = 1000; % ģ��·����
V = 106; % ��ؼ�&������
t = 1/250;  % ʱ������������
rate = str2double(regexp(string(data_bond(1,8)),'\d*\.\d*(?=%)','match'))/100; % ����
years = length(rate); % ��תծ����

for m = 1:length(times_stock)
    disp(m)
    T = T_end - times_stock(m); % ��������
    TD = round(T*250/365); % ���㽻����
    K = cell2mat(data_bond(m,5))*ones(TD+1,N); % ת�ɼ�
    S = zeros(TD+1,N); % ·��
    S(1,:) = data_stock(m,1); % �ɼ�
    P = zeros(2,N); % [���ڣ�����]��תծ��ֵ
    v = discount(strcmp(rank,cell2mat(data_bond(m,4))),:); % ������
    already_day = times_stock(m) - T_start;  % ��תծ�ѿ�ʼ����
    already_year = floor(already_day/365)+1;  % �ڣ�����Ϣ��
    nxcupn2 = double(cell2mat(data_bond(m,6)))/365;  % ����һ��Ϣ������
    index1 = zeros(1,N); % ���һ������ʱ��
    index2 = []; % ����·��
    index3 = []; % ת��·��
    index4 = []; % ���·��
        
    for j = 1:N % ��j��ģ��
        for i = 1:TD % ��i��
            if ismember(j,index2) || ismember(j,index3)
                continue
            end
            S(i+1,j) = S(i,j)*min(max(exp((u-0.5*sigma^2)*t + sigma*sqrt(t)*randn()),0.9),1.1); % B-Sģ�ͣ�����10%��ͣ��ͣ
            
            % ת��
            if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*1.3>=0)>=15 % �κ�������ʮ��������������ʮ��������յ����̼۸񲻵��ڵ���ת�ɼ۸��130%����130%��
                index3 = [index3,j];
                P(2,j) = S(i+1,j)*100/K(i+1,j);
                n = floor(i/250-nxcupn2)+1;% �ж����˶��ٴ���Ϣ
                P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
                if n
                    P(1,j) = P(1,j) + sum(100*rate(already_year:already_year+n-1)./(1+v(1:1+n-1)).^(nxcupn2:n-1+nxcupn2));
                end
            end
            
            % ����
%             if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % ����������ʮ����������������ʮ��������յ����̼۵��ڵ���ת�ɼ۸��80%
%                 if rand() < 0.51 % ���޸���
%                     K(i+1:end,j) = max(mean(S(i-18:i+1,j)),S(i+1,j)); % �������ת�ɼ۸�Ӧ�����ڱ��ιɶ�����ٿ���ǰ��ʮ�������չ�˾��Ʊ���׾��ۺ�ǰһ�����վ���֮��Ľϸ���
%                     index1(j) = i+1;
%                 end
%             end
            
            % ����  
            if i>=max(T_put - times_stock(m),29)... % �ѵ�������ʼ��
                && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % �κ�������ʮ�������յ����̼۸���ڵ���ת�ɼ۸��70%
%                 if i+1-index1(j)>=30 % �������ת�ɼ۸������������������������������ʮ�������ա����ת�ɼ۸����֮��ĵ�һ�������������¼���
                    index2 = [index2,j];
                    P(2,j) = 100*(1+rate(min(ceil((already_day+i*365/250)/365),years))); % ��ת����˾ծȯ�����˰���ֵ���ϵ���Ӧ����Ϣ�ļ۸���۸���˾
                    n = floor(i/250-nxcupn2)+1;% �ж����˶��ٴ���Ϣ
                    P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
                    if n
                        P(1,j) = P(1,j) + sum(100*rate(already_year:already_year+n-1)./(1+v(1:1+n-1)).^(nxcupn2:n-1+nxcupn2)); % ����������Ϣ������
                    end
%                 end
            end
            
        end
    end
    
    for s = 1:N
        if P(2,s)==0 % ����
            P(1,s) = sum(rate(already_year:end)./(1+v(already_year:years)).^(nxcupn2:years-already_year+nxcupn2)); % ����ǰ��Ϣ����
            if S(TD+1,s)*100/K(TD+1,s)>V % ����ת��
                P(1,s) = P(1,s) + S(TD+1,s)*100/K(TD+1,s)/(1+v(end))^(T/365);
            else % �������
                index4 = [index4,s];
                P(1,s) = P(1,s) + V/(1+v(end))^(T/365);
            end
        end
    end
    
    bond_predict(m) = mean(P(1,:));
end
%% ��ʵvsԤ�� �۸�����ͼ
figure()
hold on
plot(bond_true,'LineWidth',1.5);
plot(bond_predict,'LineWidth',1.5);
h1 = plot(bond_true,'s','MarkerFaceColor',[0,0.45,0.74],'MarkerEdgeColor',[0,0.45,0.74]);
h2 = plot(bond_predict,'d','MarkerFaceColor',[0.85,0.33,0.1],'MarkerEdgeColor',[0.85,0.33,0.1]);
legend([h1,h2],'ʵ�ʼ۸�','Ԥ��۸�')
title([cell2mat(data_bond(1,9)),'  ',cell2mat(input_data(2)),'��',cell2mat(input_data(3))],'FontName','����','FontSize',15,'FontWeight','bold')
set(gca,'xtick',1:length(times_stock))
set(gca,'xticklabel',cellstr(datestr(times_stock,'yyyy/mm/dd')))
xtickangle(40)
table(bond_true,bond_predict)
% figure(),bar(bond_true-bond_predict)
disp(['��׼�� ',num2str(std(bond_true-bond_predict,1))])