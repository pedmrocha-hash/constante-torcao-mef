SetFactory("OpenCASCADE");

// --------------------
// 1. Pontos (coordenadas)
// --------------------
Point(1) = {0,  0,  0};
Point(2) = {100, 0,  0};
Point(3) = {100, 100, 0};
Point(4) = {0,  100, 0};

// --------------------
// 2. Linhas (bordas)
// --------------------
Line(1) = {1, 2};  // inferior
Line(2) = {2, 3};  // direita
Line(3) = {3, 4};  // superior
Line(4) = {4, 1};  // esquerda

// --------------------
// 3. Superfície
// --------------------
Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// --------------------
// 4. Controle da malha
// --------------------
nx = 3;
ny = 3;

Transfinite Line {1,3} = nx + 1;
Transfinite Line {2,4} = ny + 1;

Transfinite Surface {1};
Recombine Surface {1};

// --------------------
// 5. Physical groups
// --------------------
Physical Surface("dominio") = {1};
Physical Curve("perimetro") = {1,2,3,4};

// --------------------
// 6. Tipo de elemento
// --------------------
Mesh.ElementOrder = 1; //Q4

// --------------------
// 7. Gerar e salvar
// --------------------
Mesh 2;
Save "Secao_Quadrado_TCC.msh";
//+
Show "*";
