SetFactory("OpenCASCADE");

// --- Pontos Geométricos (Escala em cm) ---
Point(1)  = {163, 177, 0};   Point(2)  = {240, 177, 0};
Point(3)  = {240, 190, 0};   Point(4)  = {0,   190, 0};
Point(5)  = {0,   177, 0};   Point(6)  = {77,  177, 0};
Point(7)  = {77,  170, 0};   Point(8)  = {70,  170, 0};
Point(9)  = {70,  158, 0};   Point(10) = {109, 150, 0};
Point(11) = {109, 45,  0};   Point(12) = {90,  25,  0};
Point(13) = {90,  0,   0};   Point(14) = {150, 0,   0};
Point(15) = {150, 25,  0};   Point(16) = {131, 45,  0};
Point(17) = {131, 150, 0};   Point(18) = {170, 158, 0};
Point(19) = {170, 170, 0};   Point(20) = {163, 170, 0};

// --- Conectividade do Contorno ---
Line(1) = {1, 2};   Line(2) = {2, 3};   Line(3) = {3, 4};   Line(4) = {4, 5};
Line(5) = {5, 6};   Line(6) = {6, 7};   Line(7) = {7, 8};   Line(8) = {8, 9};
Line(9) = {9, 10};  Line(10) = {10, 11}; Line(11) = {11, 12}; Line(12) = {12, 13};
Line(13) = {13, 14}; Line(14) = {14, 15}; Line(15) = {15, 16}; Line(16) = {16, 17};
Line(17) = {17, 18}; Line(18) = {18, 19}; Line(19) = {19, 20}; Line(20) = {20, 1};

Curve Loop(1) = {1:20};
Plane Surface(1) = {1};

// --- RESTRIÇÕES DE MALHA PARA O PYTHON ---
Mesh.CharacteristicLengthMax = 10.0; // Tamanho do elemento
Mesh.Algorithm = 6;                // Frontal-Delaunay
Mesh.SubdivisionAlgorithm = 1;     // FORÇA 100% QUADRILÁTEROS (Q4)
Recombine Surface(1);              

// --- GRUPOS FÍSICOS (Nomes usados no seu código) ---
Physical Surface("dominio") = {1};
Physical Curve("perimetro") = {1:20};

Mesh 2;
Save "viga_vao.msh";