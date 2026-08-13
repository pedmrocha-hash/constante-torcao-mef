SetFactory("OpenCASCADE");

// --- Pontos Geométricos (Escala em cm) ---
Point(1)  = {150, 153.9, 0}; Point(2)  = {170, 158, 0};
Point(3)  = {170, 170,   0}; Point(4)  = {163, 170, 0};
Point(5)  = {163, 177,   0}; Point(6)  = {240, 177, 0};
Point(7)  = {240, 190,   0}; Point(8)  = {0,   190, 0};
Point(9)  = {0,   177,   0}; Point(10) = {77,  177, 0};
Point(11) = {77,  170,   0}; Point(12) = {70,  170, 0};
Point(13) = {70,  158,   0}; Point(14) = {90,  153.9, 0};
Point(15) = {90,  0,     0}; Point(16) = {150, 0,   0};

// --- Conectividade do Contorno ---
Line(1) = {1, 2};   Line(2) = {2, 3};   Line(3) = {3, 4};   Line(4) = {4, 5};
Line(5) = {5, 6};   Line(6) = {6, 7};   Line(7) = {7, 8};   Line(8) = {8, 9};
Line(9) = {9, 10};  Line(10) = {10, 11}; Line(11) = {11, 12}; Line(12) = {12, 13};
Line(13) = {13, 14}; Line(14) = {14, 15}; Line(15) = {15, 16}; Line(16) = {16, 1};

Curve Loop(1) = {1:16};
Plane Surface(1) = {1};

// --- RESTRIÇÕES DE MALHA PARA O PYTHON ---
Mesh.CharacteristicLengthMax = 10.0;
Mesh.Algorithm = 6;
Mesh.SubdivisionAlgorithm = 1;     // FORÇA 100% QUADRILÁTEROS (Q4)
Recombine Surface(1);

// --- GRUPOS FÍSICOS ---
Physical Surface("dominio") = {1};
Physical Curve("perimetro") = {1:16};

Mesh 2;
Save "viga_apoio.msh";