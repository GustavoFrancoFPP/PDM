# Mapa de Locais

Aplicação Flutter com Firebase Cloud Firestore para pesquisar, filtrar, cadastrar, editar, excluir e favoritar locais.

## Problema
A empresa deseja disponibilizar uma aplicação para localizar serviços e estabelecimentos em diferentes cidades, com pesquisa, filtros, detalhes e gerenciamento de favoritos.

## Objetivo
Permitir ao usuário:
- selecionar uma cidade;
- pesquisar locais por nome ou categoria;
- filtrar resultados;
- ver detalhes de um local;
- favoritar estabelecimentos;
- cadastrar, editar e excluir registros no Firestore.

## Tecnologias utilizadas
- Flutter / Dart
- Firebase Core
- Cloud Firestore
- FlutterFire CLI

## Arquitetura do projeto
- `lib/models` — modelo Local
- `lib/services` — LocalService com CRUD e filtros
- `lib/screens` — mapa, resultados e detalhes
- `lib/widgets` — componentes reutilizáveis
- `lib/dialogs` — confirmação de exclusão

## Modelo da coleção `locais`
- `nome: String`
- `categoria: String`
- `cidade: String`
- `avaliacao: Number`
- `distancia: Number`
- `horario: String`
- `descricao: String`
- `favorito: Boolean`

## Operações CRUD
- Create: `adicionar(Local local)`
- Read: `listarLocais()`
- Update: `atualizar(Local local)` e `alterarFavorito()`
- Delete: `excluir(String id)`

## Requisitos atendidos
- Seleção de cidade
- Pesquisa por nome ou categoria
- Leitura do Firestore
- Filtros por categoria e cidade
- Cadastro/edição/exclusão
- Detalhes do local
- Favoritos
- Navegação entre telas

## Tabela de testes
| ID | Teste | Resultado |
| --- | --- | --- |
| T01 | Conexão ao Firestore | Requer validação em execução |
| T02 | Pesquisa por Academia | Requer validação em execução |
| T03 | Seleção de cidade | Requer validação em execução |
| T04 | Filtro por categoria | Requer validação em execução |
| T05 | Create | Requer validação em execução |
| T06 | Read | Requer validação em execução |
| T07 | Update | Requer validação em execução |
| T08 | Delete | Requer validação em execução |
| T09 | Favorito | Requer validação em execução |
| T10 | Navegação | Requer validação em execução |

## Observação
Em execução local, a aplicação precisa do projeto Firebase configurado com `firebase_options.dart` e a coleção `locais` criada no Cloud Firestore.
