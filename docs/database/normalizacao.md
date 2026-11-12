# Normalizacao ate a 3FN - AI TRADER

## Escopo e entrega

Esta proposta parte das 28 entidades e dos relacionamentos do HTML fornecido, antes desta adequacao. Os tipos foram confrontados com o DDL de referencia existente no repositorio. Nao foi disponibilizado o arquivo original da Aula 02 no brModelo Web: a equivalencia com esse arquivo deve ser confirmada pela Squad.

O resultado e um **modelo logico relacional**, nao um DER conceitual Peter Chen. O documento descreve as dependencias funcionais assumidas, a decomposicao e as regras de integridade. Nao modifica modelos Python, migracoes ou dados da aplicacao existente.

Entregaveis locais:

- [Modelo logico visual em HTML](../DER_AI_TRADER_Figma.html), com tipos, PK/FK, NULL/NOT NULL, UNIQUE, DEFAULT, CHECK e conectores.
- [Modelo logico em PDF](modelo_logico.pdf), exportado localmente do HTML, com folhas por modulo.
- Este documento, com problemas reais do HTML anterior e os respectivos antes/depois.
- [Dicionario de dados](dicionario_dados.md), com uma linha por coluna e regras de exclusao.
- [Fonte unica do modelo](modelo_logico.js), compartilhada pelo HTML e pelo gerador do dicionario.

**Etapas externas ainda obrigatorias:** recriar/conferir o modelo logico no brModelo Web e salva-lo na conta da Squad; exportar de la a imagem/PDF exigida pelo professor; cada integrante fazer pelo menos um commit proprio; publicar o link do repositorio no local da atividade. O PDF local e material de apoio e **nao substitui a comprovacao no brModelo Web**.

## 1. Listas de ativos e periodos em STRATEGIES - 1FN

**Antes:** `STRATEGIES(id, ..., assets, timeframes)`. Um unico campo representava varios ativos ou varios periodos, sem uma linha individual por valor.

**Problema:** grupos repetidos dificultam integridade referencial, pesquisa e exclusao de um unico elemento. A representacao de colecoes em texto nao atende a atomicidade adotada nesta atividade.

**Depois:**

```text
STRATEGIES(id PK, ...)
STRATEGY_VERSIONS(id PK, strategy_id FK, version, UNIQUE(strategy_id, version))
STRATEGY_ASSETS(strategy_version_id PK/FK, asset_id PK/FK)
STRATEGY_TIMEFRAMES(strategy_version_id PK/FK, timeframe_id PK/FK)
TIMEFRAMES(id PK, code UNIQUE, duration_seconds UNIQUE)
```

Cada par ocupa uma linha e a PK composta impede repeticao. A configuracao e vinculada a uma versao para preservar o significado dos sinais historicos. Nao ha copias de nome do ativo ou duracao do periodo nas associacoes.

## 2. Colecoes de regras, condicoes e metricas - 1FN

**Antes:** `STRATEGIES.entry_rules`, `exit_rules` e `filters`; `TRADING_SIGNALS.conditions_met` e `conditions_rejected`; `MODEL_VERSIONS.metrics`.

**Problema:** cada campo pode conter varios fatos independentes. Uma nova regra ou metrica exige editar uma colecao inteira e nao possui integridade individual.

**Depois:**

```text
STRATEGY_RULES(id PK, strategy_version_id FK, rule_kind, sequence, expression, ...)
  UNIQUE(strategy_version_id, rule_kind, sequence)
SIGNAL_CONDITIONS(signal_id PK/FK, rule_id PK/FK, is_met, observed_value)
MODEL_METRICS(model_version_id PK/FK, metric_name PK, metric_value, calculated_at)
```

Uma regra e uma expressao predicativa unica, uma condicao e o resultado de uma regra em um sinal e uma metrica e um numero identificado pelo nome dentro da versao. Os parametros aceitam somente valores escalares, nao listas.

## 3. Ticker e fonte duplicados nos registros de mercado - 3FN

