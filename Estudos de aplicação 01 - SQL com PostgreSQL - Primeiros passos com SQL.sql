-- Primeiros passos SQL com PG

integer
real
serial
numeric

varchar(n)
char(n)
text

boolean

date
time
timestamp

CREATE TABLE aluno(
    id SERIAL,
        nome VARCHAR(255),
        cpf CHAR(11),
        observacao TEXT,
        idade INTEGER,
        dinheiro NUMERIC(10,2),
        altura REAL,
        ativo BOOLEAN,
        data_nascimento DATE,
        hora_aula TIME,
        matriculado_em TIMESTAMP
);

SELECT * FROM aluno;

INSERT INTO aluno (
    nome,
    cpf,
    observacao,
    idade,
    dinheiro,
    altura,
    ativo,
    data_nascimento,
    hora_aula,
    matriculado_em
) VALUES (
    'Diogo',
    '12345678901',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ac dui et nisl vestibulum consequat. Integer vitae magna egestas, finibus libero dapibus, maximus magna. Fusce suscipit mi ut dui vestibulum, non vehicula felis fringilla. Vestibulum eget massa blandit, viverra quam non, convallis libero. Morbi ut nunc ligula. Duis tristique purus augue, nec sodales sem scelerisque dignissim. Sed vel rutrum mi. Nunc accumsan magna quis tempus rhoncus. Duis volutpat nulla a aliquet feugiat. Vestibulum rhoncus mi diam, eu consectetur sapien eleifend in. Donec sed facilisis velit. Duis tempus finibus venenatis. Mauris neque nisl, pulvinar eu volutpat eu, laoreet in massa. Quisque vestibulum eros ac tortor facilisis vulputate. Sed iaculis purus non sem tempus mollis. Curabitur felis lectus, aliquam id nunc ut, congue accumsan tellus.',
    35,
    100.50,
    1.81,
    TRUE,
    '1984-08-27',
    '17:30:00',
    '2020-02-08 12:32:45'
);

SELECT *
    FROM aluno
WHERE id = 1

UPDATE aluno
    SET nome = 'Nico',
    cpf = '10987654321',
    observacao = 'Teste',
    idade = 38,
    dinheiro = 15.23,
    altura = 1.90,
    ativo = FALSE,
    data_nascimento = '1980-01-15',
    hora_aula = '13:00:00',
    matriculado_em = '2020-01-02 15:00:00'
WHERE id = 1;

SELECT *
    FROM aluno 
    WHERE nome = 'Nico';

DELETE
    FROM aluno 
    WHERE nome = 'Nico';

SELECT * 
	FROM aluno;

SELECT nome 
	FROM aluno;

SELECT nome,
	   idade,
	   matriculado_em
 FROM aluno;

SELECT nome,
	   idade,
	   matriculado_em AS quando_se_matriculou
 FROM aluno;

SELECT nome AS "Nome do Aluno",
	   idade,
	   matriculado_em AS quando_se_matriculou
 FROM aluno;

INSERT INTO aluno (nome) VALUES ('Vin??cius Dias');
INSERT INTO aluno (nome) VALUES ('Nico Steppat');
INSERT INTO aluno (nome) VALUES ('Jo??o Roberto');
INSERT INTO aluno (nome) VALUES ('Diego');

-- Filtragem utilizando a igualdade de um dado em um campo da tabela

SELECT * 
	FROM aluno
	WHERE nome = 'Diogo'
	;

-- Filtragem utilizando a diferen??a de um dado em um campo da tabela

SELECT * 
	FROM aluno
	WHERE nome <> 'Diogo'
	;

-- Outra forma de escrever diferente ?? utilizando !=

SELECT * 
	FROM aluno
	WHERE nome != 'Diogo'
	;

-- Utilizando o par??metro LIKE com _ podemos pedir para filtrar qualquer item que atenda os valore determinados
-- considerando para o campo _ qualquer caractere

SELECT * 
	FROM aluno
	WHERE nome LIKE 'Di_go'
	;

-- Com o NOT LIKE temos o reverso do LIKE

SELECT * 
	FROM aluno
	WHERE nome NOT LIKE 'Di_go'
	;

-- Com % junto ao LIKE conseguimos filtrar a partir de um caractere especificado qual dado na tabela que tenha
-- qualquer tipo de caractere antes ou ap??s o %

SELECT * 
	FROM aluno
	WHERE nome LIKE '%s'
	;

SELECT * 
	FROM aluno
	WHERE nome LIKE '% %'
	;

