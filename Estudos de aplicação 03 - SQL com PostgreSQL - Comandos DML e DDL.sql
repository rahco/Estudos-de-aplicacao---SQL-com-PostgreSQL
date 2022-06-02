-- Comandos DML e DDL

CREATE DATABASE alura;

-- SCHEMA

-- Com comando CREATE SCHEMA podemos criar novas divisões no bd para separar e organizar tabelas que traram
-- de assuntos diferentes.

CREATE SCHEMA academico;

-- Ao criar tabelas dentro de um schema deve-se referenciar a mesma antes do nome da tabela a ser criada

CREATE TABLE academico.aluno (
    id SERIAL PRIMARY KEY,
	primeiro_nome VARCHAR(255) NOT NULL,
	ultimo_nome VARCHAR(255) NOT NULL,
	data_nascimento DATE NOT NULL
);

CREATE TABLE academico.categoria (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE academico.curso(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    categoria_id INTEGER NOT NULL REFERENCES academico.categoria(id)
);

CREATE TABLE academico.aluno_curso (
	aluno_id INTEGER NOT NULL REFERENCES academico.aluno(id),
	curso_id INTEGER NOT NULL REFERENCES academico.curso(id),
	PRIMARY KEY (aluno_id, curso_id)
);

-- TEMPORARY TABLE: comando para criar uma tabela temporária no bd
-- CHECK: parâmetro para definir restrições aos dados que serão preenchidos na coluna
-- UNIQUE: parâmetro aplicado a concatenação das colunas relacionadas

CREATE TEMPORARY TABLE a (
	coluna1 VARCHAR(255) NOT NULL CHECK(coluna1 <> ''),
	coluna2 VARCHAR(255) NOT NULL,
	UNIQUE (coluna1, coluna2)
);

INSERT INTO a VALUES ('a', 'c');

SELECT * FROM a;

-- ALTER TABLE nome_da_tabela RENAME TO: para alterar o nome de uma tabela sem mecher nos dados contidos nela
ALTER TABLE a RENAME TO teste;
SELECT * FROM teste;
-- Comando pode ser utilizado também para alterar o nome de colunas
ALTER TABLE teste RENAME coluna1 TO primeira_coluna;
ALTER TABLE teste RENAME coluna2 TO segunda_coluna;


-- INSERT SELECT --

CREATE DATABASE alura;

CREATE TABLE aluno (
    id SERIAL PRIMARY KEY,
	primeiro_nome VARCHAR(255) NOT NULL,
	ultimo_nome VARCHAR(255) NOT NULL,
	data_nascimento DATE NOT NULL
);

CREATE TABLE curso(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
    categoria_id INTEGER NOT NULL REFERENCES categoria(id)
);

CREATE TABLE curso (
    id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL
);

CREATE TABLE aluno_curso (
	aluno_id INTEGER NOT NULL REFERENCES aluno(id),
	curso_id INTEGER NOT NULL REFERENCES curso(id),
	PRIMARY KEY (aluno_id, curso_id)
);

INSERT INTO academico.aluno (primeiro_nome, ultimo_nome, data_nascimento) VALUES (
	'Vinicius', 'Dias', '1997-10-15'
), (
	'Patricia', 'Freitas', '1986-10-25'
), (
	'Diogo', 'Oliveira', '1984-08-27'
), (
	'Maria', 'Rosa', '1985-01-01'
);

INSERT INTO academico.categoria (nome) VALUES ('Front-end'), ('Programação'), ('Bancos de dados'), ('Data Science');

INSERT INTO academico.curso (nome, categoria_id) VALUES
	('HTML', 1),
	('CSS', 1),
	('JS', 1),
	('PHP', 2),
	('Java', 2),
	('C++', 2),
	('PostgreSQL', 3),
	('MySQL', 3),
	('Oracle', 3),
	('SQL Server', 3),
	('SQLite', 3),
	('Pandas', 4),
	('Machine Learning', 4),
	('Power BI', 4);
	
INSERT INTO academico.aluno_curso VALUES (1, 4), (1, 11), (2, 1), (2, 2), (3, 4), (3, 3), (4, 4), (4, 6), (4, 5);

SELECT *
    FROM academico.curso
	JOIN academico.categoria ON academico.categoria.id = academico.curso.categoria_id
   WHERE categoria_id = 2;


CREATE TEMPORARY TABLE cursos_programacao(
	id_curso INTEGER PRIMARY KEY,
	nome_curso VARCHAR(255) NOT NULL
);

-- INSERT SELECT
-- Podemos fazer uma inserção em tabela, inserindo uma query direta após o comando INSERT INTO + tabela
-- Esta comando somente funciona se mantermos na tabela e no select o mesmo número de campos e em mesma ordem

INSERT INTO cursos_programacao
SELECT academico.curso.id,
	   academico.curso.nome
    FROM academico.curso
	JOIN academico.categoria ON academico.categoria.id = academico.curso.categoria_id
   WHERE categoria_id = 2;
   
SELECT * FROM cursos_programacao;


-- IMPORTAÇÃO DE DADOS
-- No bd do pg acessando a opção Import/Export com botão direito do mouse sobre uma tabela criada, podemos
-- tanto importar como exportar dados de forma muito simples

CREATE SCHEMA teste;

CREATE TABLE teste.cursos_programacao(
	id_curso INTEGER PRIMARY KEY,
	nome_curso VARCHAR(255) NOT NULL
);

INSERT INTO teste.cursos_programacao
SELECT academico.curso.id,
	   academico.curso.nome
    FROM academico.curso
   WHERE categoria_id = 2;
   
SELECT * FROM teste.cursos_programacao;


-- UPDATE

SELECT * FROM academico.curso ORDER BY 1;

UPDATE academico.curso SET nome = 'PHP Básico' WHERE id = 4;
UPDATE academico.curso SET nome = 'Java Básico' WHERE id = 5;
UPDATE academico.curso SET nome = 'C++ Básico' WHERE id = 6;

SELECT * FROM teste.cursos_programacao;

-- UPDATE pode ser utilizado baseando-se em dados de outra tabela que tenha mesmo campo e id relacionados
-- Dessa forma o update realizado em uma tabela pode ser levado a outras

UPDATE teste.cursos_programacao SET nome_curso = nome
	FROM academico.curso WHERE teste.cursos_programacao.id_curso = academico.curso.id
 AND academico.curso.id < 10;
 
SELECT * FROM teste.cursos_programacao ORDER BY 1;


-- BEGIN (transações)
-- Com o comando BEGIND indicamos um ponto de referência onde iniciamos uma transação no pg
-- Este ponto de transação serve como um marco de onde podemos voltar caso seja necessário recuperar uma ação
-- indevida realizada no código

BEGIN;
DELETE FROM teste.cursos_programacao;
SELECT * FROM teste.cursos_programacao ORDER BY 1;

-- ROLLBACK
-- Com o comando ROLLBACK retornamos o código do pg ao momento onde iniciamos o comando BEGIN

ROLLBACK;
SELECT * FROM teste.cursos_programacao ORDER BY 1;

-- COMMIT
-- Com o comando COMMIT podemos confirmar as ações realizadas após o inicio do BEGIN

BEGIN;
SELECT * FROM teste.cursos_programacao ORDER BY 1;
DELETE FROM teste.cursos_programacao WHERE id_curso = 5;
SELECT * FROM teste.cursos_programacao ORDER BY 1;
COMMIT;
SELECT * FROM teste.cursos_programacao ORDER BY 1;


-- SEQUENCE

-- Com o comando CREATE SEQUENCE podemos criar sequências para uso diversos, como uma aplicação gerar sequências
-- de ids em uma tabela.

CREATE SEQUENCE eu_criei;

-- Utilizando CURRVAL conseguir identificar o valor atual da sequência/serie criada
SELECT CURRVAL('eu_criei');
-- Com o comando NEXTVAL avançamos a sequência para o próximo valor
SELECT NEXTVAL('eu_criei');

-- Após criarmos a sequência atribuimos ela a um campo para que o comando NEXTVAL siga gerando novos ids para o campo
CREATE TEMPORARY TABLE auto (
	id INTEGER PRIMARY KEY DEFAULT NEXTVAL('eu_criei'),
	nome VARCHAR(30) NOT NULL
);

INSERT INTO auto (nome) VALUES ('Vinicius Dias');

SELECT * FROM auto;

-- Um problema comum é que podemos ao utilizar SEQUENCE definir um id específico para um registro em uma tabela
-- desde que este ainda não tenha sido utilizado pela SEQUENCE.
-- Quanto isto ocorre e a SEQUENCE avança até o id criado manualmente o pg da uma mensagem de erro impedindo a
-- criação do registro por já existir o id da sequência.
-- Ao rodar novamente o código, o NEXTVAL irá pular o id e continuará normalmente.

INSERT INTO auto (id,nome) VALUES (2, 'Vinicius Dias');
INSERT INTO auto (nome) VALUES ('Outro nome');

SELECT * FROM auto;


-- TYPE

-- Utilizando CREATE TYPE é possível criar um tipo de formato de dados a ser utilizado ou reutilizado em várias
-- tabelas.

-- Combinando o comando CRETE TYPE com o comando ENUM podemos criar um tipo de dado que serão valores específicos
CREATE TYPE CLASSIFICACAO AS ENUM ('LIVRE', '12_ANOS', '14_ANOS', '16_ANOS', '18_ANOS')

-- Ao utilizar o tipo criado no exemplo acimo no campo da tabelas poderam somente ser preenchidos os dados
-- especificados no comando de criação do tipo CREATE TYPE
CREATE TEMPORARY TABLE filmes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	classificacao CLASSIFICACAO
);

INSERT INTO filmes (nome, classificacao) VALUES ('Um filme qualquer', '18_ANOS');

SELECT * FROM filmes;