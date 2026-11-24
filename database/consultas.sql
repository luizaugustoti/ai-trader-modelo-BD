-- =====================================================
-- consultas.sql — Etapas 3, 4 e 5
-- =====================================================

USE `trader`;

-- ---------------- Etapa 3: consultas com SELECT ----------------

-- 1. Produtos com preço maior que 100, do mais caro para o mais barato
SELECT id, nome, preco FROM mini_indici
WHERE preco > 100
ORDER BY preco DESC;

-- 2. Clientes cujo nome começa com a letra C
SELECT id, nome, email FROM cliente
WHERE nome LIKE 'C%';

-- 3. Os 3 pedidos mais recentes (id, data e cliente)
SELECT id, data, cliente_id FROM mini_dolar
ORDER BY data DESC
LIMIT 3;

-- 4. Clientes de Goiânia, em ordem alfabética de nome
SELECT id, nome, cidade FROM cliente
WHERE cidade = 'Goiânia'
ORDER BY nome;

-- 5. Produtos sem estoque
SELECT id, nome, estoque FROM mini_indici
WHERE estoque = 0;

-- 6. Pedidos do cliente de id 1, do mais antigo para o mais recente
SELECT id, data, cliente_id FROM mini_dolar
WHERE cliente_id = 1
ORDER BY data ASC;

-- 7. Itens do pedido 1 (id do produto e quantidade)
SELECT mini_indici_id, quantidade FROM item_mini_dolar
WHERE mini_dolar_id = 1;

-- 8. Produtos com estoque menor que 5
SELECT id, nome, estoque FROM mini_indici
WHERE estoque < 5;


-- ---------------- Etapa 4: alterar e apagar com segurança ----------------

-- Aumentar em 5 o estoque da Webcam (id 4): SELECT antes, UPDATE, SELECT depois
SELECT id, nome, estoque FROM mini_indici WHERE id = 4;   -- antes: 0
UPDATE mini_indici SET estoque = estoque + 5 WHERE id = 4;
SELECT id, nome, estoque FROM mini_indici WHERE id = 4;   -- depois: 5

-- Tentar apagar o cliente de id 2 (vai FALHAR com o erro 1451 — de propósito)
-- DELETE FROM cliente WHERE id = 2;


-- ---------------- Etapa 5: testar a integridade ----------------
-- Os comandos abaixo DEVEM falhar. Estão comentados para o arquivo rodar inteiro;
-- tire o "-- " da frente e rode um de cada vez para ver o erro.

-- Erro 1452: cliente 6 não existe
-- INSERT INTO mini_dolar (data, cliente_id) VALUES ('2026-11-15', 6);

-- Erro 1062: e-mail ana@mail.com já existe
-- INSERT INTO cliente (nome, email, cidade) VALUES ('Teste', 'ana@mail.com', 'Goiânia');