SELECT * 
	FROM aluno
	WHERE nome LIKE '%i%a%'
	;

-- IS e IS NOT NULL servem para filtrar itens que tenham dados nulos ou n??o nulos na tabela

SELECT *
    FROM aluno
 WHERE cpf IS NULL;

SELECT *
    FROM aluno
 WHERE cpf IS NOT NULL;

-- Para dados num??ricos podemos utilizar os comparativos =,>,< e suas combina????es

SELECT *
    FROM aluno
 WHERE idade < 70;

-- Com BETWEEN podemos filtrar dados num??ricos por um range de valores

SELECT *
    FROM aluno
 WHERE idade BETWEEN 10 AND 40;

-- Para booleanos utilizarmos TRUE ou FALSE para filtragem

SELECT * FROM aluno WHERE ativo = true

-- Com AND ou OR filtramos dados com condi????es espec??ficas

SELECT * 
	FROM aluno 
	WHERE nome LIKE 'D%'
	AND cpf IS NOT NULL;

SELECT * 
	FROM aluno 
	WHERE nome LIKE 'D%'
	OR nome LIKE 'Rodrigo'
	OR nome LIKE 'Nico%';

-- Ao criar tabelas utilizando NOT NULL podemos indicar que uma tabela n??o ir?? aceitar campos nulos
-- Utilizando o par??metro UNIQUE indicamos que um campo n??o pode ter valores repetidos na tabela

CREATE TABLE curso (
    id INTEGER NOT NULL UNIQUE,
        nome VARCHAR(255) NOT NULL
);

INSERT INTO curso (id, nome) VALUES (1, 'HTML');
INSERT INTO curso (id, nome) VALUES (2, 'Javascript');

SELECT * FROM curso;

-- O conjunto de par??metros NOT NULL UNIQUE pode ser substitu??do por PRIMARY KEY que possui o mesmo efeito

DROP TABLE curso;
CREATE TABLE curso (
    id INTEGER PRIMARY KEY,
        nome VARCHAR(255) NOT NULL
);

INSERT INTO curso (id, nome) VALUES (1, 'HTML');
INSERT INTO curso (id, nome) VALUES (2, 'Javascript');
INSERT INTO curso (id, nome) VALUES (2, 'Javascript');

SELECT * FROM curso;

-- Avaliando o par??metro FOREIGN KEY

DROP TABLE aluno;

