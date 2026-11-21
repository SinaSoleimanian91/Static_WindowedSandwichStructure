/# Static_WindowedSandwichStructure

Static Deflection Analysis of a Curved sandwich Plate Embedding pattern of Windows

This MATLAB code calculates the static deflection of a three-layer curved composite plate subjected to uniform transverse pressure. The structure incorporates multiple rectangular windows filled with a different material, representing potential applications such as aircraft window panels.
<img width="1225" height="614" alt="image" src="https://github.com/user-attachments/assets/be23b963-6689-4d90-aed0-45ade6e28c16" />


The analytical formulation is based on Classical Lamination Theory (CLT) and a shallow-shell approximation. The plate is modelled as a piecewise composite structure, with distinct extensional and bending stiffness properties inside and outside the window regions.

Simply supported boundary conditions are satisfied using trigonometric (Navier-type) displacement functions. The governing equations are then solved using the Galerkin method, with the required integrals evaluated analytically in closed form. This approach avoids numerical or symbolic integration and provides an efficient computational solution.

The script allows users to define:

Layer thicknesses and plate dimensions.

(The original code is developed in 2013)

Window area fraction and rectangular window arrangement.

Material properties of the composite layers and window filler.

Principal radii of curvature.

Applied uniform pressure.

The outputs include the deflection at the plate centre, a two-dimensional deflection contour, and a three-dimensional representation of the deformed curved plate.
(I created the original code in 2013).