**Antes:** `MARKET_DATA(id, asset_id, symbol, source, ...)`, `ORDERS(id, asset_id, symbol, ...)` e `POSITIONS(id, asset_id, symbol, ...)`; a ligacao desenhada entre provedor e candle nao tinha uma FK correspondente.

**Dependencia indevida:** `market_data.id -> asset_id -> assets.symbol`. O mesmo ticker era mantido tanto no cadastro de ativos quanto nas linhas dependentes.

**Depois:** `symbol` fica apenas em `ASSETS`, com UNIQUE. `MARKET_DATA` referencia `asset_id`, `provider_id` e `timeframe_id`; `DATASETS` tambem referencia esses cadastros. Ordens e posicoes referenciam o ativo sem copiar o ticker. A chave candidata do candle e `(asset_id, provider_id, timeframe_id, timestamp)`.

O ticker e o nome do provedor sao obtidos por JOIN. Uma alteracao no cadastro nao exige atualizar todos os candles, ordens e posicoes.

## 4. Estrategia repetida ao lado de sua versao - 3FN

**Antes:** `TRADING_SIGNALS(id, strategy_id, strategy_version_id, ...)`, enquanto `STRATEGY_VERSIONS` ja continha `strategy_id`. Ordens, posicoes e eventos de risco tambem copiavam nomes/versoes de estrategia.

**Dependencia indevida:** `signal.id -> strategy_version_id -> strategy_id -> strategy.name`.

**Depois:** o sinal armazena somente `strategy_version_id`. Uma ordem automatizada referencia `signal_id`; uma ordem manual usa NULL. O evento de risco referencia a versao avaliada. A origem de uma posicao e consultada pelas execucoes alocadas, suas ordens e os sinais dessas ordens.

A versao pertence a exatamente uma estrategia e `UNIQUE(strategy_id, version)` evita versoes repetidas dentro da mesma estrategia.

## 5. Ambiente e conta repetidos em tabelas dependentes - 3FN

**Antes:** `ORDERS(account_id, environment, ...)`, `POSITIONS(account_id, environment, ...)`, `PAPER_SESSIONS(account_id, environment, ...)` e snapshots com `portfolio_id` e `environment`.

**Dependencias indevidas:** `order.id -> account_id -> account.environment`; `snapshot.id -> portfolio_id -> account_id -> account.environment`.

**Depois:** o ambiente de negociacao permanece em `ACCOUNTS`. Ordens e sessoes referenciam a conta. Posicoes referenciam uma carteira, que referencia uma conta; o antigo `positions.account_id` nao e duplicado. Snapshots referenciam a carteira.

O campo `broker_connections.is_demo`, derivavel do ambiente de negociacao, foi removido. Ambientes em auditoria e eventos representam **o processo emissor**, que pode monitorar contas de outro ambiente; nao sao copias do ambiente da conta.

## 6. Dados da ordem repetidos nas execucoes - 3FN

**Antes:** `ORDER_EXECUTIONS(id, order_id, symbol, side, quantity, price, ...)`.

**Dependencia indevida:** `execution.id -> order_id -> order.side` e `execution.id -> order_id -> order.asset_id -> asset.symbol`.

**Depois:** a execucao contem a FK `order_id` e seus proprios fatos: quantidade executada, preco efetivo, comissao e instante. Ativo e direcao sao consultados na ordem.

O relacionamento ambiguo `ORDERS -> POSITIONS (1:N..1)` foi substituido por `POSITION_EXECUTIONS(position_id PK/FK, execution_id PK/FK, effect, allocated_quantity)`. Uma execucao pode ser repartida entre ciclos de posicao sem duplicar a execucao nem seus custos.

## 7. Valores calculaveis armazenados junto dos determinantes - 3FN

**Antes:** o contrato continha `tick_size`, `point_value` e `tick_value`; a conta continha `balance`, `used_margin` e `available_balance`; ordens e posicoes mantinham totais ja obtidos das execucoes.

**Dependencias indevidas, nas regras adotadas:** `(tick_size, point_value) -> tick_value` e `(balance, used_margin) -> available_balance`. Totais mantidos em paralelo ainda criavam risco de divergencia de atualizacao.

**Depois:**

