[![View LuGre friction model in MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/84792-lugre-friction-model-in-matlab)

Reconstruction of the paper: A new model for control systems with friction  
By: Canudas de Wit et al., 1995, IEEE Transactions on Automatic Control  

I am trying to reconstruct as many figures as possible from the paper above.  

Link to the paper: https://ieeexplore.ieee.org/document/376053  

There are 2 m-files:

1. demo1.m

This is the first attempt at reconstructing the paper. I use the basic Euler method here to perform the integration. It takes more time to complete the simulation since a high sampling rate is necessary to mantain stability. The system itself is a very stiff ODE.

2. demo2.m

This is the second attempt at reconstructing the paper. Here, I use the built-in MATLAB solver: ode23s, which is designed for a stiff system. Thus, it takes less time to complete the simulation. In order to use MATLAB built-in solver, the problem must be first formalized. Plese see the PDF file [here](./problem_formalization.pdf).

3. demo3.m

This is an additional simulation to demonstrate the friction observer. This is not shown in the paper. Basically, this is a numerical simulation of section V.B, for position control with a unit-step input.

-------------------------------

Not shown in the paper

![fig1](https://github.com/auralius/LuGre/blob/master/fig1.png)

-------------------------------

Not shown in the paper

![fig2](https://github.com/auralius/LuGre/blob/master/fig2.png)

-------------------------------

Fig. 3 of the paper

![fig3](https://github.com/auralius/LuGre/blob/master/fig3.png)

-------------------------------

Fig. 2 of the paper

![fig4](https://github.com/auralius/LuGre/blob/master/fig4.png)

-------------------------------

Fig. 6 of the paper

![fig5](https://github.com/auralius/LuGre/blob/master/fig5.png)

-------------------------------

Fig. 4 of the paper

![fig6](https://github.com/auralius/LuGre/blob/master/fig6.png)

-------------------------------

Fig. 8 of the paper

![fig6](https://github.com/auralius/LuGre/blob/master/fig7.png)

-------------------------------

Not shown in the paper

![fig6](https://github.com/auralius/LuGre/blob/master/fig8.png)
