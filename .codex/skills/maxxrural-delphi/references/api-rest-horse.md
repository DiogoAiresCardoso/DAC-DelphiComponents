# API REST/Horse Patterns

## Entry Point

`MaxxRural\MaxxRuralApi\MaxxRuralApi.dpr` starts `TMaxxRuralApiService` from `src\View\MaxxRuralApi.View.Service.pas`.

Debug mode (`DebugHook <> 0`) opens `UFormServiceTester`; service mode creates the Windows Service.

`TMaxxRuralApiService.ServiceCreate` configures middleware:

- `Compression()`
- `Jhonson`
- `HandleException`
- `MiddlewareAuth`
- `HorseJWT(...)`
- `OctetStream`

Then it calls `MaxxRuralApi.Routes.RegistrarV1`.

## Routes

`src\Routes\MaxxRuralApi.Routes.pas` sets:

```pascal
THorse.Routes.Prefix('maxxRural/api/v1');
```

Typical route registration:

```pascal
TProdutoController.New.Registry;
```

Some controllers use `Registrar` rather than `Registry`; check the existing controller before copying.

## Generic CRUD Controller

`src\Controller\MaxxRuralApi.Controller.Generics.pas` defines `TMaxxRuralController<T>`.

The constructor receives the route name and whether the route is scoped by `:empresa`:

```pascal
constructor TProdutoController.Create;
begin
  inherited Create('produtos', True);
end;
```

`Registry` wires:

- `GET :empresa/<nome>`
- `GET :empresa/<nome>/:codigo`
- `POST :empresa/<nome>`
- `PUT :empresa/<nome>/:codigo`
- `PUT :empresa/<nome>/sincronizar`
- `DELETE :empresa/<nome>/:codigo`

When `Empresa = False`, the `:empresa` prefix is omitted.

## Entity Pattern

API entities live in `src\Model\Entity` and use SimpleAttributes plus local attributes:

```pascal
[Tabela('PRODUTOS')]
TPRODUTOS = class
published
  [Campo('COD_PROD'), Pk, AutoInc, Alias('codigo')]
  property COD_PROD: string read FCOD_PROD write FCOD_PROD;
end;
```

Important conventions:

- Table and database field names are uppercase.
- JSON names are usually camelCase via `Alias`.
- Primary key fields have `Pk`; generated keys commonly have `AutoInc`.
- `COD_EMP`, `DUMANUT`, `COD_USU`, and `INATIVO` are common defaults handled by DAO logic.
- Many fields are strings even when semantically numeric. Match the existing entity/table pattern.

`src\Model\MaxxRuralApi.Model.Atributos.pas` defines local `Alias` and `Exporta` attributes.

## DAO Pattern

`src\Model\DAO\MaxxRuralApi.Model.DAO.MaxxRural.pas` is the main generic DAO.

It:

- Builds SQL with SimpleSQL/SimpleRTTI from entity attributes.
- Reads Firebird connection details from `TMaxxRuralCFG`.
- Applies pagination from `limit` and `page` query params.
- Converts datasets to JSON with aliases and User-Agent behavior.
- Converts JSON back to entities with RTTI.
- Fills default values for `DUMANUT`, `INATIVO`, and `COD_USU`.
- Generates codes through `CODIGOS_TAB` when key fields are not marked for database autoincrement behavior.

Be careful with memory ownership: many methods create `TFDConnection`, `TFDQuery`, JSON values, dictionaries, and RTTI contexts manually.

## Auth

`src\Middleware\Middleware.Auth.pas` intercepts `POST /auth`.

Supported User-Agent cases:

- `AGROLEGIAO`: body requires `cpfCNPJ` and `id`.
- `EMBARCADERO URI CLIENT/1.0, MAXXRURAL` and `MAXXRURAL`: body requires `empresa` and `usuario`.

`src\Service\MaxxRuralApi.Service.Autenticacao.pas` generates HS256 JWT tokens and currently sets expiration to 20 minutes.

Desktop REST clients set `User-Agent: MaxxRural` and use `Bearer <token>`.

## Adding a Simple CRUD Endpoint

1. Add or update the entity in `src\Model\Entity`.
2. Add a controller in `src\Controller` extending `TMaxxRuralController<T>`.
3. Register it in `src\Routes\MaxxRuralApi.Routes.pas`.
4. Add the new unit to `MaxxRuralApi.dpr` if the project uses explicit includes for that area.
5. Search for any matching desktop REST client model/entity and update it when the desktop consumes the endpoint.

Do not add custom SQL to the generic DAO unless the generic attribute-based pattern cannot express the behavior.