- `tick_value = tick_size * point_value` e calculado.
- O saldo disponivel simplificado e `balance - used_margin`; reservas adicionais exigiriam fatos proprios, nao uma copia desse calculo.
- Quantidade preenchida, preco medio, comissao total, slippage e instante de preenchimento completo da ordem sao resultados de consultas as execucoes.
- Quantidade, custo medio, resultado e comissao da posicao sao calculados a partir das alocacoes, execucoes e cotacoes; `is_open` decorre de `closed_at IS NULL`.
- Carteiras guardam identidade e titularidade. Snapshots guardam observacoes historicas por `(portfolio_id, timestamp)`, nao os mesmos totais atuais em duas tabelas.
- Patrimonio, capital disponivel e retorno percentual nao sao repetidos no snapshot ao lado de seus determinantes. Saldo corrente de simulacao tambem e calculado.

As medidas historicas restantes nao dependem do estado atual da carteira. Nao existe a dependencia `portfolio_id -> total_capital` no historico: a mesma carteira pode ter observacoes diferentes em instantes diferentes.

## 8. N:M sem tabelas associativas e relacionamentos sem FK

**Antes:** usuarios/papeis e papeis/permissoes eram ligados diretamente como N:M; `USERS.role` coexistia com essa representacao. Contas/perfis de risco, contas/sessoes do agente e sinais/ordens tinham linhas desenhadas sem colunas correspondentes. Portfolios e versoes de IA tinham referencias sem conectores.

**Depois:** `USER_ROLES` e `ROLE_PERMISSIONS` possuem PKs compostas, FKs e os atributos da associacao. `USERS.role` foi removido. Foram materializadas `accounts.risk_profile_id`, `agent_sessions.account_id` e `orders.signal_id`; o desenho de **todo** relacionamento agora deriva de uma FK da fonte unica.

Essa correcao completa o mapeamento conceitual-logico. Nao se classifica automaticamente uma relacao N:M como violacao da 2FN: a 2FN depende das dependencias funcionais de uma chave composta.

## Verificacao de 1FN, 2FN e 3FN

- **1FN:** sem listas de ativos, periodos, regras, condicoes ou metricas em campos. Cada coluna representa um valor no dominio declarado.
- **2FN:** nas associacoes, os atributos nao chave dependem do par completo. Por exemplo, `assigned_at` depende de `(user_id, role_id)`; `metric_value` depende de `(model_version_id, metric_name)`; a quantidade alocada depende de `(position_id, execution_id)`. Dados descritivos dos pais nao ficam nessas tabelas.
- **3FN:** identificadores determinam os atributos de sua entidade; atributos de outro cadastro sao obtidos por FK/JOIN. As dependencias transitivas e os valores derivados descritos acima foram removidos.
- Uma PK artificial, por si so, nao prova 3FN. A conclusao depende das regras de negocio abaixo e das chaves candidatas UNIQUE registradas no dicionario.
- Campos TEXT de auditoria (`metadata`, `config_snapshot`, `old_value`, `new_value`) sao documentos historicos opacos tratados como um unico valor, nao colecoes consultaveis do dominio. Se a Squad precisar consultar seus componentes como fatos de negocio, esses componentes devem virar colunas/tabelas antes de afirmar 1FN para esse novo uso. Trocar JSON por TEXT, isoladamente, nao normaliza dados.

## Regras de negocio e limites da proposta

### Integridade declarativa

PKs, FKs, NOT NULL, UNIQUE, DEFAULT, CHECK e ON DELETE estao detalhados em [dicionario_dados.md](dicionario_dados.md) e representados no HTML/PDF. As FKs referenciam chaves candidatas de tipos compativeis. Nenhum SET NULL incide sobre campo obrigatorio.

CASCADE e usado nas associacoes/configuracoes sem vida independente. Dados de operacao e de risco usam RESTRICT para impedir perda de historico; desativacao e preferivel a exclusao. SET NULL e limitado a autoria opcional de atribuicao/auditoria e conta opcional de eventos do sistema. PKs internas nao devem ser alteradas.

### Premissas que a Squad precisa confirmar

