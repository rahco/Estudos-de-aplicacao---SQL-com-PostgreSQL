-- FUNCTION

-- Com o comando CREATE FUNCTION podemos criar uma função a ser utilizada no bd seja em uma tabela ou como um
-- parâmetro para alimentar algum dado específico na tabela.

-- Na sintaxe definimos o nome da função, o que a mesma irá retornar, seu padrão de cálculo e sua linguagem.
CREATE FUNCTION primeira_funcao() RETURNS INTEGER AS '
	SELECT (5 - 3) * 2
' LANGUAGE SQL;

-- O resultado da uma função pode ser acessado através de um SELECT
SELECT primeira_funcao() AS resultado;

-- Dentro dos () de uma função podemos definir parâmetros a mesma que possam vir de fontes externas tornando
-- a função mais dinâmica.
-- Ao utilizar parâmetros os mesmos devem ser escritos na equação da função e também devem ser informados ao se
-- chamar a função.
CREATE FUNCTION soma_dois_numeros(numero_1 INTEGER, numero_2 INTEGER) RETURNS INTEGER AS '
	SELECT numero_1 + numero_2;
' LANGUAGE SQL;

SELECT soma_dois_numeros(2, 2);

-- Um função pode ser utilizada para inserir dados em uma tabela

CREATE TABLE a (nome VARCHAR(255) NOT NULL);

-- Uma ponto importante é que, caso a função tenha algum retorno, este deve ser expresso na função para exibição
-- do mesmo. No exemplo temos o comando SELECT fazendo esta função.
-- Caso o objetivo da função seja apenas inserir dados na tabelas, no parâmetro RETURNS pode ser preenchido com 
-- VOID, assim não será necessário inserir o SELECT para exibir o retorno da função.
CREATE FUNCTION cria_a(nome VARCHAR) RETURNS VARCHAR AS '
	INSERT INTO a (nome) VALUES(cria_a.nome);
	SELECT nome;
' LANGUAGE SQL;

SELECT cria_a('Vinicius Dias');

-- Exemplo de função inserindo dados na tabela sem retorno
CREATE FUNCTION cria_b(nome VARCHAR) RETURNS VOID AS '
	INSERT INTO a (nome) VALUES(cria_b.nome);
' LANGUAGE SQL;

SELECT cria_b('Raphael Coelho');

SELECT * FROM a;

-- Como dentro de uma função podemos ter a necessidade de passar caracteres sendo valores inclusos na função,
-- uma boa prática é iniciar e terminar o texto descritivo da função com $$. Assim podemos utilizar '' para
-- escrever textos dentro da função.
CREATE FUNCTION cria_c() RETURNS VOID AS $$
	INSERT INTO a (nome) VALUES('Patricia Lima');
$$ LANGUAGE SQL;

SELECT cria_c();

SELECT * FROM a;


-- Parâmetros compostos

CREATE TABLE instrutor (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	salario DECIMAL(10,2)
);

INSERT INTO instrutor (nome, salario) VALUES ('Vinicius Dias', 100);

-- Uma função pode ter parâmetros compostos como por exemplo todos os dados de uma linha por completo
CREATE FUNCTION dobro_do_salario(instrutor) RETURNS DECIMAL AS $$
	SELECT $1.salario * 2 AS dobro;
$$ LANGUAGE SQL;

-- Com essa combinação, podemos utilizar funções que podem iterar sobre todos os dados de uma linha ou conjunto
-- de dados
SELECT nome, dobro_do_salario(instrutor.*) FROM instrutor;

CREATE OR REPLACE FUNCTION cria_instrutor_falso() RETURNS instrutor AS $$
	SELECT 22, 'Nome falso', 200.0;
$$ LANGUAGE SQL;

-- De forma similar, podemos acessar resultados de funções em formatos de valor composto ou de tabela, mesmo que
-- o registro não exista em nenhuma tabela.
SELECT cria_instrutor_falso();
SELECT id, salario FROM cria_instrutor_falso();

INSERT INTO instrutor (nome, salario) VALUES ('Diogo Mascarenhas', 200);
INSERT INTO instrutor (nome, salario) VALUES ('Nico Steppat', 300);
INSERT INTO instrutor (nome, salario) VALUES ('Juliana', 400);
INSERT INTO instrutor (nome, salario) VALUES ('Priscila', 500);

