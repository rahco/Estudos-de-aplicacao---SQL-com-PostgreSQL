-- Views, sub-consultas e funções

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

-- A criação de campos com chave estrangeira serve para restringirmos para que nenhum dado seja inserido em uma
-- tabela sem que ele já exista em alguma tabela estrangeira de origem, como exemplo uma tabela primária.

CREATE TABLE aluno_curso (
	aluno_id INTEGER NOT NULL REFERENCES aluno(id),
	curso_id INTEGER NOT NULL REFERENCES curso(id),
	PRIMARY KEY (aluno_id, curso_id)
);

INSERT INTO aluno (primeiro_nome, ultimo_nome, data_nascimento) VALUES (
	'Vinicius', 'Dias', '1997-10-15'
), (
	'Patricia', 'Freitas', '1986-10-25'
), (
	'Diogo', 'Oliveira', '1984-08-27'
), (
	'Maria', 'Rosa', '1985-01-01'
);

INSERT INTO categoria (nome) VALUES ('Front-end'), ('Programação'), ('Bancos de dados'), ('Data Science');

INSERT INTO curso (nome, categoria_id) VALUES
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
	
INSERT INTO aluno_curso VALUES (1, 4), (1, 11), (2, 1), (2, 2), (3, 4), (3, 3), (4, 4), (4, 6), (4, 5);

-- Query para buscar a quantidade de cursos por aluno

-- Query inicial
SELECT *
    FROM aluno
    JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
    JOIN curso ON curso.id = aluno_curso.curso_id;

-- Query final
SELECT aluno.primeiro_nome,
       aluno.ultimo_nome,
       COUNT(aluno_curso.curso_id) numero_cursos
    FROM aluno
    JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
GROUP BY 1,2
ORDER BY numero_cursos DESC;

-- Query final limitando o aluno com maior quantidade de cursos
SELECT aluno.primeiro_nome,
       aluno.ultimo_nome,
       COUNT(aluno_curso.curso_id) numero_cursos
    FROM aluno
    JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
GROUP BY 1,2
ORDER BY numero_cursos DESC
LIMIT 1;

-- Query do curso com mais alunos matriculados

-- Query inicial
SELECT *
    FROM curso
    JOIN aluno_curso ON aluno_curso.curso_id = curso.id;

-- Query final
SELECT curso.nome,
       COUNT(aluno_curso.aluno_id) numero_alunos
    FROM curso
    JOIN aluno_curso ON aluno_curso.curso_id = curso.id
GROUP BY 1
ORDER BY numero_alunos DESC;

-- Query final limitando o curso com maior quantidade de alunos
SELECT curso.nome,
       COUNT(aluno_curso.aluno_id) numero_alunos
    FROM curso
    JOIN aluno_curso ON aluno_curso.curso_id = curso.id
GROUP BY 1
ORDER BY numero_alunos DESC
LIMIT 1;

-- --

SELECT * FROM curso;
SELECT * FROM categoria;

-- Query para buscar cursos filtrando duas catergorias
SELECT * FROM curso WHERE categoria_id = 1 OR categoria_id = 2;

-- Utilizando o operador IN podemos criar uma lista a ser utilizada como filtro de igualdade
SELECT * FROM curso WHERE categoria_id IN (1,2);


-- Com o objetivo de criar uma query que busque cursos que tenham categorias cujo nome não possuem espações

-- Iniciamos buscanto a query que filtra essas categorias
SELECT id FROM categoria WHERE nome NOT LIKE ('% %');

-- Utilizando a consulta com o operador IN em outra consulto criamos uma sub-query para atingir o objetivo do filtro
SELECT curso.nome FROM curso WHERE categoria_id IN (
    SELECT id FROM categoria WHERE nome NOT LIKE ('% %')
);


-- Uma query pode ser utilizada como uma uma tabela para outra consulta

-- No exemplo utilizamos a query que gera uma tabela com quantidade de cursos por categoria
SELECT categoria.nome AS categoria,
        COUNT(curso.id) as numero_cursos
    FROM categoria
    JOIN curso ON curso.categoria_id = categoria.id
