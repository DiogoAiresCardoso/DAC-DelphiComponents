# Desktop Modules and Clients

## Main Areas

The desktop side is modular under `MaxxRural\src` and application projects such as `MaxxRural\MaxxADM\MaxxRural.dproj`.

Common layers:

- `View`: forms, frames, UI workflows.
- `Controller`: presentation/application controllers.
- `Model\Entity`: Delphi entity classes.
- `Service`: integrations, REST clients, conversion helpers.
- `Conexao`: shared FireDAC connection and DAO infrastructure.
- `Shared`: filters and shared interfaces.

Inspect the module-local project file before adding a unit. Delphi projects often require units in `.dpr`, `.dproj`, package, or uses clauses.

## REST Client Consumption

`MaxxRural\src\Service\MaxxRural.Service.REST.pas` contains two REST helper classes.

`TMaxxRuralServiceREST<T>`:

- Uses `TRESTClient`, `TRESTRequest`, `TRESTResponse`.
- Authenticates against `/auth` when `dmMaxxLocal.Token` is empty.
- Uses config values `FCFG.IPRest`, `FCFG.PortaAuth`, and `FCFG.PortaRest`.
- Adds `User-Agent = MaxxRural`.
- Adds `Authorization = Bearer <token>`.
- Supports pagination with `limit` and `page`.
- Can populate a dataset from JSON docs using RTTI and `Campo` attributes.

`TServiceREST`:

- Uses RESTRequest4D `TRequest`.
- Replaces `{empresa}` in endpoint strings with `dmMaxxLocal.empresaLogadaCOD_EMP`.
- Handles JSON, octet-stream, and some text/html base64 stream responses.

When changing server responses, inspect these clients for expected JSON shape:

- Paged responses usually contain `metadata` and `docs`.
- Empty GET results may return HTTP 204.
- Some clients automatically retry on 401 after refreshing token.

## Connection Pattern

`MaxxRural\src\Conexao\src\Model\Conexao\Conexao.Model.FireDAC.pas` defines a singleton-ish `TConexaoModelFireDAC`.

It creates a `TFDManager`, disables autoload of connection definition files, and adds a Firebird connection definition with:

- `Pooled=True`
- `Server=<host>/<porta>`
- `Database=<banco>`
- `User_Name=<usuario>`
- `Password=<senha>`
- `DriverID=<driver>`
- `Protocol=TCPIP`

Connections are acquired through `FDManager.AcquireConnection`.

## UI and Artifact Caution

`.dfm` and `.fmx` files are designer-owned. For UI changes:

- Edit paired `.pas` and `.dfm`/`.fmx` together only when necessary.
- Preserve component names and event handlers.
- Avoid reformatting whole form files.

FastReport `.fr3`, skins, images, docs, and binaries should only be changed when the request is explicitly about those artifacts.
