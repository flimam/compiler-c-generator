algoritmo TESTE

funcao calculaMedia
	entrada vetor, tamanho
	saida media
	declare temp: REAL;
	
	temp = 0
	para i = 1 ate tamanho passo 1 faca
		temp = temp + vetor[i]
	fim_para
	media = temp / tamanho
	
fim_funcao

inicio
	// teste de comentário
	declare i, quant: INTEIRO;
	declare notas[1..100]: REAL;
	declare media: REAL;
	
	escreva "Entre com a quantidade de notas (max 100):"
	leia quant
	
	se (quant >= 1 && quant <= 100) entao
		para i = 1 ate quant passo 1 faca
			leia notas[i]
		fim_para
	
		media = calculaMedia(notas, quant)
		
		se (media >= 6) entao
			escreva "ALUNO APROVADO!"
		senao
			escreva "ALUNO REPROVADO!"
		fim_se
	fim_se
	tchau = 1
fim_algoritmo
