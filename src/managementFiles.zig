const std = @import("std");

pub const ManagementFile = struct {
    current_working_dir: std.fs.Dir, // nama folder di mana program di jalankan
    allocator: std.mem.Allocator,

    ///baca banyak file ( extensinya) di 1 folder utama
    /// inisialiasi ManagementFile  (atur default)
    pub fn init(allocator: std.mem.Allocator) ManagementFile {
        return ManagementFile{
            .current_working_dir = std.fs.cwd(), // gak perluh di bersihkan cwd otomatis managaninya
            .allocator = allocator,
        };
    }
    /// Membersihkan resource (seperti 'Drop' di Rust)
    // pub fn deinit(self: *ManagementFile) void {
    //     // Jika nanti menambah alokasi dinamis lain (ArrayList, dsb), juga bisa bebaskan di sini.
    //     // Contoh:
    //     // self.some_list.deinit();
    // }

    ///return nama nama files
    pub fn read_files(self: *ManagementFile) ![][]const u8 {
        var dir = try self.current_working_dir.openDir(".", .{ .iterate = true });
        defer dir.close();

        var iterator = dir.iterate();
        var result = std.ArrayList([]const u8).initCapacity(self.allocator, 0) catch unreachable;
        defer result.deinit(self.allocator);

        while (try iterator.next()) |entry| {
            if (entry.kind == .file) {
                // duplikasi nama file (karena entry.name tidak stabil)
                const nama_file = try self.allocator.dupe(u8, entry.name);
                try result.append(self.allocator, nama_file);
            }
        }
        return try result.toOwnedSlice(self.allocator);
    }

    /// return  : nama nama extensi file
    pub fn read_extensi_file(self: *ManagementFile) ![][]const u8 {
        var dir = try self.current_working_dir.openDir(".", .{ .iterate = true });
        defer dir.close();

        var it = dir.iterate();
        var result = std.ArrayList([]const u8).initCapacity(self.allocator, 0) catch unreachable;

        defer result.deinit(self.allocator);

        while (try it.next()) |entry| {
            if (entry.kind == .file) {
                // duplikasi nama file (karena entry.name tidak stabil)
                const name_file = try self.allocator.dupe(u8, entry.name);

                // simpan index yang di dapat pada tanda "."
                const extensi = self.get_extensi_file(name_file) catch |err| {
                    std.debug.print("Gagal mendapatkan ekstensi fn read_extensi_file: {any}\n", .{err});
                    continue; // skip file tanpa ekstensi
                };

                const ext_copy = try self.allocator.dupe(u8, extensi);

                try result.append(self.allocator, ext_copy);
            }
        }
        return try result.toOwnedSlice(self.allocator);
    }

    /// slice nama file dan mabil extensi nya aja
    pub fn get_extensi_file(_: *ManagementFile, file_name: []const u8) ![]const u8 {
        const dot_index_opt = std.mem.lastIndexOfScalar(u8, file_name, '.');
        if (dot_index_opt) |i| {
            if (i + 1 < file_name.len) {
                return file_name[i + 1 ..];
            } else {
                return error.NoExtensionFound;
            }
        } else {
            return error.NoExtensionFound;
        }
    }

    /// fn untuk buat folder folder sesuai namnay
    pub fn create_folders(self: *ManagementFile, extensi_files: []const []const u8) !void {
        for (extensi_files) |folder_name| {
            self.current_working_dir.makeDir(folder_name) catch |err| switch (err) {
                error.PathAlreadyExists => {}, // abaikan kalau sudah ada
                else => return err,
            };
        }
    }
    /// fn untuk memindahkan semua file ke dalam folder masing masig
    pub fn move_files(self: *ManagementFile, extensi_files: []const []const u8, nama_files: []const []const u8) !void {
        const cwd = self.current_working_dir;

        for (nama_files) |value| {
            std.debug.print(" file name  : {s}\n", .{value});
        }

        // jika file ada banyak maka perlu nested loop untuk memindah 1 per 1 ke folder seuia nama extensi
        for (nama_files) |src| {
            const extensi = self.get_extensi_file(src) catch "";
            if (extensi.len == 0) {
                std.debug.print("Lewati file tanpa ekstensi: {s}\n", .{src});
                continue; // skip jika tidak ada extensi
            }

            for (extensi_files) |dst| {
                if (std.mem.eql(u8, extensi, dst)) {
                    //pastikan folder tujuan
                    _ = cwd.makeDir(dst) catch |err| switch (err) {
                        error.PathAlreadyExists => {}, // skip
                        else => return err,
                    };

                    // Path lengkap untuk sumber dan tujuan
                    const src_path = try std.fmt.allocPrint(self.allocator, "./{s}", .{src});
                    const dst_path = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ dst, src });
                    defer {
                        self.allocator.free(src_path);
                        self.allocator.free(dst_path);
                    }


                    cwd.rename(src_path, dst_path) catch |err| switch (err) {
    error.FileNotFound => {
        std.debug.print("Gagal memindahkan {s}: file tidak ditemukan\n", .{src});
        continue;
    },
    else => return err,
};

                }
            }
        }
    }
};
