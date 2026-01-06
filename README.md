<h1 align="center"> 
tidy up files
</h1>

tools cli ( untuk sekarang ) bagi yang malas merapikan file file yang banyak , nantik `tidy up files` akan meng move atau merapikan file file ke folder dengan extensi tertentu

<p align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=zig&perline=5" />
  </a>
</p>

### FIle

- `managementFile.zig` = untuk handle bagaiman prilaku file di simpan dan lainya
- `managementArgs.zig` = management management bagaiman argument atau parameter dari yang di dapat
- `terminalStyle.zig` = handle tampilan tools ( TUI )

### argument || parameter

setal file di panggil handle argument , untuk menentukan nama forlder dan lainya

1. `-r` : rename folder spesifik

```bash
# exmaple rename file word dari doctx ke my-word
tidy-up-file -r=file_name.doctx my-word

```
