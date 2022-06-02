
-- TRIGGERS

/* TRIGGERS são gatilhos adicionados a tabelas para que seja executado de forma automática no pg alguma função
antes ou depois de algum evento. No exemplo abaixo, temos uma function criada com returno do tipo trigger
função esta que insere um log avaliativo em outra tabela após a inserção em uma outra tabale. */

CREATE TABLE log_instrutores (
	id SERIAL PRIMARY KEY,
	informacao VARCHAR(255),
	momento_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Function conectada ao TRIGGER por retorno.
CREATE OR REPLACE FUNCTION cria_instrutor () RETURNS TRIGGER AS $$
	DECLARE
		media_salarial DECIMAL;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		total_instrutores INTEGER DEFAULT 0;
		salario DECIMAL;
		percentual DECIMAL(5, 2);
	BEGIN
		SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;
		IF NEW.salario > media_salarial THEN
			INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média');
		END IF;
		FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> NEW.id LOOP
			total_instrutores := total_instrutores + 1;
			IF NEW.salario > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			END IF;
		END LOOP;
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		INSERT INTO log_instrutores (informacao)
			VALUES (NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

-- Comando de criação do TRIGGER ligado a tabela instrutor.
CREATE TRIGGER cria_log_instrutores AFTER INSERT ON instrutor
	FOR EACH ROW EXECUTE FUNCTION cria_instrutor();

-- Testes
SELECT * FROM instrutor;
SELECT * FROM log_instrutores;
INSERT INTO instrutor (nome, salario) VALUES ('Outra pessoa de novo', 600);
SELECT * FROM instrutor;
SELECT * FROM log_instrutores;

SELECT * FROM instrutor;
SELECT * FROM log_instrutores;
INSERT INTO instrutor (nome, salario) VALUES ('Maria', 700);
SELECT * FROM instrutor;
SELECT * FROM log_instrutores;


-- Função TRIFFER utilizando ASSERT
/* Com a função ASSERT podemos definir uma verificação a função que sendo verdadeira procede a função e quando
falsa gera um erro que impede que a função seja concluída. ASSERT é uma ótima forma de provocar erro dentro
da aplicação afim de evitar processamentos indesejados na mesma. */
CREATE OR REPLACE FUNCTION cria_instrutor () RETURNS TRIGGER AS $$
	DECLARE
		media_salarial DECIMAL;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		total_instrutores INTEGER DEFAULT 0;
		salario DECIMAL;
		percentual DECIMAL(5, 2);
	BEGIN
		SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;
		IF NEW.salario > media_salarial THEN
			INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média');
		END IF;
		FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> NEW.id LOOP
			total_instrutores := total_instrutores + 1;
			IF NEW.salario > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			END IF;
		END LOOP;
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		ASSERT percentual < 100::DECIMAL, 'Instrutores novos não podem receber mais que os antigos';
		INSERT INTO log_instrutores (informacao, teste)
			VALUES (NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

-- Comando de criação do TRIGGER ligado a tabela instrutor.

DROP TRIGGER cria_log_instrutores ON instrutor;
CREATE TRIGGER cria_log_instrutores BEFORE INSERT ON instrutor
	FOR EACH ROW EXECUTE FUNCTION cria_instrutor();

SELECT * FROM instrutor;
SELECT * FROM log_instrutores;

INSERT INTO instrutor (nome, salario) VALUES ('João', 8700);


-- CURSORES

/* Funções podem ser criadas utilizando cursores quando se busca uma eficiência seja na organização do código
ou seja na memória armazenada caso o SELECT por completo seja inserido dentro da função. De modo geral o cursor
funciona da mesma forma que FOR.*/
CREATE OR REPLACE FUNCTION instrutores_internos(id_instrutor INTEGER) RETURNS refcursor AS $$
	DECLARE
		cursor_salarios refcursor;
	BEGIN
		OPEN cursor_salarios FOR SELECT instrutor.salario
  								   FROM instrutor
							   WHERE id <> id_instrutor
							        AND salario > 0;
		RETURN cursor_salarios;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cria_instrutor () RETURNS TRIGGER AS $$
	DECLARE
		media_salarial DECIMAL;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		total_instrutores INTEGER DEFAULT 0;
		salario DECIMAL;
		percentual DECIMAL(5, 2);
		cursor_salarios refcursor;
	BEGIN
		SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;
		IF NEW.salario > media_salarial THEN
			INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média');
		END IF;
		
		SELECT instrutores_internos(NEW.id) INTO cursor_salarios; 
		LOOP
			FETCH cursor_salarios INTO salario;
			EXIT WHEN NOT FOUND;
			total_instrutores := total_instrutores + 1;
			IF NEW.salario > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			END IF;
		END LOOP;
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		ASSERT percentual < 100::DECIMAL, 'Instrutores novos não podem receber mais que os antigos';
		INSERT INTO log_instrutores (informacao, teste)
			VALUES (NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores');
		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

INSERT INTO instrutor (nome, salario) VALUES ('João', 8700);


-- DO

/* O comando DO pode ser utilizado para testar a execução de uma função ou query. Muito utilizado em testes e
quando é necessário fazer uma consulta que não será novamente realizada no código. */

DO $$
	DECLARE
		cursor_salarios refcursor;
		salario DECIMAL;
		total_instrutores INTEGER DEFAULT 0;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		percentual DECIMAL(5,2);
	BEGIN
		SELECT instrutores_internos(6) INTO cursor_salarios; 
		LOOP
			FETCH cursor_salarios INTO salario;
			EXIT WHEN NOT FOUND;
			total_instrutores := total_instrutores + 1;
			IF 600::DECIMAL > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			END IF;
		END LOOP;
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;

		RAISE NOTICE 'Percentual: % %%', percentual;
	END;
$$;