CREATE TABLE aluno (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

INSERT INTO aluno (nome) VALUES ('Diogo');
INSERT INTO aluno (nome) VALUES ('Vin??cius');

SELECT * FROM aluno;
SELECT * FROM curso;

-- Ao criar uma refer??ncia entre campos utilizando FOREIGN KEY evitamos inconsist??ncias no BD devido a
-- relacionamento de informa????es que n??o existem em duas ou mais tabelas diferentes.

CREATE TABLE aluno_curso (
  	    aluno_id INTEGER,
        curso_id INTEGER,
        PRIMARY KEY (aluno_id, curso_id),

		FOREIGN KEY (aluno_id)
        REFERENCES aluno (id),

        FOREIGN KEY (curso_id)
        REFERENCES curso (id)

);

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (1,1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2,1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (3,1);

SELECT * FROM aluno WHERE id = 1;
SELECT * FROM curso WHERE id = 1;

-- Com JOIN unimos dados relacionados entre duas ou mais tabelas

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2,2);

SELECT * FROM aluno;
SELECT * FROM curso;

SELECT aluno.nome as "Nome do Aluno",
       curso.nome as "Nome do Curso"
  FROM aluno
  JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
  JOIN curso       ON curso.id             = aluno_curso.curso_id


INSERT INTO aluno (nome) VALUES ('Nico');
INSERT INTO curso (id, nome) VALUES (3, 'CSS');

-- Com o LEFT e o RIGHT JOIN unimos tabelas independentemente que estas tenham ou n??o dados vinculados
-- neste caso todos os campos de uma tabela ?? exibido, sendo apresentado os que n??o tenham conex??o como nulos

SELECT aluno.nome as "Nome do Aluno",
        curso.nome as "Nome do Curso"
    FROM aluno
	LEFT JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
	LEFT JOIN curso 	  ON curso.id             = aluno_curso.curso_id

SELECT aluno.nome as "Nome do Aluno",
        curso.nome as "Nome do Curso"
    FROM aluno
	RIGHT JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
	RIGHT JOIN curso 	  ON curso.id             = aluno_curso.curso_id

-- Com o FULL JOIN trazemos todos os dados tanto da tabela a 'esquerda' quanto da 'direita' por completo.
-- Os campos n??o tiverem conex??o ser??o apresentados como nulos.

SELECT aluno.nome as "Nome do Aluno",
        curso.nome as "Nome do Curso"
    FROM aluno
	FULL JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
	FULL JOIN curso 	  ON curso.id             = aluno_curso.curso_id

-- CROSS JOIN junta as duas tabelas criando uma conex??o completa entre ambas repetindo cada elemento de uma
-- tabela relacionado a todos os campos da outra

SELECT aluno.nome as "Nome do Aluno",
       curso.nome as "Nome do Curso"
    FROM aluno
	CROSS JOIN curso

INSERT INTO aluno (nome) VALUES ('Jo??o');

SELECT aluno.nome as "Nome do Aluno",
       curso.nome as "Nome do Curso"
    FROM aluno
	CROSS JOIN curso

-- Ao adicionarmos o par??metro ON DELETE CASCADE na cria????o da tabela junto ao FOREIGN KEY permitimos a exclus??o
-- de dados de tabelas prim??rias. Neste caso ter?? um efeito em cascata excluindo todas as rela????es do dado excluindo
-- nos demais JOINS

SELECT * FROM aluno;
SELECT * FROM aluno_curso;
SELECT * FROM curso;

CREATE TABLE aluno_curso (
    aluno_id INTEGER,
    curso_id INTEGER,
    PRIMARY KEY (aluno_id, curso_id),

    FOREIGN KEY (aluno_id)
     REFERENCES aluno (id)
     ON DELETE CASCADE
	,

    FOREIGN KEY (curso_id)
     REFERENCES curso (id)
);

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (1,1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2,1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (3,1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (1,3);

SELECT aluno.nome as "Nome do Aluno",
       curso.nome as "Nome do Curso"
  FROM aluno
  JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
  JOIN curso       ON curso.id             = aluno_curso.curso_id

DELETE FROM aluno WHERE id = 1;

-- O par??metro ON UPDATE CASCADE funciona de forma analoga ao ON DELETE CASCADE

UPDATE aluno
    SET id = 10
    WHERE id = 2;

UPDATE aluno
    SET id = 20
    WHERE id = 4;

DROP TABLE aluno_curso;
CREATE TABLE aluno_curso (
    aluno_id INTEGER,
        curso_id INTEGER,
        PRIMARY KEY (aluno_id, curso_id),

        FOREIGN KEY (aluno_id)
         REFERENCES aluno (id)
         ON DELETE CASCADE
         ON  UPDATE CASCADE
		 ,

        FOREIGN KEY (curso_id)
         REFERENCES curso (id)

);

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2,1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (3,1);

SELECT 
        aluno.id as aluno_id,
        aluno.nome as "Nome do Aluno",
        curso.id as "curso_id",
        curso.nome as "Nome do Curso"
    FROM aluno
    JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
    JOIN curso ON curso.id = aluno_curso.curso_id

UPDATE aluno
    SET id = 10
    WHERE id = 2;


CREATE TABLE funcionarios(
    id SERIAL PRIMARY KEY,
    matricula VARCHAR(10),
    nome VARCHAR(255),
    sobrenome VARCHAR(255)
);


INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES ('M001', 'Diogo', 'Mascarenhas');
INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES ('M002', 'Vin??cius', 'Dias');
INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES ('M003', 'Nico', 'Steppat');
INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES ('M004', 'Jo??o', 'Roberto');
INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES ('M005', 'Diogo', 'Mascarenhas');
INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES ('M006', 'Alberto', 'Martins');
INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES ('M007', 'Diogo', 'Oliveira');

-- Ordenando uma query de forma crescente

SELECT * 
    FROM funcionarios
    ORDER BY nome;

-- Ordenando uma query de forma decrescente

SELECT * 
    FROM funcionarios
    ORDER BY nome DESC;

-- Ordenando por dois campos em sequ??ncia

SELECT * 
    FROM funcionarios
    ORDER BY nome, matricula;

-- Ordenando por dois campos em sequ??ncia e um sendo decrescente

SELECT * 
    FROM funcionarios
    ORDER BY nome, matricula DESC;

-- Uma outra forma de ordenar ?? apenas indicando o n??mero da coluna de refer??ncia

SELECT * 
    FROM funcionarios
    ORDER BY 4;

SELECT * 
    FROM funcionarios
    ORDER BY 3,4,2;

SELECT * 
    FROM funcionarios
    ORDER BY 4 DESC, nome DESC, 2 ASC;

-- Ao fazer JOINs para utilizar o ORDER BY podemos utilizar a sintaxe tabela.campo para ordenar situa????es onde
-- temos o mesmo campo em tabelas diferentes que foram vinculadas na consulta atrav??s de um JOIN

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (20,3);

SELECT 
        aluno.id as aluno_id,
        aluno.nome as "Nome do Aluno",
        curso.id as "curso_id",
        curso.nome as "Nome do Curso"
    FROM aluno
    JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
    JOIN curso ON curso.id = aluno_curso.curso_id
    ORDER BY curso.nome, aluno.nome

-- Utilizando a cl??usula LIMIT podemos limitar a quantidade de registros filtrado na query

SELECT * FROM funcionarios;

SELECT * FROM funcionarios LIMIT 5;

-- O LIMIT pode ser combinado com ORDER BY

SELECT *
  FROM funcionarios
  ORDER BY nome
LIMIT 5;

-- O comando OFFSET serve para pular uma quantidade de registros na query

SELECT *
  FROM funcionarios
  ORDER BY id
 LIMIT 5
OFFSET 1;


-- FUN????ES PRINCIPAIS DE AGREGA????O

-- COUNT - Retorna a quantidade de registros
-- SUM -   Retorna a soma dos registros
-- MAX -   Retorna o maior valor dos registros
-- MIN -   Retorna o menor valor dos registros
-- AVG -   Retorna a m??dia dos registros

SELECT * FROM funcionarios;

SELECT COUNT (id)
  FROM funcionarios;

-- As fun????es de agrega????o podem ser utilizadas junto ao ROUND para arredondar resultados

SELECT COUNT (id),
       SUM(id),
       MAX(id),
       MIN(id),
       ROUND(AVG(id),0)
  FROM funcionarios;


SELECT * FROM funcionarios;

-- DISTINCT ?? uma clausula que permite trazer apenas dados ??nicos em uma consulta considerando uma ou mais colunas

SELECT DISTINCT
        nome
  FROM funcionarios
  ORDER BY nome;

-- Ao setar o DISTINCT para duas ou mais colunas ele remover duplicatas considerando o concatenar das colunas
-- solicitadas na query

SELECT DISTINCT
        nome,
		sobrenome
  FROM funcionarios
  ORDER BY nome;

-- Quanto precisamos trabalhar com fun????es de agrega????o n??o conseguimos utilizar o DISTINCT para isto incluimos
-- o GROUP BY para agrupar os resultados em linhas unicas

SELECT
       nome,
       sobrenome,
       COUNT(*)
  FROM funcionarios
  GROUP BY nome, sobrenome
  ORDER BY nome;

-- O GROUP BY pode ser combinado com JOINs para utilizar agrega????o na consulta de dados

SELECT curso.nome,
        COUNT(aluno.id)
    FROM aluno
    JOIN aluno_curso ON aluno.id = aluno_curso.aluno_id
    JOIN curso ON curso.id = aluno_curso.curso_id
    GROUP BY 1
    ORDER BY 1

SELECT * FROM aluno;
SELECT * FROM aluno_curso;
SELECT * FROM curso;

SELECT *
    FROM curso
    LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
    LEFT JOIN aluno ON aluno.id = aluno_curso.aluno_id;

SELECT curso.nome,
        COUNT(aluno.id)
    FROM curso
    LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
    LEFT JOIN aluno ON aluno.id = aluno_curso.aluno_id
GROUP BY 1

-- Ao utilizarmos fun????es de agrega????o n??o conseguimos criar consultas com condi????es utilizando a clausula
-- WHERE. Nestas circust??ncias podemos utilizar o HAVING que possui o mesmo prop??sito de WHERE, por??m funcionando
-- em queries onde temos agrega????es e agrupamentos.

SELECT curso.nome,
	COUNT(aluno.id)
    FROM curso
    LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
    LEFT JOIN aluno ON aluno.id = aluno_curso.aluno_id
    --WHERE COUNT(aluno.id) = 0
GROUP BY 1
    HAVING COUNT (aluno.id) = 0

SELECT curso.nome,
	COUNT(aluno.id)
    FROM curso
    LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
    LEFT JOIN aluno ON aluno.id = aluno_curso.aluno_id
    --WHERE COUNT(aluno.id) = 0
GROUP BY 1
    HAVING COUNT (aluno.id) > 0

SELECT nome,
       COUNT(id)
    FROM funcionarios
    GROUP BY nome
    HAVING COUNT(id) > 1;