1. `assets.symbol` e `accounts.account_number` sao unicos no universo do projeto. Se houver tickers iguais em bolsas diferentes ou numeros iguais em corretoras diferentes, as chaves naturais e esses cadastros precisam ser revistos.
2. Timeframes representam duracoes fixas; periodos de calendario, como meses, exigem outro dominio.
3. Todo sinal vem de uma versao identificada. Uma ordem manual nao precisa de sinal. O sinal e uma sugestao de origem, nao determina os campos efetivamente solicitados pela ordem: uma decisao humana pode ajusta-los.
4. Cada carteira pertence a uma conta; cada ciclo de posicao pertence a uma carteira e a um ativo. Mais de uma carteira por conta e permitida.
5. Cada versao de IA usa no maximo um dataset de treinamento. O dataset pode ser reutilizado por varias versoes/modelos.
6. Perfis usados em eventos historicos e versoes publicadas devem ser preservados; uma alteracao de limites historicos requer novo perfil. O perfil vigente da conta pode mudar sem alterar o perfil avaliado no evento.
7. `param_name` nao determina globalmente tipo ou descricao: ambos fazem parte da definicao do parametro naquela versao. Da mesma forma, uma corretora pode oferecer varios adaptadores.
8. Valores monetarios de margem e limites estao na moeda da conta. Precos nao recebem CHECK positivo generico, pois alguns instrumentos podem negociar a zero ou com preco negativo.

### Regras transacionais, nao garantidas por uma FK isolada

Estas regras precisam de validacao de servico ou trigger na futura implementacao; **nao foram instaladas no banco por esta entrega documental**:

- A regra em `signal_conditions` deve pertencer a mesma versao do sinal. Ativo e periodo do sinal devem constar nas associacoes da versao.
- `paper_sessions.account_id` deve apontar para uma conta PAPER; sessoes de simulacao da mesma conta nao devem se sobrepor.
- Uma conta/versao/perfil desativado nao deve iniciar novas operacoes, mas seu historico permanece consultavel.
- Uma alocacao deve ligar uma execucao e uma posicao da mesma conta e ativo. OPEN/CLOSE deve respeitar a direcao BUY/SELL da ordem e LONG/SHORT da posicao.
- A soma alocada de uma execucao nao pode exceder sua quantidade; a soma preenchida de uma ordem nao pode exceder a quantidade solicitada. Validar sob transacao/controle de concorrencia, nao apenas em um formulario.
- A comissao de uma execucao dividida entre posicoes deve ser rateada proporcionalmente, nao repetida integralmente em cada posicao.
- Valores escalares de parametros devem corresponder ao `param_type`. As expressoes de regras devem ser validadas pelo avaliador do dominio.

### Cardinalidades

Uma FK NOT NULL exige exatamente um pai por filho; uma FK opcional permite zero ou um. Um pai pode ter zero a muitos filhos, salvo FK individualmente UNIQUE, que limita a zero ou um. A PK composta de uma associacao impede repetir o **par**, mas nao torna cada FK individualmente unica.

O modelo nao obriga um cadastro pai a possuir filhos: tal minimo exige regra adicional de negocio. Retangulos pontilhados nas folhas do diagrama sao referencias a chaves de tabelas definidas em outra folha, nao novas tabelas.

## Reproducao e conferencias

Na raiz do repositorio:

```powershell
node scripts\gerar_dicionario_modelo.cjs
node --test tests\modelo_logico.test.cjs
```

Para atualizar o PDF, abrir [o HTML](../DER_AI_TRADER_Figma.html), usar **Imprimir / salvar PDF**, escolher A3 paisagem, escala 100%, sem cabecalhos/rodapes do navegador, e gravar como `database\modelo_logico.pdf`. O CSS imprime todas as folhas, mesmo quando um modulo esta filtrado na tela. O dicionario precisa ser regenerado sempre que a fonte do modelo mudar.

A Squad deve conferir este material no brModelo Web antes da entrega e registrar seus proprios commits. Nenhum commit, publicacao remota ou salvamento em conta externa e realizado automaticamente por estes arquivos.
