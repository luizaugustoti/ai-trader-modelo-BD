# Respostas — Banco `trader` (Etapas 3, 4 e 5)

Correspondência com o roteiro: `produto` = `mini_indici`, `pedido` = `mini_dolar`, `item_pedido` = `item_mini_dolar`.

## Etapa 3 — resultado esperado de cada consulta

| # | Consulta | Resultado esperado |
|---|----------|--------------------|
| 1 | Preço > 100, do mais caro ao mais barato | Notebook (3500,00), Monitor 24 polegadas (899,00), Teclado Mecânico (249,90), Webcam (189,90) |
| 2 | Nome começa com C | Carla Mendes, Carlos Pereira |
| 3 | 3 pedidos mais recentes | Pedido 8 (12/11, cliente 3), Pedido 7 (08/11, cliente 1), Pedido 6 (03/11, cliente 5) |
| 4 | Clientes de Goiânia, A–Z | Ana Souza, Carla Mendes, Daniela Rocha |
| 5 | Produtos sem estoque | Webcam (estoque 0) |
| 6 | Pedidos do cliente 1, do mais antigo ao mais recente | Pedidos 1 (02/10), 4 (18/10) e 7 (08/11) |
| 7 | Itens do pedido 1 | Produto 1 (qtd 1), Produto 2 (qtd 2) |
| 8 | Estoque < 5 | Notebook (3), Webcam (0), Monitor 24 polegadas (2) |

Obs.: as consultas 5 e 8 consideram o estoque **antes** da Etapa 4. Depois do UPDATE, a Webcam fica com estoque 5 e sai das duas listas.

## Etapa 4 — UPDATE e DELETE

**Estoque da Webcam (id 4 em `mini_indici`):** antes = 0, depois do `UPDATE` = 5. Subiu 5 unidades, como esperado.

**DELETE do cliente 2:**

```
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
(`trader`.`mini_dolar`, CONSTRAINT `mini_dolar_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`))
```

**Por que o banco recusou:** o cliente 2 (Bruno Lima) tem o registro 2 da tabela `mini_dolar` (o "pedido" 2) no nome dele. A chave estrangeira `mini_dolar.cliente_id` foi criada com `ON DELETE RESTRICT`, ou seja, o banco não deixa apagar um cliente que ainda tem pedidos. Se deixasse, o pedido 2 ficaria apontando para um cliente que não existe mais (um "pedido órfão").

## Etapa 5 — testes de integridade

**Erro 1452 — mini_dolar com cliente_id 6**

```
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
(`trader`.`mini_dolar`, CONSTRAINT `mini_dolar_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`))
```

Significa que o pedido tentou apontar para um cliente que não existe. Só temos os clientes 1 a 5. A chave estrangeira obriga todo `cliente_id` em `mini_dolar` a existir na tabela `cliente`, então o banco bloqueia o INSERT.

**Erro 1062 — cliente com e-mail ana@mail.com repetido**

```
ERROR 1062 (23000): Duplicate entry 'ana@mail.com' for key 'email'
```

O campo `email` foi criado como `UNIQUE`, então dois clientes não podem ter o mesmo e-mail. Isso faz sentido porque o e-mail identifica a pessoa (login, contato, nota fiscal): se dois cadastros tivessem o mesmo e-mail, o sistema não saberia qual é o cliente certo.

**Resumo dos erros:**

| Código | Quando acontece | O que protege |
|--------|-----------------|---------------|
| 1451 | Apagar um registro "pai" que tem "filhos" (cliente com pedidos) | Impede registros órfãos |
| 1452 | Inserir um "filho" apontando para um "pai" que não existe | Impede referências a ids inexistentes |
| 1062 | Repetir um valor em coluna `UNIQUE` ou `PRIMARY KEY` | Impede duplicidade |
