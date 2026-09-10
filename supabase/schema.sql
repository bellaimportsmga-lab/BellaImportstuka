-- ============================================
-- BELLAS IMPORTS - BANCO DE DADOS
-- Supabase / PostgreSQL
-- ============================================

create extension if not exists "pgcrypto";

-- ============================================
-- CLIENTES
-- ============================================

create table if not exists public.clientes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  telefone text,
  email text,
  cpf text,
  endereco text,
  cidade text,
  estado text,
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================
-- PRODUTOS
-- ============================================

create table if not exists public.produtos (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  descricao text,
  categoria text,
  marca text,
  codigo text,
  codigo_barras text,
  custo numeric(12,2) not null default 0,
  preco_venda numeric(12,2) not null default 0,
  estoque_minimo integer not null default 0,
  ativo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================
-- VIAGENS AO PARAGUAI
-- ============================================

create table if not exists public.viagens (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  data_viagem date,
  destino text default 'Paraguai',
  observacoes text,
  status text not null default 'planejada',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================
-- ITENS DAS VIAGENS
-- ============================================

create table if not exists public.itens_viagem (
  id uuid primary key default gen_random_uuid(),
  viagem_id uuid not null references public.viagens(id) on delete cascade,
  produto_id uuid references public.produtos(id) on delete set null,
  descricao text not null,
  quantidade integer not null default 1,
  custo_estimado numeric(12,2) not null default 0,
  comprado boolean not null default false,
  observacoes text,
  created_at timestamptz not null default now()
);

-- ============================================
-- PEDIDOS
-- ============================================

create table if not exists public.pedidos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid references public.clientes(id) on delete set null,
  canal text not null default 'whatsapp',
  numero_externo text,
  status text not null default 'pendente',
  valor_total numeric(12,2) not null default 0,
  observacoes text,
  data_pedido timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================
-- ITENS DOS PEDIDOS
-- ============================================

create table if not exists public.pedido_itens (
  id uuid primary key default gen_random_uuid(),
  pedido_id uuid not null references public.pedidos(id) on delete cascade,
  produto_id uuid references public.produtos(id) on delete set null,
  descricao text not null,
  quantidade integer not null default 1,
  preco_unitario numeric(12,2) not null default 0,
  desconto numeric(12,2) not null default 0,
  subtotal numeric(12,2) not null default 0,
  created_at timestamptz not null default now()
);

-- ============================================
-- MOVIMENTAÇÕES DE ESTOQUE
-- ============================================

create table if not exists public.movimentacoes_estoque (
  id uuid primary key default gen_random_uuid(),
  produto_id uuid not null references public.produtos(id) on delete cascade,
  tipo text not null,
  quantidade integer not null,
  custo_unitario numeric(12,2) not null default 0,
  origem text,
  referencia_id uuid,
  observacoes text,
  created_at timestamptz not null default now()
);

-- ============================================
-- CAIXA / FINANCEIRO
-- ============================================

create table if not exists public.lancamentos_caixa (
  id uuid primary key default gen_random_uuid(),
  tipo text not null,
  categoria text,
  descricao text not null,
  valor numeric(12,2) not null default 0,
  forma_pagamento text,
  data_lancamento date not null default current_date,
  pedido_id uuid references public.pedidos(id) on delete set null,
  observacoes text,
  created_at timestamptz not null default now()
);

-- ============================================
-- INTEGRAÇÕES
-- ============================================

create table if not exists public.integracoes (
  id uuid primary key default gen_random_uuid(),
  tipo text not null unique,
  nome text not null,
  ativo boolean not null default false,
  configuracao jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================
-- ÍNDICES
-- ============================================

create index if not exists idx_clientes_nome
  on public.clientes(nome);

create index if not exists idx_clientes_telefone
  on public.clientes(telefone);

create index if not exists idx_produtos_nome
  on public.produtos(nome);

create index if not exists idx_produtos_codigo
  on public.produtos(codigo);

create index if not exists idx_viagens_data
  on public.viagens(data_viagem);

create index if not exists idx_itens_viagem_viagem
  on public.itens_viagem(viagem_id);

create index if not exists idx_itens_viagem_produto
  on public.itens_viagem(produto_id);

create index if not exists idx_pedidos_cliente
  on public.pedidos(cliente_id);

create index if not exists idx_pedidos_status
  on public.pedidos(status);

create index if not exists idx_pedidos_canal
  on public.pedidos(canal);

create index if not exists idx_pedido_itens_pedido
  on public.pedido_itens(pedido_id);

create index if not exists idx_pedido_itens_produto
  on public.pedido_itens(produto_id);

create index if not exists idx_estoque_produto
  on public.movimentacoes_estoque(produto_id);

create index if not exists idx_estoque_data
  on public.movimentacoes_estoque(created_at);

create index if not exists idx_caixa_data
  on public.lancamentos_caixa(data_lancamento);

create index if not exists idx_caixa_tipo
  on public.lancamentos_caixa(tipo);

-- ============================================
-- RLS - SEGURANÇA
-- ============================================

alter table public.clientes enable row level security;
alter table public.produtos enable row level security;
alter table public.viagens enable row level security;
alter table public.itens_viagem enable row level security;
alter table public.pedidos enable row level security;
alter table public.pedido_itens enable row level security;
alter table public.movimentacoes_estoque enable row level security;
alter table public.lancamentos_caixa enable row level security;
alter table public.integracoes enable row level security;

-- ============================================
-- POLÍTICAS
-- Usuários autenticados podem acessar o sistema.
-- ============================================

create policy "usuarios autenticados clientes"
on public.clientes
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados produtos"
on public.produtos
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados viagens"
on public.viagens
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados itens viagem"
on public.itens_viagem
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados pedidos"
on public.pedidos
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados itens pedidos"
on public.pedido_itens
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados estoque"
on public.movimentacoes_estoque
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados caixa"
on public.lancamentos_caixa
for all
to authenticated
using (true)
with check (true);

create policy "usuarios autenticados integracoes"
on public.integracoes
for all
to authenticated
using (true)
with check (true);

-- ============================================
-- INTEGRAÇÕES PADRÃO
-- ============================================

insert into public.integracoes (tipo, nome, ativo)
values
  ('whatsapp', 'WhatsApp Business', false),
  ('mercadolivre', 'Mercado Livre', false)
on conflict (tipo) do nothing;
