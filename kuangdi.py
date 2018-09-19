import  kNN
group,labels = kNN.createDataSet()
print(kNN.classify0([2,2],group,labels,3))