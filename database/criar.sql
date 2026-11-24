-- =====================================================
-- criar.sql — Etapa 1: criação do banco e das tabelas
-- Banco: trader
-- Correspondência com o roteiro:
--   cliente         = cliente
--   mini_indici     = produto
--   mini_dolar      = pedido
--   item_mini_dolar = item_pedido
-- =====================================================

CREATE DATABASE IF NOT EXISTS `trader`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `trader`;

CREATE TABLE cliente (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nome      VARCHAR(100) NOT NULL,
  email     VARCHAR(120) NOT NULL UNIQUE,
  cidade    VARCHAR(60)
) ENGINE=InnoDB;

CREATE TABLE mini_indici (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nome      VARCHAR(100) NOT NULL,
  preco     DECIMAL(10,2) NOT NULL,
  estoque   INT DEFAULT 0
) ENGINE=InnoDB;

-- DEFAULT (CURRENT_DATE) entre parênteses funciona no MariaDB (XAMPP) e no MySQL 8
CREATE TABLE mini_dolar (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  data        DATE NOT NULL DEFAULT (CURRENT_DATE),
  cliente_id  INT NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES cliente(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE item_mini_dolar (
  mini_dolar_id    INT,
  mini_indici_id   INT,
  quantidade       INT NOT NULL,
  preco_unitario   DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (mini_dolar_id, mini_indici_id),
  FOREIGN KEY (mini_dolar_id)  REFERENCES mini_dolar(id)  ON DELETE CASCADE,
  FOREIGN KEY (mini_indici_id) REFERENCES mini_indici(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
