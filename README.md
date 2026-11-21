/# Static_WindowedSandwichStructure

Static Deflection Analysis of a Curved sandwich Plate Embedding pattern of Windows

This MATLAB code analyses the static deflection of a curved  plate subjected to uniform transverse pressure. 
A three layer layup is considered for the plate structure.
<img width="583" height="395" alt="image" src="https://github.com/user-attachments/assets/31b687a8-6f42-4fd6-96ae-1ec9b36ffc71" />

The structure incorporates multiple rectangular windows filled with a different material, representing potential applications such as aircraft window panels.
<img width="435" height="218" alt="image" src="https://github.com/user-attachments/assets/3ebb5d2b-019e-4eb0-bfb9-a865579a9af0" />



The analytical formulation is based on Classical Lamination Theory (CLT) and a shallow-shell approximation. The plate is modelled as a piecewise composite structure, with distinct extensional and bending stiffness properties inside and outside the window regions.

Simply supported boundary conditions are satisfied using trigonometric (Navier-type) displacement functions. The governing equations are then solved using the Galerkin method, with the required integrals evaluated analytically in closed form. This approach avoids numerical or symbolic integration and provides an efficient computational solution.

The script allows users to define:

Layer thicknesses and plate dimensions.

(The original code is developed in 2013)

Window area fraction and rectangular window arrangement.

Material properties of the composite layers and window filler.

Principal radii of curvature.

Applied uniform pressure.

The outputs include the deflection at the plate centre, and the deflection contour:
<img width="1009" height="521" alt="image" src="https://github.com/user-attachments/assets/b1f56bdf-58a2-44e9-9228-ec4ad5707b57" />


(I created the original code in 2013).
