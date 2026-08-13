// -------------------------------------------------------------
// GEOMETRIA S6AS11 - UNIDADES EM CM - VERSÃO ESTÁVEL
// -------------------------------------------------------------
SetFactory("OpenCASCADE");
Delete All;

lc = 5.0; // Tamanho do elemento (cm) - PODE ALTERAR ESSE VALOR AGORA

// --- FORÇA O OPENCASCADE A OBEDECER O TAMANHO ---
Mesh.MeshSizeMin = lc;
Mesh.MeshSizeMax = lc;

// --- CONTORNO EXTERNO (Coordenadas CAD * 100) ---
Point(1)  = {956.00, 283.59, 0, lc};
Point(2)  = {960.00, 291.59, 0, lc};
Point(3)  = {960.00, 331.59, 0, lc};
Point(4)  = {880.00, 331.59, 0, lc};
Point(5)  = {880.00, 317.60, 0, lc};
Point(6)  = {-240.00, 295.20, 0, lc};
Point(7)  = {-240.00, 309.23, 0, lc};
Point(8)  = {-320.00, 309.23, 0, lc};
Point(9)  = {-320.00, 269.23, 0, lc};
Point(10) = {-316.00, 261.23, 0, lc};
Point(11) = {-275.00, 267.23, 0, lc};
Point(12) = {0.00, 255.00, 0, lc};
Point(13) = {0.00, 0.00, 0, lc};
Point(14) = {640.00, 12.80, 0, lc};
Point(15) = {640.00, 267.80, 0, lc};
Point(16) = {915.00, 289.59, 0, lc};

Line(1) = {1, 2};   Line(2) = {2, 3};   Line(3) = {3, 4};   Line(4) = {4, 5};
Line(5) = {5, 6};   Line(6) = {6, 7};   Line(7) = {7, 8};   Line(8) = {8, 9};
Line(9) = {9, 10};  Line(10) = {10, 11}; Line(11) = {11, 12}; Line(12) = {12, 13};
Line(13) = {13, 14}; Line(14) = {14, 15}; Line(15) = {15, 16}; Line(16) = {16, 1};

Curve Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

// --- CONTORNO INTERNO (O Furo) ---
Point(17) = {50.00, 256.00, 0, lc};
Point(18) = {169.98, 278.40, 0, lc};
Point(19) = {470.02, 284.40, 0, lc};
Point(20) = {590.00, 266.80, 0, lc};
Point(21) = {590.00, 51.80, 0, lc};
Point(22) = {530.01, 30.60, 0, lc};
Point(23) = {109.99, 22.20, 0, lc};
Point(24) = {50.00, 41.00, 0, lc};

Line(17) = {17, 18}; Line(18) = {18, 19}; Line(19) = {19, 20}; Line(20) = {20, 21};
Line(21) = {21, 22}; Line(22) = {22, 23}; Line(23) = {23, 24}; Line(24) = {24, 17};

Curve Loop(2) = {17, 18, 19, 20, 21, 22, 23, 24};

// --- DEFINIÇÃO DA SUPERFÍCIE VAZADA ---
// O segredo para não sumir no Reload:
Plane Surface(1) = {1, 2}; 

// --- CONFIGURAÇÃO DE MALHA Q4 ---
Mesh.Algorithm = 6;               // Frontal-Delaunay
Mesh.SubdivisionAlgorithm = 1;    // Força 100% Quadriláteros (Q4)
Recombine Surface {1};

// --- GRUPOS FÍSICOS (Para o seu Python) ---
Physical Surface("quad") = {1};
Physical Curve("line") = {1:24};

Mesh 2;
Save "Caixao-A.msh";