-- Com o comando SETOF após o returns conseguimos utilizar a tabela instrutor como sendo um tipo para trazer
-- todos os itens da tabela que atendam a um critério ou filtro específico determinado dentro de uma função.
CREATE FUNCTION instrutores_bem_pagos(valor_salario DECIMAL) RETURNS SETOF instrutor AS $$
	SELECT * FROM instrutor WHERE salario > valor_salario;
$$ LANGUAGE SQL;

SELECT * FROM instrutores_bem_pagos(300);


-- OUT

-- Outra forma de apresentar o retorno composto de uma função é através do parâmetro OUT dentro da função.
CREATE FUNCTION soma_e_produto (numero_1 INTEGER, numero_2 INTEGER, OUT soma INTEGER, OUT produto INTEGER) AS $$
	SELECT numero_1 + numero_2 AS soma, numero_1 * numero_2 AS produto;
$$ LANGUAGE SQL;
SELECT * FROM soma_e_produto(3,3);

-- Uma forma igual de extrair resultados compostos é criando um tipo a ser utilizado na função.
CREATE TYPE dois_valores AS (soma INTEGER, produto INTEGER);
-- Com o tipo criado e atribuido na função o retorno será uma tabela com valores.
CREATE FUNCTION soma_e_produto_2 (numero_1 INTEGER, numero_2 INTEGER) RETURNS dois_valores AS $$
	SELECT numero_1 + numero_2 AS soma, numero_1 * numero_2 AS produto;
$$ LANGUAGE SQL;
SELECT * FROM soma_e_produto(3,3);


-- PLPGSQL

-- A linguagem plpgsql serve para criar funções mais complexas com variáveis e que possuem retornos específicos

-- Na linha da gunção a plpgsql inicia-se com BEGIN terminando com END e seu retorno deve ser especificado na
-- função sendo com o comando RETURN
CREATE OR REPLACE FUNCTION primeira_pl() RETURNS INTEGER AS $$
	BEGIN
		-- Varios comandos
		RETURN 1;
	END
$$ LANGUAGE plpgsql;

SELECT primeira_pl();


-- Com plpgsql podemos utilizar o campo DECLARE para formalizar variáveis que serão utilizadas durante a função
CREATE OR REPLACE FUNCTION primeira_pl() RETURNS INTEGER AS $$
	DECLARE
		primeira_variavel INTEGER DEFAULT 3;
	BEGIN
		primeira_variavel := primeira_variavel * 2;
		-- Varios comandos
		RETURN primeira_variavel;
	END
$$ LANGUAGE plpgsql;

SELECT primeira_pl();


-- É possível utilizar uma estrutura de bloco para iniciar uma nova declaração de variáveis e funções dentro de
-- uma outra função. Neste caso tendo novamente a declaração de uma variável já existente ela será uma outra 
-- variável e caso o comando DECLARE não seja utilizado, os valores da variável será o último a ser processado.
CREATE OR REPLACE FUNCTION primeira_pl() RETURNS INTEGER AS $$
	DECLARE
		primeira_variavel INTEGER DEFAULT 3;
	BEGIN
		primeira_variavel := primeira_variavel * 2;

		DECLARE
			primeira_variavel INTEGER;
		BEGIN
			primeira_variavel := 7;
		END;

		RETURN primeira_variavel;
	END
$$ LANGUAGE plpgsql;

SELECT primeira_pl();


-- IF-ELSE

-- IF-ELSE é utilizado na função para fazer checagem multiplas de parâmetros em uma função.
-- Um ponto diferencial é que podemos associar como parâmetro uma variável cujo formato já seja um type de tabela,
-- dessa forma temos como resultado a possibilidade de iterar a função em todas as linhas da tabelas com os if-else.
CREATE OR REPLACE FUNCTION salario_ok(instrutor instrutor) RETURNS VARCHAR AS $$
	BEGIN
		-- se o salário do instrutor for maior do que 200, está ok. Senão, pode aumentar
		IF instrutor.salario > 200 THEN
			RETURN 'Salário está ok';
		ELSE
			RETURN 'Salário pode aumentar';
		END IF;
	END;
$$ LANGUAGE plpgsql

SELECT nome, salario_ok(instrutor) FROM instrutor;

