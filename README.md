# Constante de Torção (J) pelo Método dos Elementos Finitos

Rotina em Python para o cálculo da **constante de torção (J)** e das **tensões de
cisalhamento por torção uniforme** em seções transversais de geometria arbitrária,
discretizadas por elementos finitos quadriláteros de quatro nós (Q4).

Este repositório contém o código apresentado no **ANEXO A** do Trabalho de Conclusão
de Curso:

> **ROCHA, Pedro Moreira.** *Avaliação da constante de torção aplicada em longarinas
> de pontes e viadutos.* 2026. Trabalho de Conclusão de Curso (Engenharia Civil) –
> Escola de Engenharia, Universidade Federal do Rio Grande do Sul, Porto Alegre, 2026.
>
> Orientador: Prof. Inácio Benvegnu Morsch.

---

## Motivação

A modelagem de tabuleiros de pontes e viadutos exige a avaliação da rigidez à torção
das longarinas. As soluções analíticas clássicas cobrem apenas geometrias simples e
não se aplicam às seções reais de obras de arte especiais — perfis "I" com mísulas,
seções alargadas de apoio e caixões celulares. Este código resolve o problema
numericamente para qualquer geometria que se consiga discretizar.

---

## As duas formulações

O código implementa **duas abordagens** para o mesmo problema, selecionadas pela
variável `modo`. Elas se diferenciam pela variável nodal adotada:

| `modo` | Variável nodal | Condição de contorno | Aplicabilidade |
|---|---|---|---|
| `"empenamento"` | Função de empenamento **ψ** | Um único nó travado (ψ = 0) | **Seções abertas e fechadas** |
| `"tensao"` | Função de tensão de Prandtl **F** | F = 0 em todo o perímetro | **Somente seções abertas** |

> ### ⚠️ Atenção — seções celulares (vazadas)
>
> Para seções **fechadas** (caixões celulares, seções com vazios internos) use
> **exclusivamente** `modo = "empenamento"`.
>
> A formulação por Função de Tensão pressupõe F = 0 no contorno, mas em seções
> vazadas a função **não é nula nos perímetros internos** — o valor em cada borda
> de vazio é uma incógnita adicional que exige condições de contorno suplementares
> não implementadas aqui (cf. Jog e Mokashi, 2014). Aplicá-la a um caixão produz
> um **J fortemente subestimado**, sem qualquer aviso de erro.
>
> A formulação por empenamento lida naturalmente com vazios internos.

Em seções abertas as duas formulações convergem para o mesmo resultado, e a
comparação entre elas é uma boa verificação da malha. Na validação do trabalho, a
formulação por empenamento apresentou convergência consistentemente mais rápida.

---

## Instalação

Requer Python 3.9 ou superior.

```bash
pip install -r requirements.txt
```

Dependências: `numpy`, `scipy`, `matplotlib`, `meshio`.

---

## Como usar

Abra `torcao_mef.py` e ajuste o bloco de parâmetros no topo do arquivo:

```python
G = 0.1                  # Módulo de elasticidade transversal [N/cm²]
l = 100.0                # Comprimento da barra [cm]
theta = 0.01             # Ângulo de torção por unidade de comprimento [rad/cm]
z_ref = 50.0             # Coordenada z do nó a ser travado (modo empenamento)
y_ref = 50.0             # Coordenada y do nó a ser travado (modo empenamento)
modo = "empenamento"     # "empenamento" ou "tensao"
caminho = "malhas/Secao_Quadrado_TCC.msh"   # Malha a ser analisada
```

Depois execute:

```bash
python torcao_mef.py
```

O terminal exibe o número de nós, o número de elementos e o tempo de processamento.
Uma janela gráfica é aberta com:

- **Mapa de calor** das tensões cisalhantes |τ| avaliadas no baricentro de cada
  elemento, com o valor de **J** e de **τ<sub>máx</sub>** no título;
- **Superfície 3D do empenamento (ψ)** — apenas no `modo = "empenamento"`.

### Notas sobre os parâmetros

- **`J` não depende de `G`, `l` nem `theta`.** A constante de torção é uma
  propriedade puramente geométrica: o código a obtém por `J = |M / (G·θ)|`, e os
  valores adotados se cancelam. Já as **tensões** são proporcionais a `G·θ` e devem
  ser calculadas com os valores reais do problema.
- **`z_ref` / `y_ref`** definem apenas a referência de empenamento nulo (marcada com
  um "×" vermelho no gráfico). O código trava o nó **mais próximo** dessas
  coordenadas. Como a solução é definida a menos de uma constante, a escolha do nó
  **não altera J nem as tensões** — muda apenas o nível da superfície ψ. Escolha um
  ponto dentro da seção para uma visualização coerente.
- **As unidades são as da malha.** Todas as malhas deste repositório estão em
  **centímetros**, portanto J sai em cm⁴.

---

## Preparação da malha

