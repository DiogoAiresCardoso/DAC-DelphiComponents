# Project Map

## Root

- `MaxxSoft.groupproj`: broad Delphi group. Includes shared libraries, desktop apps, services, login/updater, `MaxxRural\MaxxRuralApi\MaxxRuralApi.dproj`, and tests.
- `MaxxRuralApi.groupproj`: narrower group for shared API dependencies such as `Configuracao`, `Conexao`, `Entidades`, `Base`, `Parametros`, `Parceiros`, `Fazendas`, `Core`, `DocumentosFiscais`, and `ApiTestes`.
- `MaxxRural\MaxxADM\MaxxRural.dproj`: main MaxxRural desktop application.
- `MaxxRural\MaxxRuralApi\MaxxRuralApi.dproj`: API Windows Service project.
- `MaxxRural\src`: newer modular shared code used by desktop/API modules.
- `Relatorios`: many FastReport `.fr3` files. Treat as report artifacts.
- `Componentes`: custom component packages.

## Newer Modular Source

`MaxxRural\src` contains reusable packages/modules:

- `Conexao`: FireDAC/Firebird connection layer and DAO abstractions.
- `Configuracao`: config model used by connection startup.
- `Entidades`: shared entity classes.
- `Base`, `Parametros`, `Fazendas`, `Parceiro`, `Empresa`, `Core`: domain modules.
- `DocumentosFiscais`: fiscal document services/controllers/components.
- `Service\MaxxRural.Service.REST.pas`: desktop/client REST integration with the API.
- `Tests`: Delphi test projects such as `ApiTestes.dproj`.

## API Service

`MaxxRural\MaxxRuralApi` is a Windows Service that exposes HTTP endpoints with Horse. Its current source layout is:

- `src\View`: service entry and tester form.
- `src\Routes`: route registration.
- `src\Controller`: endpoint controllers.
- `src\Model\Entity`: API entity DTO/ORM classes.
- `src\Model\DAO`: generic DAO and RTTI helpers.
- `src\Model\Interface`: DAO/service/logger interfaces.
- `src\Service`: domain services, auth, logger, background services.
- `src\Middleware`: request middleware.
- `src\Utils`: JSON/data conversion and pagination.
- `modules`: third-party/vendor dependencies such as gbswagger, delphi-jose-jwt, and Horse modules. Avoid editing for product changes.

## Legacy/Peripheral Areas

- `MaxxBarter`, `MaxxRDNBarter`, `MaxxLogin`, `MaxxLoginFMX`, `MaxxAtualizador`, `Login`, `DLL`: separate apps/services/libraries. Inspect their own `.dpr`/`.dproj` before editing.
- `__history`, `DCU`, `EXE`, `DLL`, `Log`, generated stackdump files: usually build/runtime artifacts. Avoid changing unless explicitly requested.

## Build Notes

This is a Delphi/MSBuild repository. A meaningful build usually requires RAD Studio/BDS variables and installed component dependencies. If local build tooling is unavailable, validate with targeted static checks and say that the compile was not run.
