# ZIP FTP Uploader

Console application for Delphi 10.2+ that creates a ZIP and uploads it to a
standard FTP server. It relies only on RTL (`System.Zip`) and Indy (`IdFTP`).

> FTP does not encrypt credentials or data. If the provider supports it, prefer
> SFTP or explicit FTPS; this version intentionally supports only plain FTP.

## Build

Open `ZipFtpUploader.dpr` in Delphi and use **Build**. Indy and `System.Zip`
must be available in the IDE installation.

## Configure and run

1. Copy `zip-ftp-uploader.example.ini` to a private location and replace the
   example source folders and FTP data.
2. Set the password for the current process. Do not save it in the INI file:

   ```powershell
   $env:ZIPFTP_PASSWORD = 'your-password'
   ```

3. Run the executable:

   ```powershell
   .\ZipFtpUploader.exe --config C:\secure\zip-ftp-uploader.ini
   ```

Use `--dry-run` to validate and create the ZIP without uploading. By default,
the ZIP is retained locally; add `--delete-local-zip` to remove it only after a
successful upload.

The FTP remote directory must already exist and the user must have write
permission there. The ZIP stores files below their source-folder names, which
avoids name collisions when multiple source folders contain the same file.

## MaxxRural update package

`MaxxRuralUpdatePackager.dpr` is the preset packager for MaxxRural. Its
configuration is in `maxxrural-update.ini` and it:

1. reads `VERSAO` from `Geral\uConstantes.pas`;
2. creates `M:\MaxxSoft\MaxxRural\Relatorios.zip` with every `.fr3` below the
   configured reports folder;
3. creates `M:\MaxxSoft\MaxxRural\<VERSAO>.zip`, containing `Relatorios.zip`
   and the five configured executables, then deletes the intermediate
   `Relatorios.zip` (`delete_after_packaging=true`).

Build `MaxxRuralUpdatePackager.dpr`, then run:

```powershell
.\MaxxRuralUpdatePackager.exe
```

The program looks for `maxxrural-update.ini` in the same directory as the
executable. `--config <path>` remains available when a different configuration
file is needed.

Each execution writes `MaxxRuralUpdatePackager.log` beside the executable. It
records the FTP connection, requested and confirmed remote directories, up to
100 listed items, upload result, and errors. Passwords are never logged.
It starts at `www` by default and traverses `remote_dir` one directory at a
time. Set `[ftp] start_dir` only when the account uses another initial folder.

Run `MaxxRuralUpdatePackager.exe --diagnostico` to perform only this FTP
navigation and logging; it neither creates nor sends archives.

Existing output archives are protected. Use `--sobrescrever` only when the
current version is intentionally being regenerated. FTP remains disabled until
`[ftp] enabled=true` and its connection settings are supplied.