As malhas são geradas no [Gmsh](https://gmsh.info/) e lidas via `meshio`
(formato `.msh`). O código impõe três exigências:

1. **Somente elementos Q4.** A malha não pode conter triângulos — o código verifica
   os tipos presentes e interrompe a execução com `RuntimeError` se encontrar
   qualquer elemento que não seja `quad` ou `line`. No Gmsh isso se obtém com
   `Recombine Surface`, e para geometrias irregulares também
   `Mesh.SubdivisionAlgorithm = 1`, que força 100 % de quadriláteros.
2. **Elementos de linha no contorno**, necessários no `modo = "tensao"` para impor
   F = 0 no perímetro. Declare-os com `Physical Curve`.
3. **Geometria plana no plano z–y**, lida das duas primeiras colunas de coordenadas.

Trecho típico de um `.geo`:

```
Mesh.Algorithm = 6;               // Frontal-Delaunay
Mesh.SubdivisionAlgorithm = 1;    // Força 100% quadriláteros (Q4)
Recombine Surface {1};

Physical Surface("quad") = {1};
Physical Curve("line") = {1:24};

Mesh 2;
Save "minha_secao.msh";
```

Os nomes dos grupos físicos são livres: o código identifica os elementos pelo **tipo**
(`quad`, `line`), não pelo nome do grupo.

---

## Estrutura do repositório

```
torcao_mef.py           Rotina de cálculo (ANEXO A do TCC)
requirements.txt        Dependências
malhas/                 Malhas .msh prontas para uso
geometrias/             Arquivos-fonte .geo do Gmsh que geram as malhas
```

| Seção | `.geo` | `.msh` |
|---|---|---|
| Quadrada (validação) | `Quadrado_TCC.geo` | `Secao_Quadrado_TCC.msh` |
| Seção 1 — vão da longarina | `Secao_no_Vao.geo` | `viga_vao.msh` |
| Seção 2 — apoio da longarina | `Secao_no_Apoio.geo` | `viga_apoio.msh` |
| Seção A — caixão celular | `Secao_Caixao_A.geo` | `Caixao-A.msh` |
| Seção B — caixão celular reforçado | `Secao_Caixao_B.geo` | `Caixao-B.msh` |

---

## Validação

Barra prismática de seção quadrada com lado 2a = 100 cm. A solução analítica de
Timoshenko e Goodier (1970) para a seção quadrada é
J = 0,1406 · (2a)⁴ = **14 060 000 cm⁴**.

O arquivo `Quadrado_TCC.geo` usa uma malha transfinita controlada pelos parâmetros
`nx` e `ny`. A malha incluída no repositório é a mais grosseira (**3 × 3**), útil
para um teste rápido de instalação; para reproduzir o estudo de convergência do
trabalho, altere `nx` e `ny` no `.geo` e gere novamente a malha no Gmsh.

Resultados com a malha 3 × 3 incluída:

| Formulação | J (cm⁴) | Erro vs. analítico |
|---|---:|---:|
| Empenamento | 15 319 865 | +8,96 % |
| Função de Tensão | 11 851 852 | −15,71 % |

O erro cai rapidamente com o refinamento. No trabalho, elementos de 2 cm já
produzem erro inferior a 5 % em J; a determinação precisa de τ<sub>máx</sub> exige
refinamento maior, por ser uma grandeza derivada do campo de deslocamentos.

---

## Resultados de referência

Valores obtidos com as malhas **deste repositório**, para conferência de que a
instalação está correta. Não substituem as tabelas de convergência do trabalho, que
utilizaram malhas mais refinadas.

| Malha | Elementos | Formulação | J (cm⁴) |
|---|---:|---|---:|
| `viga_vao.msh` | 692 | Empenamento | 2 755 645 |
| `viga_vao.msh` | 692 | Função de Tensão | 2 666 053 |
| `viga_apoio.msh` | 908 | Empenamento | 12 101 173 |
| `viga_apoio.msh` | 908 | Função de Tensão | 11 974 059 |
| `Caixao-A.msh` | 16 736 | Empenamento | 1 904 089 792 |
| `Caixao-B.msh` | 31 740 | Empenamento | 10 841 079 574 |

Nas seções abertas (1 e 2) as duas formulações concordam, como esperado. Nas seções
caixão apenas a formulação por empenamento é válida — a razão J<sub>B</sub>/J<sub>A</sub> ≈ **5,7**
quantifica o ganho de rigidez à torção obtido com o aumento da altura das almas e das
espessuras da seção B.

---

## Referências

- JOG, C. S.; MOKASHI, I. S. A finite element method for the Saint-Venant torsion
  and bending problems for prismatic beams. *Computers & Structures*, 2014.
- TIMOSHENKO, S. P.; GOODIER, J. N. *Theory of Elasticity*. 3. ed. New York:
  McGraw-Hill, 1970.
- TRAN, Dang-Bao. Torsional shear stress with arbitrary cross-sections in homogeneous
  isotropic elastic material using finite element method. *Civil Engineering Journal*,
  v. 2, art. 30, p. 409–420, 2021. DOI: 10.14311/CEJ.2021.02.0030.
- GEUZAINE, C.; REMACLE, J.-F. Gmsh: a three-dimensional finite element mesh generator
  with built-in pre- and post-processing facilities. *International Journal for
  Numerical Methods in Engineering*, v. 79, n. 11, p. 1309–1331, 2009.
- VIRTANEN, P. et al. SciPy 1.0: Fundamental Algorithms for Scientific Computing in
  Python. *Nature Methods*, v. 17, p. 261–272, 2020.

---

## Licença

Distribuído sob a licença MIT — veja o arquivo [LICENSE](LICENSE).