-- Com o ELSEIF podemos encortar a verificação de varios parâmetros dentro da função
CREATE OR REPLACE FUNCTION salario_ok(instrutor instrutor) RETURNS VARCHAR AS $$
	BEGIN
		-- se o salário do instrutor for maior do que 300, está ok. Se for 300, pode aumentar, se não salário está defasado
		IF instrutor.salario > 300 THEN
			RETURN 'Salário está ok';
		ELSEIF instrutor.salario = 300 THEN
			RETURN 'Salário pode aumentar';
		ELSE
			RETURN 'Salário está defasado';
		END IF;
	END;
$$ LANGUAGE plpgsql

SELECT nome, salario_ok(instrutor) FROM instrutor;


-- CASE WHEN

/* O CASE WHEN é uma forma de fazer várias verificações sem a necessidade de if e else. Sua sintaxe simplificada
permite adicionar o parâmetro de verificação uma única vez após o CASE e ir adicionando condições de verificação.*/
CREATE OR REPLACE FUNCTION salario_ok(instrutor instrutor) RETURNS VARCHAR AS $$
	BEGIN
		CASE instrutor.salario
			WHEN 100 THEN
				RETURN 'Salário muito baixo';
			WHEN 200 THEN
				RETURN 'Salário baixo';
			WHEN 300 THEN
				RETURN 'Salário ok';
			ELSE
				RETURN 'Salário ótimo';
		END CASE;
	END;
$$ LANGUAGE plpgsql;

SELECT nome, salario_ok(instrutor) FROM instrutor;


-- RETURN NEXT

/* Quanto precisamos montar o resultado de uma função em tabela com SETOF, outro comando além do RETURN QUERY
é o RETURN NEXT, que agrupa o conjunto de resultados em uma tabela.*/
CREATE OR REPLACE FUNCTION tabuada(numero INTEGER) RETURNS SETOF INTEGER AS $$
	DECLARE
	BEGIN
		RETURN NEXT numero * 1;
		RETURN NEXT numero * 2;
		RETURN NEXT numero * 3;
		RETURN NEXT numero * 4;
		RETURN NEXT numero * 5;
		RETURN NEXT numero * 6;
		RETURN NEXT numero * 7;
		RETURN NEXT numero * 8;
		RETURN NEXT numero * 9;		
	END;
$$ LANGUAGE plpgsql;
SELECT tabuada(2);

-- LOOP

/* Com o LOOP podemos criar funções que são executadas em loop até que algum parâmetro seja atingido. Este
recurso é muito útil para evitarmos a repetição de descrição de cálculos em funções.*/
CREATE OR REPLACE FUNCTION tabuada(numero INTEGER) RETURNS SETOF INTEGER AS $$
	DECLARE
		multiplicador INTEGER DEFAULT 1;
	BEGIN
		-- multiplicador que começa com 1, e vai até < 10
		-- numero * multiplicador
		-- multiplicador := multiplicador + 1
		LOOP
			RETURN NEXT numero * multiplicador;
			multiplicador := multiplicador + 1;
			EXIT WHEN multiplicador = 10;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;
SELECT tabuada(2);

/* Com retorno do tipo VARCHAR e || para concatenar dados, podemos criar uma função com resultado completo
da tabuada.*/
CREATE OR REPLACE FUNCTION tabuada_completa(numero INTEGER) RETURNS SETOF VARCHAR AS $$
	DECLARE
		multiplicador INTEGER DEFAULT 1;
	BEGIN
		LOOP
			RETURN NEXT numero || ' x ' || multiplicador || ' = ' || numero * multiplicador;
			multiplicador := multiplicador + 1;
			EXIT WHEN multiplicador = 10;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;
SELECT tabuada_completa(9);

/* Com a condição WHILE, podemos tirar o EXIT WHEN de dentro do LOOP para que o código fique mais curto e de
fácil entendimento.*/
CREATE OR REPLACE FUNCTION tabuada_completa(numero INTEGER) RETURNS SETOF VARCHAR AS $$
	DECLARE
		multiplicador INTEGER DEFAULT 1;
	BEGIN
		WHILE multiplicador < 10 LOOP
			RETURN NEXT numero || ' x ' || multiplicador || ' = ' || numero * multiplicador;
			multiplicador := multiplicador + 1;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;
SELECT tabuada_completa(7);


-- FOR

