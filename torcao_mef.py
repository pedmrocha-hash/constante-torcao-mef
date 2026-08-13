import numpy as np #Operações matriciais e vetoriais
import meshio #Interpretação de arquivos de malha .msh
import matplotlib.pyplot as plt #Geração de gráficos e visualização
from scipy.sparse import lil_matrix #Estrutura para matrizes esparsas
from scipy.sparse.linalg import spsolve #Solucionador linear Ku=r
import time  #Biblioteca para medição de tempo
from matplotlib.collections import PolyCollection #Gráfico com Cores nos polígonos dos Elementos
#Parâmetros Físicos e de Entrada
G = 0.1 #Módulo de Elasticidade Transversal em [N/cm^2]
l = 100.0 #Comprimento da barra com seção transversal analisada em [cm]
theta = 0.01 #Ângulo de torção em [rad/cm]
z_ref = 50.0 #Coordenada Z mais próxima do nó travado no método por empenamento
y_ref = 50.0 #Coordenada Y mais próxima do nó travado no método por empenamento
modo = "empenamento" #Alternar entre "empenamento" e "tensao" para definir método de análise
caminho = "malhas/Secao_Quadrado_TCC.msh" #Inserir o diretório aqui
def calcular_geometria_elemento(xl, xi, eta): #Calculo do Jacobiano e da matriz B
    #Diferenças de coordenadas entre os nós do elemento para o Jacobiano
    z13 = xl[0,0]-xl[2,0]
    y24 = xl[1,1]-xl[3,1]
    z24 = xl[1,0]-xl[3,0]
    y13 = xl[0,1]-xl[2,1]
    z34 = xl[2,0]-xl[3,0]
    y12 = xl[0,1]-xl[1,1]
    z12 = xl[0,0]-xl[1,0]
    y34 = xl[2,1]-xl[3,1]
    z23 = xl[1,0]-xl[2,0]
    y14 = xl[0,1]-xl[3,1]
    z14 = xl[0,0]-xl[3,0]
    y23 = xl[1,1]-xl[2,1]
    #Determinante do Jacobiano para mapeamento de área local/global
    detJ = 1/8 * (z13*y24 - z24*y13 + (z34*y12 - z12*y34)*xi + (z23*y14 - z14*y23)*eta)
    #Gradientes das funções de forma bilineares (dN/dz e dN/dy)
    b1 = [y24-y34*xi-y23*eta, -y13+y34*xi+y14*eta, -y24+y12*xi-y14*eta, y13-y12*xi+y23*eta]
    b2 = [-z24+z34*xi+z23*eta, z13-z34*xi-z14*eta, z24-z12*xi+z14*eta, -z13+z12*xi-z23*eta]
    B = (1.0 / (8.0 * detJ)) * np.array([b1, b2])
    return detJ, B #Retorno do detJ e matriz B (normalizada pelo Jacobiano)
def interpolar_coordenadas(xl, xi, eta): #Funções de forma
    #Funções de forma bilineares N1, N2, N3 e N4
    N = 0.25 * np.array([(1-xi)*(1-eta), (1+xi)*(1-eta), (1+xi)*(1+eta), (1-xi)*(1+eta)])
    #Mapeamento para coordenadas físicas globais (z, y)
    return np.dot(N, xl[:, 0]), np.dot(N, xl[:, 1]), N
t_inicio = time.time() #Início da cronometragem do processamento
#Leitura e Verificação de Malha
malha = meshio.read(caminho)
for cell_block in malha.cells: #Inspeciona tipos de elementos
    if cell_block.type not in ["quad", "line"]: #Permite apenas Q4 e linhas de contorno
        raise RuntimeError(f"Elemento '{cell_block.type}' detectado. O código exige quadriláteros.")