GROUP BY categoria;

-- Dentro de outra query para filtrar categorias com uma quantidade específica de cursos
SELECT categoria,
       numero_cursos
    FROM (
            SELECT categoria.nome AS categoria,
                COUNT(curso.id) as numero_cursos
            FROM categoria
            JOIN curso ON curso.categoria_id = categoria.id
        GROUP BY categoria
    ) AS categoria_cursos
  WHERE numero_cursos > 3;


-- Views
-- Com o comando CREATE VIEW podemos criar uma visão de uma tabela para utilizada em uma nova consulta
-- O recurso de view é muito utilizado para otimização e segurança para compartilhamento de dados


CREATE VIEW vw_cursos_por_categoria
    AS SELECT categoria.nome AS categoria,
       COUNT(curso.id) as numero_cursos
   FROM categoria
   JOIN curso ON curso.categoria_id = categoria.id
GROUP BY categoria;

SELECT * FROM vw_cursos_por_categoria;

SELECT categoria
    FROM vw_cursos_por_categoria AS categoria_cursos
  WHERE numero_cursos > 3;

CREATE VIEW vw_cursos_programacao AS SELECT nome FROM curso WHERE categoria_id = 2;

SELECT * FROM vw_cursos_programacao;

SELECT categoria.id AS categoria_id, 
	   vw_cursos_por_categoria.*
    FROM vw_cursos_por_categoria
    JOIN categoria ON categoria.nome = vw_cursos_por_categoria.categoria;

-- --

-- Tratamento de strings

SELECT * FROM aluno;

-- Utilizando o parâmetro || conseguimos concatenar strings
SELECT (primeiro_nome || ' ' || ultimo_nome) AS nome_completo FROM aluno;

-- O mesmo resultado de concatenção pode ser obtido com a função CONCAT
SELECT CONCAT (primeiro_nome, ' ',ultimo_nome) FROM aluno;

-- Com a função UPPER tornamos todas as letras em maiúsculas
SELECT UPPER(CONCAT (primeiro_nome, ' ',ultimo_nome)) FROM aluno;

-- A função TRIM apara espaços em branco no início ou fim das palavras
SELECT TRIM(UPPER(CONCAT('Vinicius', NULL, 'Dias') || ' '));


-- Funções com datas

SELECT (primeiro_nome || ultimo_nome) AS nome_completo, data_nascimento FROM aluno;

-- A função NOW() insere a data atual no formato timestamp
SELECT (primeiro_nome || ultimo_nome) AS nome_completo, NOW(), data_nascimento FROM aluno;

-- Com :: podemos converter uma data para o tipo DATE
SELECT (primeiro_nome || ultimo_nome) AS nome_completo, NOW()::DATE, data_nascimento FROM aluno;

-- Com a função completa obtemos a idade
SELECT (primeiro_nome || ultimo_nome) AS nome_completo,
    (NOW()::DATE - data_nascimento)/365 AS idade
  FROM aluno;

-- A função AGE() serve para buscar a quantidade de anos, meses e dias a partir de uma data
SELECT (primeiro_nome || ultimo_nome) AS nome_completo,
    AGE(data_nascimento) AS idade
  FROM aluno;

-- Com EXTRACT() podemos extrair uma informação específica de uma data
SELECT (primeiro_nome || ultimo_nome) AS nome_completo,
    EXTRACT(YEAR FROM AGE(data_nascimento)) AS idade
  FROM aluno;


-- Funções de conversão

SELECT NOW();

-- Com a função TO_CHAR é possível converter um dado a diversas formas passando seus parâmetros
SELECT TO_CHAR(NOW(), 'DD');
SELECT TO_CHAR(NOW(), 'DD/MM/YYYY');
SELECT TO_CHAR(NOW(), 'DD, MONTH, YYYY');
SELECT TO_CHAR(128.3::REAL,'9999D99');

