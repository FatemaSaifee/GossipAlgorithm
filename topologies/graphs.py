import matplotlib.pyplot as plt
from scipy.interpolate import spline
import numpy as np
 
############### PushSum Algorithm ######################


# Torus
x = [100,225,324,400,529,625,729,841,900,1024,1156,1225,1369,1444,1521,1600]
xnew = np.linspace(min(x),max(x),300)
y = [156,875,2125,3625,7531,13250,20641,29531,34500,45063,56984,62860,78437,85266,93546,100922]
ynew = spline(x,y,xnew)

# 3D
x1 = [125,216,343,512,512,729,729,1000]
xnew1 = np.linspace(min(x1),max(x1),300)
y1 = [515,1719,5219,10797,11703,23047,24265,46422]
ynew1 = spline(x1,y1,xnew1)

# Line
x2= [100,200,300,400,500]
xnew2 = np.linspace(min(x2),max(x2),300)
y2 = [1234,8219,29625,79672,128657]
ynew2 = spline(x2,y2,xnew2)

# 2D
x3= [100,200,400,800, 900, 1200, 1500]
xnew3 = np.linspace(min(x3),max(x3),300)
y3 = [281,1141,3797,11516,12873,25422, 40329]
ynew3 = spline(x3,y3,xnew3)

# Imperfect Line
x4= [100,200,300,400,550,700,900,1200,1500]
xnew4 = np.linspace(min(x4),max(x4),300)
y4 = [140,188,359,766,1078,3562,2063,3688,5656]
ynew4 = spline(x4,y4,xnew4)

# Full
x5= [100,400,800,1200,1500]
xnew5 = np.linspace(min(x5),max(x5),300)
y5 = [171, 2688, 11125, 27594, 41594 ]
ynew5 = spline(x5,y5,xnew5)

# plt.plot(xnew, ynew, 'r')
# plt.plot(xnew, ynew, 'r', label='torus')
# plt.plot(xnew1, ynew1, 'g', label='3D')
# plt.plot(xnew2, ynew2, 'y', label='line')
# plt.plot(xnew3, ynew3, 'b', label='rand2D')
# plt.plot(xnew4, ynew4, 'k', label='impLine')
# plt.plot(xnew5, ynew5, 'c', label='full')
# plt.grid(True)
# plt.xlabel('Number of Nodes', fontsize=12)
# plt.ylabel('Time (Milliseconds)', fontsize=12)
# plt.title('PushSum Algorithm')
# plt.legend()
# plt.show()

############### Gossip Algorithm ######################

# Torus
x = [100, 400, 900, 1500]
xnew = np.linspace(min(x),max(x),300)
y = [32, 265, 1313, 2578]
ynew = spline(x,y,xnew)

# 3D
x1 = [100, 400, 900, 1500]
xnew1 = np.linspace(min(x1),max(x1),300)
y1 = [97,500,3699,13387]
ynew1 = spline(x1,y1,xnew1)

# Line
x2 = [100, 200, 400, 800]
xnew2 = np.linspace(min(x2),max(x2),300)
y2 = [63, 328, 5000, 43047]
ynew2 = spline(x2,y2,xnew2)

# 2D
x3 = [100, 400, 900, 1500]
xnew3 = np.linspace(min(x3),max(x3),300)
y3 = [31,219,1016,4000]
ynew3 = spline(x3,y3,xnew3)

# Imperfect Line
x4 = [100, 400, 900, 1500]
xnew4 = np.linspace(min(x4),max(x4),300)
y4 = [149, 706, 3627, 43047]
ynew4 = spline(x4,y4,xnew4)

# Full
x5 = [100, 400, 900, 1500]
xnew5 = np.linspace(min(x5),max(x5),300)
y5 = [16, 578, 3312, 12375]
ynew5 = spline(x5,y5,xnew5)


# plt.plot(xnew, ynew, 'r')
# plt.plot(xnew, ynew, 'r', label='torus')
# plt.plot(xnew1, ynew1, 'g', label='3D')
# plt.plot(xnew2, ynew2, 'y', label='line')
# plt.plot(xnew3, ynew3, 'b', label='rand2D')
# plt.plot(xnew4, ynew4, 'k', label='impLine')
# plt.plot(xnew5, ynew5, 'c', label='full')
# plt.grid(True)
# plt.xlabel('Number of Nodes', fontsize=12)
# plt.ylabel('Time (Milliseconds)', fontsize=12)
# plt.title('Gossip Algorithm')
# plt.legend()
# plt.show()



x = [0, 10,30,60,100,150,200]
xnew = np.linspace(min(x),max(x),300)
y = [216, 281, 188, 78, 62, 47, 32]
ynew = spline(x,y,xnew)

plt.plot(xnew, ynew, 'r')
plt.xlabel('Number of Failed Nodes', fontsize=12)
plt.ylabel('Time (Milliseconds)', fontsize=12)
plt.title('Gossip Algorithm with node failures')
# plt.legend()
plt.show()