nos = malha.points[:, :2]  #Nós
elementos = malha.cells_dict["quad"] #Conectividade
num_nos = nos.shape[0] #Total de nós na malha
num_elementos = len(elementos) #Número total de elementos Q4
K = lil_matrix((num_nos, num_nos))  #Matriz Global
r = np.zeros(num_nos) #Vetor Carga Nodal
pg = [-1/np.sqrt(3), 1/np.sqrt(3)] #Pontos para Integração de Gauss 2x2
#Informações das Malhas
print("-" * 30)
print(f"ANÁLISE DE SEÇÃO: {caminho.split('/')[-1]}")
print(f"Número de Nós: {num_nos}")
print(f"Número de Elementos (Q4): {num_elementos}")
print("-" * 30)
#Montagem Matriz de rigidez e vetor de cargas nodais
for el in elementos:
    ke = np.zeros((4, 4)) #Inicializa matriz rigidez local
    re = np.zeros(4) #Inicializa vetor carga nodal local
    xl = nos[el] #Coordendas nós contidos no elemento
    for i in range(2): #Loop Quadratura de Gauss em xi
        for j in range(2): #Loop Gauss em eta
            xi = pg[i] #Coordenadas de integração
            eta = pg[j] #Coordenadas de integração
            detJ, B = calcular_geometria_elemento(xl, xi, eta) #Geometria local
            zg, yg, N = interpolar_coordenadas(xl, xi, eta) #Interpolação global
            if modo == "empenamento":
                ke += (B.T @ B) * (G * l * theta**2) * detJ #Componente matriz de rigidez elementar por empenamento
                re += (B.T @ np.array([yg, -zg])) * (G * l * theta**2) * detJ #Vetor de carga Nodal elementar por empenamento
            else:
                ke += (B.T @ B) * (1.0/G) * detJ #Componente matriz de rigidez elementar por Função de Tensão
                re += (2 * theta * N) * detJ #Vetor de carga Nodal elementar por Função de Tensão
    for il in range(4): #Posicionamento na Matriz Global
        for jl in range(4):
            K[el[il], el[jl]] += ke[il, jl]
        r[el[il]] += re[il]
#Condições de contorno
if modo == "empenamento":
    #Busca do nó mais próximo das coordenadas de suporte informadas
    dist = np.sqrt((nos[:,0]-z_ref)**2 + (nos[:,1]-y_ref)**2)
    idx = np.argmin(dist) #Índice do nó suporte
    no_trav_plot = nos[idx] #Coordenadas para o X vermelho
    #Imposição (ψ=0)
    K[idx, :] = 0
    K[:, idx] = 0
    K[idx, idx] = 1
    r[idx] = 0
else:
    #Imposição de contorno nulo (F=0) no perímetro da seção
    nos_b = np.unique(malha.cells_dict["line"])
    for n in nos_b:
        K[n, :] = 0
        K[:, n] = 0
        K[n, n] = 1
        r[n] = 0
u = spsolve(K.tocsr(), r) #Solução do sistema linear Ku=r
#Cálculo das Tensões Cisalhantes e do J
M = 0.0 #Inicializa Cálculo do Momento Torçor
tau_elementos = [] #Lista para guardar a tensão de cada elemento
for el in elementos:
    xl = nos[el] #Coordenadas nodais
    sol_e = u[el] #Soluções nodais
    for i in range(2):
        for j in range(2):
            detJg, Bg = calcular_geometria_elemento(xl, pg[i], pg[j])
            zr, yr, Ng = interpolar_coordenadas(xl, pg[i], pg[j])
            deriv = Bg @ sol_e #Cálculo do gradiente da solução
            if modo == "empenamento":
                M += G * theta * (np.dot(deriv, np.array([-yr, zr])) + (yr**2 + zr**2)) * detJg
            else:
                M += 2.0 * np.dot(Ng, sol_e) * detJg
    #Cálculo da Tensão no BARICENTRO para o Gráfico
    detJc, Bc = calcular_geometria_elemento(xl, 0.0, 0.0)
    zc, yc, Nc = interpolar_coordenadas(xl, 0.0, 0.0) #Coords do centro
    deriv_c = Bc @ sol_e
    if modo == "empenamento":
        tau_vec = G * theta * (deriv_c + np.array([-yc, zc]))
    else:
        tau_vec = np.array([deriv_c[1], -deriv_c[0]])
    #Módulo da tensão no centro
    val_tau = np.sqrt(tau_vec[0]**2 + tau_vec[1]**2)
    tau_elementos.append(val_tau)