/* Com o FOR podemos simplificar ainda mais funções, pois no mesmo podemos declarar uma variável, set a mesma
como uma série com o formato x..y e automaticamente o pg irá iterar sobre todos os itens da série fazendo o 
LOOP onde o FOR foi iniciado.*/
CREATE OR REPLACE FUNCTION tabuada_completa(numero INTEGER) RETURNS SETOF VARCHAR AS $$
	BEGIN
		FOR multiplicador IN 1..9 LOOP
			RETURN NEXT numero || ' x ' || multiplicador || ' = ' || numero * multiplicador;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;
SELECT tabuada_completa(5);

/* Com pl podemos utilizar uma function dentro de outra em um select criando uma infinidade de tipos de funções. */
CREATE OR REPLACE FUNCTION instrutor_com_salario(OUT nome VARCHAR, OUT salario_ok VARCHAR) RETURNS SETOF record AS $$
	DECLARE
		instrutor instrutor;
	BEGIN
		FOR instrutor IN SELECT * FROM instrutor LOOP
			nome := instrutor.nome;
			salario_ok = salario_ok(instrutor.id);
			RETURN NEXT;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;
SELECT * FROM instrutor_com_salario();


-- EXEMPLOS DE APLICAÇÃO PLPGSQL

CREATE DATABASE alura;

CREATE TABLE aluno (
	id SERIAL PRIMARY KEY,
	primeiro_nome VARCHAR(255) NOT NULL,
	ultimo_nome VARCHAR(255) NOT NULL,
	data_nascimento DATE NOT NULL
);

CREATE TABLE categoria (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE curso (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	categoria_id INTEGER NOT NULL REFERENCES categoria(id)
);

CREATE TABLE aluno_curso(
	aluno_id INTEGER NOT NULL REFERENCES aluno(id),
	curso_id INTEGER NOT NULL REFERENCES curso(id),
	PRIMARY KEY (aluno_id, curso_id)
);


-- FOUND

/* Combinando os conceitos das funções pl com FOUND podemos criar funções que inserem valores em tabelas avaliando
critérios e parâmetros. */
CREATE FUNCTION cria_curso(nome_curso VARCHAR, nome_categoria VARCHAR) RETURNS void AS $$
	DECLARE
		id_categoria INTEGER;
	BEGIN
		SELECT id INTO id_categoria FROM categoria WHERE nome = nome_categoria;
	
		IF NOT FOUND THEN
			INSERT INTO categoria (nome) VALUES (nome_categoria) RETURNING id INTO id_categoria;
		END IF;
		
		INSERT INTO curso (nome, categoria_id) VALUES (nome_curso, id_categoria);
	END;
$$ LANGUAGE plpgsql;


SELECT cria_curso('PHP', 'Programação');
SELECT * FROM curso;
SELECT * FROM categoria;
SELECT cria_curso('Java', 'Programação');

-- Exemplo de função para inserção de dados em uma tabela seguindo critério prédefinidos em uma função

/* Objetivos
->Inserir instrutores (com salários).
->Se o salário for maior do que a média, salvar um log.
->Salvar outro log dizendo que fulano recebe mais do que x% da grade de instrutores.
*/

CREATE TABLE log_instrutores (
	id SERIAL PRIMARY KEY,
	informacao VARCHAR(255),
	momento_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION cria_instrutor (nome_instrutor VARCHAR, salario_instrutor DECIMAL) RETURNS void AS $$
	DECLARE
		id_instrutor_inserido INTEGER;
		media_salarial DECIMAL;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		total_instrutores INTEGER DEFAULT 0;
		salario DECIMAL;
		percentual DECIMAL;
	BEGIN
		INSERT INTO instrutor (nome, salario) VALUES (nome_instrutor, salario_instrutor) RETURNING id INTO id_instrutor_inserido;
	
		SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> id_instrutor_inserido;
		
		IF salario_instrutor > media_salarial THEN
			INSERT INTO log_instrutores (informacao) VALUES (nome_instrutor || ' recebe acima da média');
		END IF;
		
		FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> id_instrutor_inserido LOOP
			total_instrutores := total_instrutores + 1;
			IF salario_instrutor > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			END IF;
		END LOOP;
		
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		
		INSERT INTO log_instrutores (informacao)
			VALUES (nome_instrutor || ' recebe mais do que ' || percentual || '% da grade de instrutores');

	END;
$$ LANGUAGE plpgsql;

-- Testes
SELECT * FROM instrutor;
SELECT cria_instrutor('Fulada de tal', 1000);
SELECT * FROM log_instrutores;
SELECT cria_instrutor('Outra instrutora', 400);
SELECT * FROM log_instrutores;




