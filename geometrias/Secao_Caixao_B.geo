// -------------------------------------------------------------
// NOVA GEOMETRIA CAIXÃO - VERSÃO ESTÁVEL COMPROVADA
// -------------------------------------------------------------
SetFactory("OpenCASCADE");
Delete All;

lc = 5.0; // Tamanho do elemento - PODE ALTERAR ESSE VALOR AGORA

// --- FORÇA O OPENCASCADE A OBEDECER O TAMANHO ---
Mesh.MeshSizeMin = lc;
Mesh.MeshSizeMax = lc;

// --- CONTORNO EXTERNO ---
Point(1)  = {810.4588, 819.1486, 0};
Point(2)  = {890.4588, 819.1486, 0};
Point(3)  = {890.4588, 779.1486, 0};
Point(4)  = {886.4588, 771.1486, 0};
Point(5)  = {845.4588, 777.1486, 0};
Point(6)  = {570.4588, 755.3599, 0};
Point(7)  = {570.4588, 150.3599, 0};
Point(8)  = {-69.5412, 137.5599, 0};
Point(9)  = {-69.5412, 742.5599, 0};
Point(10) = {-344.5412, 754.7880, 0};
Point(11) = {-385.5412, 748.7880, 0};
Point(12) = {-389.5412, 756.7880, 0};
Point(13) = {-389.5412, 796.7880, 0};
Point(14) = {-309.5412, 796.7880, 0};
Point(15) = {-309.5412, 782.7599, 0};
Point(16) = {810.4588, 805.1599, 0};

Line(1) = {1, 2};   Line(2) = {2, 3};   Line(3) = {3, 4};   Line(4) = {4, 5};
Line(5) = {5, 6};   Line(6) = {6, 7};   Line(7) = {7, 8};   Line(8) = {8, 9};
Line(9) = {9, 10};  Line(10) = {10, 11}; Line(11) = {11, 12}; Line(12) = {12, 13};
Line(13) = {13, 14}; Line(14) = {14, 15}; Line(15) = {15, 16}; Line(16) = {16, 1};

Curve Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

// --- CONTORNO INTERNO (O Furo) ---
Point(17) = {510.4588, 249.1599, 0};
Point(18) = {450.4708, 227.9601, 0};
Point(19) = {50.4468,  219.9596, 0};
Point(20) = {-9.5412,  238.7599, 0};
Point(21) = {-9.5412,  743.7599, 0};
Point(22) = {110.4349, 766.1594, 0};
Point(23) = {390.4828, 771.7604, 0};
Point(24) = {510.4588, 754.1599, 0};

Line(17) = {17, 18}; Line(18) = {18, 19}; Line(19) = {19, 20}; Line(20) = {20, 21};
Line(21) = {21, 22}; Line(22) = {22, 23}; Line(23) = {23, 24}; Line(24) = {24, 17};

Curve Loop(2) = {17, 18, 19, 20, 21, 22, 23, 24};

// --- DEFINIÇÃO DA SUPERFÍCIE VAZADA ---
Plane Surface(1) = {1, 2}; 

// --- CONFIGURAÇÃO DE MALHA Q4 ---
Mesh.Algorithm = 6;               // Frontal-Delaunay
Mesh.SubdivisionAlgorithm = 1;    // Força 100% Quadriláteros (Q4)
Recombine Surface {1};

// --- GRUPOS FÍSICOS (Para o seu Python) ---
Physical Surface("quad") = {1};
Physical Curve("line") = {1:24};

Mesh 2;
Save "Caixao-B.msh";