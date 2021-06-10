[![View LuGre friction model in MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/84792-lugre-friction-model-in-matlab)

Reconstruction of the paper: A new model for control systems with friction  
By: Canudas de Wit et al., 1995, IEEE Transactions on Automatic Control  

I am trying to reconstruct as many figures as possible from the paper above.  

Link to the paper: https://ieeexplore.ieee.org/document/376053  

There are 2 m-files:

2. demo2.m

This is the second attempt at reconstructing the paper. Here, I use the built-in MATLAB solver: ode23s, which is designed for a stiff system. Thus, it takes less time to complete the simulation. In order to use MATLAB built-in solver, the problem must be first formalized. Plese see the PDF file [here](./problem_formalization.pdf).

3. demo3.m

This is an additional simulation to demonstrate the friction observer. This is not shown in the paper. Basically, this is a numerical simulation of section V.B, for position control with a unit-step input.

4. demo4.m 

This shows optimally tuned PI and velocity gain without the friction observer. The performance is superior to the friction observer with poorly tuned PI and velocity gains.

-------------------------------

Not shown in the paper. Run demo2.

![fig1](fig1.png)

-------------------------------

Not shown in the paper. Run demo2.

![fig2](fig2.png)

-------------------------------

Fig. 3 of the paper. Run demo2.

![fig3](fig3.png)

-------------------------------

Fig. 2 of the paper. Run demo2.

![fig4](fig4.png)

-------------------------------

Fig. 6 of the paper. Run demo2.

![fig5](fig5.png)

-------------------------------

Fig. 4 of the paper. Run demo2.

![fig6](fig6.png)

-------------------------------

Fig. 8 of the paper. Run demo2.

![fig6](fig7.png)

-------------------------------

Not shown in the paper. Run demo3.

![fig6](fig8.png)

-------------------------------

Note that if the PI and velocity gains are optimally tuned, then the performance is better than the friction observer. Rise time is smaller and overshoot is smaller. This model is generally easier to tune. Run demo4.

![fig6](fig9.png)