J_f = abs(M / (G * theta)) #Determinação da inércia torcional J
tau_max = np.max(tau_elementos) #Tensão Máxima na Seção
#Fim da cronometragem do processamento
t_fim = time.time()
tempo_total = t_fim - t_inicio
print(f"Tempo de Processamento: {tempo_total:.4f} segundos")
#Gráficos
fig = plt.figure(figsize=(14, 7))
ax1 = fig.add_subplot(1, 2, 1) #Subplot 2D: Tensões
#Cria os polígonos para o Matplotlib
#'verts' é uma lista onde cada item são as coordenadas/vértices (x,y) dos 4 nós do elemento
verts = [nos[el] for el in elementos]
#Cria a coleção de polígonos
#cmap='jet' define as cores
pc = PolyCollection(verts, cmap='jet', edgecolors='None')
#Define os valores que vão colorir cada polígono
pc.set_array(np.array(tau_elementos))
#Adiciona ao gráfico
ax1.add_collection(pc)
ax1.autoscale() #Ajusta o zoom automaticamente para caber tudo
plt.colorbar(pc, ax=ax1, label='Intensidade |τ| (N/cm²) - Baricentro') #Desenho da malha com Q4
if modo == "empenamento":
    ax1.plot(no_trav_plot[0], no_trav_plot[1], 'rx', markersize=10, mew=2, label='Suporte')
ax1.set_title(f"Mapa de Calor de Tensões | J = {J_f:.4f} cm⁴\n|τ|máx = {tau_max:.4f} N/cm²")
ax1.axis('equal')
ax1.set_xlabel("z (cm)"); ax1.set_ylabel("y (cm)")
#Gráfico 3D
if modo == "empenamento":
    ax2 = fig.add_subplot(1, 2, 2, projection='3d') #Subplot 3D: Empenamento
    for el in elementos:
        zc = nos[el,0]#Dados do elemento
        yc = nos[el,1] #Dados do elemento
        psiv = u[el] #Dados do elemento
        xs = np.array([[zc[0], zc[1]], [zc[3], zc[2]]])
        ys = np.array([[yc[0], yc[1]], [yc[3], yc[2]]])
        zs = np.array([[psiv[0], psiv[1]], [psiv[3], psiv[2]]]) #Coordenadas verticais
        ax2.plot_surface(xs, ys, zs, cmap='coolwarm', edgecolor='k', alpha=0.8) #Superfície
    #Plano Referência e Rótulos com Unidades
    z_m, y_m = np.meshgrid([np.min(nos[:,0]), np.max(nos[:,0])], [np.min(nos[:,1]), np.max(nos[:,1])])
    ax2.plot_surface(z_m, y_m, np.zeros_like(z_m), color='gray', alpha=0.2)
    ax2.set_title("Superfície de Empenamento (ψ)")
    ax2.set_zlabel("ψ (cm²/rd)")
    ax2.set_xlabel("z (cm)")
    ax2.set_ylabel("y (cm)")
    amp = np.max(np.abs(u)) * 1.5 if np.max(np.abs(u)) > 0 else 1.0 #Limite
    ax2.set_zlim(-amp, amp)
    ax2.view_init(elev=20, azim=45) #Viewport 3D
#Resumo do Processamento
info_text = (f"Resumo Técnico:\n"
             f"• Nós: {num_nos}\n"
             f"• Elementos: {num_elementos}\n"
             f"• Tempo: {t_fim - t_inicio:.4f} s")
#Posicionamento da caixa no canto inferior direito da figura
fig.text(0.85, 0.02, info_text, fontsize=10, color='blue',
         bbox=dict(facecolor='white', alpha=0.8, edgecolor='blue', boxstyle='round,pad=0.5'))
plt.tight_layout()
plt.show() #Exibição final
