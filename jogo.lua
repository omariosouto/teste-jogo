-- title: A lenda de malena
-- author: Mario Souto
-- desc:   RPG 2d
-- script: lua

Constantes = {
	LARGURA_DA_TELA = 240,
	ALTURA_DA_TELA =138,
	SPRITE_JOGADOR = 260,
	SPRITE_INIMIGO = 292,
	SPRITE_ESPADA = 430,
 JOGADOR = 'Jogador',
 INIMIGO = 'Inimigo',
 CHAVE = 'Chave',
 DIRECAO = {
     CIMA = 1,
     BAIXO = 2,
     ESQUERDA = 3,
     DIREITA = 4
 }
}

TIPO_JOGADOR = Constantes.JOGADOR
TIPO_INIMIGO = Constantes.INIMIGO

-----------------------
-- Mapa
-----------------------
mapa = {
	x = 0,
	y = 0,	
}

camera = {
    x = 0,
    y = 0,
}

function mapa.desenha()
    camera.x = (jogador.x // 240) * 240
    camera.y = (jogador.y // 136) * 136
    
    local blocoX = camera.x / 8
    local blocoY = camera.y / 8
    
    map(
		blocoX, --posicao x do mapa
		blocoY, --posicao y do mapa
		Constantes.LARGURA_DA_TELA, -- quanto desenhar em x
		Constantes.ALTURA_DA_TELA, -- quanto desenhar em y
		0, -- ???
        0) -- ???
        
    print(jogador.x)
    print(jogador.y, 0, 16)
end	
-----------------------
-----------------------

-----------------------
-- Jogador
-----------------------

function criaJogador()
    local jogador = {
     tipo = Constantes.JOGADOR,
     quadroDeAnimacao = 1,
     sprite = Constantes.SPRITE_JOGADOR,
     corDeFundo = 6,
     x = posicaoNoMapa(21),
     y = posicaoNoMapa(11),
     chaves = 0,
    }
				
    function jogador.desenha ()
      sprite(
         jogador.sprite,
         jogador.x,
         jogador.y, 
         jogador.corDeFundo, -- cor de fundo
         1, -- escala
         0, -- espelhar
         0, -- rotacionar
         2, -- blocos para direita
         2) -- blocos para baixo
    end

    function jogador.checaMovimento()
        AnimacaoJogador = {
        {256, 258},
        {260, 262},
        {264, 266},
        {268, 270}
        }
        
        Direcao = {
            {0, -1},
            {0, 1},
            {-1, 0},
            {1, 0}
        }
                    
        for tecla = 0,3 do
            if btn(tecla) then
            local quadros = AnimacaoJogador[tecla + 1]
            local quadro = math.floor(jogador.quadroDeAnimacao)
            jogador.sprite = quadros[quadro]
												local delta = {
													deltaX = Direcao[tecla+1][1],
													deltaY = Direcao[tecla+1][2],
												}
            tentaMoverPara(jogador, delta)		
            end
        end

        verificaColisaoComObjetos(jogador, { x = jogador.x, y = jogador.y })
    end



    return jogador
end
----------

-----------------------
-- Objetos
-----------------------

objetos = {}
function desenhaObjetos()
    for indice, objeto in pairs(objetos) do
        sprite(
         objeto.sprite,
         objeto.x,
         objeto.y, 
         objeto.corDeFundo,
         1,
         0,
         0,
         2,
         2)
    end
end


function criaChave(linha, coluna)      
	local colisoes = {}
 colisoes[Constantes.JOGADOR] = fazColisaoDoJogadorComAChave
 colisoes[Constantes.INIMIGO] = deixaPassar
  
	local chave = {
  tipo = Constantes.CHAVE,
  sprite = 364,
  x = posicaoNoMapa(coluna),
  y = posicaoNoMapa(linha),
  corDeFundo = 6,
		colisoes = colisoes
 }
 
	return chave
end

function fazColisaoDoJogadorComAChave(indice)
    table.remove(objetos, indice)
				jogador.chaves = jogador.chaves + 1
	return true
end


function criaInimigo(linha, coluna)      
 local colisoes = {}
 colisoes[Constantes.JOGADOR] = fazColisaoDoJogadorComOInimigo
 colisoes[Constantes.INIMIGO] = deixaPassar

	local inimigo = {
		tipo = Constantes.INIMIGO,
		sprite = Constantes.SPRITE_INIMIGO,
		x = posicaoNoMapa(coluna),
  y = posicaoNoMapa(linha),
  corDeFundo = 14,
  quadroDeAnimacao = 1,
  colisoes = colisoes,
	}
 
	return inimigo
end
function fazColisaoDoJogadorComOInimigo(indice)
	inicializa()
	return true
end

function 	atualizaInimigo(inimigo) 
    local VELOCIDADE_INIMIGO = 0.5
    local delta = {
        deltaX = 0,
        deltaY = 0
    }

	if jogador.y > inimigo.y then
        inimigo.direcao = Constantes.DIRECAO.BAIXO
        delta.deltaY = VELOCIDADE_INIMIGO
	elseif jogador.y < inimigo.y then
        inimigo.direcao = Constantes.DIRECAO.CIMA
        delta.deltaY = -VELOCIDADE_INIMIGO
    end

    tentaMoverPara(inimigo, delta)
    delta = {
        deltaX = 0,
        deltaY = 0
    }
	if jogador.x > inimigo.x then
        inimigo.direcao = Constantes.DIRECAO.DIREITA
        delta.deltaX = VELOCIDADE_INIMIGO
	elseif jogador.x < inimigo.x then
        inimigo.direcao = Constantes.DIRECAO.ESQUERDA
        delta.deltaX = -VELOCIDADE_INIMIGO
    end
    
    tentaMoverPara(inimigo, delta)
	
	local AnimacaoInimigo = {
		{288, 290},
		{292, 294},
		{296, 298},
		{300, 302},
	}
	
	local quadros = AnimacaoInimigo[inimigo.direcao]
	local quadro = math.floor(inimigo.quadroDeAnimacao)
	inimigo.sprite = quadros[quadro]
end

-----------------------
-----------------------


-----------------------
-- Utilitários de Sprite/Sons
-----------------------

function posicaoNoMapa(posicao)
    return posicao * 8 + 8
end

function sprite(numeroSprite, mapX, mapY, bg, escala, espelhar, rotacionar, blocosDireita, blocosEsquerda) 
   spr(
      numeroSprite,
      mapX - 8 - camera.x,
      mapY - 8 - camera.y, 
      bg, -- cor de fundo
      1, -- escala
      0, -- espelhar
      0, -- rotacionar
      2, -- blocos para direita
      2) -- blocos para baixo
end

-----------------------
-----------------------

-----------------------
-- Funcoes de colisao
-----------------------
-- REFATORAR: ELIMINAR DEPENDENCIA DO JOGADOR
function deixaPassar()
 return false
end

function tentaMoverPara(personagem, delta)

	local meuDeslocamentoX = delta.deltaX
	local meuDeslocamentoY = delta.deltaY
	
	local novaPosicao = {
		x = personagem.x + delta.deltaX,
		y = personagem.y + delta.deltaY,
	}
	
	if verificaColisaoComObjetos(personagem, novaPosicao) then
		return false 
	end
	
	 
	-- cantos do sprite
	local superiorEsquerdo = {
      x = personagem.x - 8 + meuDeslocamentoX,
      y = personagem.y - 8 + meuDeslocamentoY
   }
 local superiorDireito = {
      x = personagem.x + 7 + meuDeslocamentoX,
      y = personagem.y - 8 + meuDeslocamentoY
   }
   
	local inferiorDireito = {
      x = personagem.x + 7 + meuDeslocamentoX,
      y = personagem.y + 7 + meuDeslocamentoY
   }
			
 local inferiorEsquerdo = {
      x = personagem.x - 8 + meuDeslocamentoX,
      y = personagem.y + 7 + meuDeslocamentoY
   }

   if temColisaoComMapa(inferiorDireito) or
      temColisaoComMapa(inferiorEsquerdo) or
      temColisaoComMapa(superiorDireito) or    
      temColisaoComMapa(superiorEsquerdo) then
      -- tem colisao
   else
      -- sem colisao			   
      personagem.quadroDeAnimacao = personagem.quadroDeAnimacao + 0.1
      
      if personagem.quadroDeAnimacao >= 3 then 
         personagem.quadroDeAnimacao = 1
      end
      
      personagem.y = personagem.y + meuDeslocamentoY
						personagem.x = personagem.x + meuDeslocamentoX
				end
end 

function temColisaoComMapa(ponto)
    blocoX = ponto.x / 8
    blocoY = ponto.y /8
    blocoId = mget(blocoX, blocoY)
    if blocoId >= 128 then
       return true
    else 
       return false
    end
 end

function temColisao(objetoA, objetoB)

    local direitaDeA = objetoA.x + 7
    local esquerdaDeA = objetoA.x - 8
    local baixoDeA = objetoA.y +7
    local cimaDeA = objetoA.y - 8

    local esquerdaDeB = objetoB.x - 8
    local direitaDeB = objetoB.x + 7
    local baixoDeB = objetoB.y + 7
    local cimaDeB = objetoB.y - 8


    if esquerdaDeB > direitaDeA or
        direitaDeB < esquerdaDeA or
        baixoDeA < cimaDeB or
        cimaDeA > baixoDeB then
        return false
    end
    return true
end

function verificaColisaoComObjetos(personagem, novaPosicao)
	for indice, objeto in pairs(objetos) do
  if temColisao(novaPosicao, objeto) then			
    local funcaoDeColisao = objeto.colisoes[personagem.tipo]
    return funcaoDeColisao(indice)
		end
	end
	return false
end

-----------------------
-----------------------

-----------------------
-- Funcoes Core do Jogo
-----------------------

function atualiza()
   jogador.checaMovimento()
			
							
			for indice, objeto in pairs(objetos) do
				if objeto.tipo == Constantes.INIMIGO then
					atualizaInimigo(objeto)
				end
			end
end

function desenha()
   cls()
   mapa.desenha()
   jogador.desenha()
   desenhaObjetos()
--    print("Chaves: " .. jogador.chaves)
end

function inicializa()
   objetos = {}
  	local chave = criaChave(7,5)
   table.insert(objetos, chave)

   local inimigo = criaInimigo(9,9)
   table.insert(objetos, inimigo)

   jogador = criaJogador()
end

function TIC()
   atualiza()
   desenha()
end

inicializa()      