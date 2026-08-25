# DataSnap and Configuration

## What Exists in This Checkout

The product configuration class `MaxxRural\MaxxRuralApi\src\Model\MaxxRuralApi.Model.CFG.pas` reads a `DATASNAP` section from `CFG\maxx.cfg`:

- `HostName` -> `HostDataSnap`
- `DriverName` -> `DriverIDDataSnap`
- `Port` -> `PortaDataSnap`

It also reads:

- `BANCO`: Firebird host, database, database_log, port.
- `SISTEMA`: version/build/server list and `EMPRESA_AGROLEGIAO`.
- `API`: `ServiceName` and API `Port`.

The initial scan of product code did not find active DataSnap server units such as `TDSServer`, `TDSServerClass`, `TDSHTTP`, `ServerMethods`, or `ServerContainer` outside third-party samples. It did find DataSnap-related client/unit usage such as `Datasnap.DBClient` (`TClientDataSet`) on the desktop side.

Treat DataSnap as a configuration/legacy integration concern until a task points to a concrete DataSnap unit.

## Verification Search

Before making a DataSnap change, run a broad search:

```powershell
rg -n "DATASNAP|HostDataSnap|PortaDataSnap|DriverIDDataSnap|TDSServer|TDSServerClass|TDSHTTP|ServerMethods|ServerContainer|TSQLConnection|DSProviderConnection|TDSRestConnection|TDSTCPChannel|Datasnap" -g "*.pas" -g "*.dfm" -g "*.dpr"
```

If hits are only in `MaxxRural\MaxxRuralApi\modules\gbswagger\Samples` or other vendor/sample folders, do not edit those for product behavior.

## Config Behavior

`TMaxxRuralCFG.LerCFG` derives paths from `gsAppPath`:

- `FPASTACFG`: replace `\EXE\` with `\CFG\`.
- `FPASTAEXE`: executable folder.
- Backup/update folder similarly replaces `\EXE\` with `\ATUALIZACAO\`.

Default credentials in the API config class are:

- user: `SYSDBA`
- password: `masterkey`

Do not change these without understanding deployment expectations.

## Practical Guidance

When a user asks for "DataSnap" work:

1. Confirm whether they mean the legacy DataSnap service, the `DATASNAP` config section, or the current REST/Horse service.
2. Search for concrete server/client classes before editing.
3. If adding new config fields, update all relevant config classes on both API and desktop sides.
4. Preserve existing `.cfg` key names unless the deployment config will be migrated too.
