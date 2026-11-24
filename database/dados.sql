-- =====================================================
-- dados.sql — Etapa 2: inserção dos dados
-- Ordem: cliente e mini_indici -> mini_dolar -> item_mini_dolar
-- Os ids NÃO são informados: o AUTO_INCREMENT gera 1, 2, 3...
-- =====================================================

USE `trader`;

-- 5 clientes (ids 1 a 5)
INSERT INTO cliente (nome, email, cidade) VALUES ('Ana Souza',      'ana@mail.com',    'Goiânia');
INSERT INTO cliente (nome, email, cidade) VALUES ('Bruno Lima',     'bruno@mail.com',  'Anápolis');
INSERT INTO cliente (nome, email, cidade) VALUES ('Carla Mendes',   'carla@mail.com',  'Goiânia');
INSERT INTO cliente (nome, email, cidade) VALUES ('Carlos Pereira', 'carlos@mail.com', 'Aparecida de Goiânia');
INSERT INTO cliente (nome, email, cidade) VALUES ('Daniela Rocha',  'daniela@mail.com','Goiânia');

-- 5 registros em mini_indici (ids 1 a 5) — a Webcam é o id 4 e começa com estoque 0
INSERT INTO mini_indici (nome, preco, estoque) VALUES ('Notebook',          3500.00,  3);
INSERT INTO mini_indici (nome, preco, estoque) VALUES ('Mouse',               49.90, 30);
INSERT INTO mini_indici (nome, preco, estoque) VALUES ('Teclado Mecânico',   249.90,  8);
INSERT INTO mini_indici (nome, preco, estoque) VALUES ('Webcam',             189.90,  0);
INSERT INTO mini_indici (nome, preco, estoque) VALUES ('Monitor 24 polegadas', 899.00, 2);

-- 8 registros em mini_dolar (ids 1 a 8) — todos apontam para clientes que existem (1 a 5)
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-10-02', 1);
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-10-05', 2);
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-10-10', 3);
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-10-18', 1);
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-10-25', 4);
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-11-03', 5);
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-11-08', 1);
INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-11-12', 3);

-- 10 itens — nenhum par (mini_dolar_id, mini_indici_id) se repete
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (1, 1, 1, 3500.00);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (1, 2, 2,   49.90);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (2, 3, 1,  249.90);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (3, 5, 1,  899.00);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (4, 2, 1,   49.90);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (4, 4, 1,  189.90);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (5, 1, 1, 3500.00);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (6, 3, 2,  249.90);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (7, 5, 2,  899.00);
INSERT INTO item_mini_dolar (mini_dolar_id, mini_indici_id, quantidade, preco_unitario) VALUES (8, 2, 3,   49.90);

-- Conferência: devem aparecer 5, 5, 8 e 10
SELECT COUNT(*) AS total_clientes FROM cliente;
SELECT COUNT(*) AS total_produtos FROM mini_indici;
SELECT COUNT(*) AS total_pedidos  FROM mini_dolar;
SELECT COUNT(*) AS total_itens    FROM item_mini_dolar;
