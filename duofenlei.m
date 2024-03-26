clear;clc;
data = load("Iris.mat");
Class = data.Class;
Feature = zscore(data.Feature);

%% train

x_train = Feature([1:30,51:80,101:130],:);

y_train = Class([1:30,51:80,101:130],:);


x_c1 = x_train(1:30,:);
x_c2 = x_train(31:60,:);
x_c3 = x_train(61:90,:);

y_c1 = y_train(1:30,:);
y_c2 = y_train(31:60,:);
y_c3 = y_train(61:90,:);

%% test

x_t1 = Feature(31:50,:);
x_t2 = Feature(81:100,:);
x_t3 = Feature(131:150,:);
x_test =[x_t1;x_t2;x_t3];

y_t1 = Class(31:50,:);
y_t2 = Class(81:100,:);
y_t3 = Class(131:150,:);
y_test = [y_t1;y_t2;y_t3];

%% LDA

sigma1 = 29*cov(x_c1);
sigma2 = 29*cov(x_c2);
sigma3 = 29*cov(x_c3);

sw = sigma1+sigma2+sigma3;
X = [x_c1; x_c2; x_c3];
st = 89* cov(X);
sb = st - sw;


%% V, 一个矩阵，其列是输入矩阵的特征向量。
%% D, 一个对角矩阵，其对角线上的元素是输入矩阵的特征值
[V,D] = eig (sw\sb);

%% 降维并绘图 （w为4*2大小的投影矩阵将属性数为4的样本的投影到2维空间）
w = V(:,1:2);

f = @(x)x*w;

y1 = f(x_c1);
scatter(y1(:,1),y1(:,2))
hold on;
y2 = f(x_c2);
scatter(y2(:,1),y2(:,2))
y3 = f(x_c3);
scatter(y3(:,1),y3(:,2))



%% 预测新数据类别，假设度量为欧式距离

%% 计算测试数据的投影
y_new = x_test*w;
scatter(y_new( :,1),y_new(:,2));
legend('第一类', '第二类', '第三类','测试数据');

%% 计算测试点的投影点到各类的距离并分类
u1 = mean(y1);
u2 = mean(y2);
u3 = mean(y3);
[m,~] = size(y_new);

% arr用于放测试点的预测类别
arr=zeros(m,1);

% 计算第i个测试点和三类数据均值的距离，若距第j类最近则让arr[i]=j
for i=1:m
    distance1 = pdist2(y_new(i,:),u1,'euclidean');
    distance2 = pdist2(y_new(i,:),u2,'euclidean');
    distance3 = pdist2(y_new(i,:),u3,'euclidean');
    distance =[distance1,distance2,distance3];
    d = min(distance);
    for j=1:3
        if d==distance(j)
            cla = j;

        end
    end
    arr(i,1)=cla;
end

%% 输出预测结果
disp("LDA预测结果")
disp(arr)


%% 对数几率回归 
%% OVO拆分策略 训练三个分类器

%% 利用logit.m内的函数训练分类器 并给出待预测数据在分类器中类别
[m,~] = size(x_test);
arr1 = zeros(m,1);
for i=1:m
    % c1 为 +  c2为 -
    class1 = logit(x_test(i,:),x_c1,y_c1,x_c2,y_c2);
    % c1 为 +  c3为 -
    class2 = logit(x_test(i,:),x_c1,y_c1,x_c3,y_c3);
    % c2 为 +  c3为 -
    class3 = logit(x_test(i,:),x_c2,y_c2,x_c3,y_c3);
    
    %% 计算票数
    c1 = 1 * (class1) + 1 * (class2);
    c2 = 1 * (~class1) + 1 * (class3);
    c3 = 1 * (~class2) + 1 * (~class3);

    c= [c1 c2 c3];

    [max_value, max_index] = max(c);
    arr1(i,1) = max_index;

% 
end
disp("对数几率回归")
disp(arr1)
















