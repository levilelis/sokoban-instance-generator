------------------------------------------------ LocalSearch -------------------------------------------------------------------------
				Alterado por Dâmaris Bento - 03.11.2018
--------------------------------------------------------------------------------------------------------------------------------------
 => LocalSearch é um sistema que gera estados iniciais para instâncias do domínio de Sokoban utilizando heurísticas que são combinações 
de número e ordem de conflitos, novelty e múltiplos PDB randomizados para tornar estes estados iniciais mais difíceis de serem 
solucionados.

Esta versão contém as seguintes características:

- Algoritmo GBFS que faz busca reversa;

- Heurísticas disponíveis: 
	-mm, pdb1, pdb2, pdb3r, pdb4r, pdb2_oc2, pdb3r_oc3r, pdb4r_oc4r, oc2_pdb2, oc3r_pdb3r, oc4r_pdb4r, wpdb1_pdb1, wpdb2_pdb2, 
	wpdb3r_pdb3r, wpdb4r_pdb4r, wpdb2_pdb2_oc2, wpdb3r_pdb3r_oc3r, wpdb4r_pdb4r_oc4r, wpdb2_oc2_pdb2, wpdb3r_oc3r_pdb3r, 
	wpdb4r_oc4r_pdb4r;

* Novelty marca um estado como novo se existe uma variável com valor novo no estado expandido, mas continuamos verificando e marcando 
as outras variáveis do estado na tabela de novelty.

* PDB usa o conceito de k partições randomizadas com uma partição sequencial. Ou seja, primeiro roda uma partição sequencial e depois
escolhemos um conjunto de partições randomizadas cada vez que computamos o valor do PDB para um estado.


--------------------------------------------------------------------------------------------------------------------------------------
