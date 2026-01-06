const std = @import("std");
const tidy_up_files = @import("tidy_up_files");

const managementFile = @import("managementFiles.zig").ManagementFile;
const managementArgument =  @import("managementArgs.zig").ManagementArgs;

// const managementTerminal = @import("managementTerminal.zig").ManagementTerminal;
pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var file_exec = managementFile.init(allocator);
    // var terminal_exec = managementTerminal.init(allocator);
    var argument_exec = managementArgument.init(allocator);


    const extensi_file_name = file_exec.read_extensi_file() catch |err| blk: {
        std.debug.print("gagal mendapatkan extensi file name {any} \n", .{err});
        break :blk &[_][]const u8{}; // fallback ke slice kosong
    };

    const file_names = file_exec.read_files() catch |err| blk: {
        std.debug.print("gagal membaca file {any}\n", .{err});
        break :blk &[_][]const u8{};
    };
    // creater folder folder esuai nama fiel
    try file_exec.create_folders(extensi_file_name);
    // pindahkan 1 per 1 ke folder masing masing
    _ = file_exec.move_files(extensi_file_name, file_names) catch |err| {
        std.debug.print("Gagal memindahkan file: {any}\n", .{err});
    };
}
