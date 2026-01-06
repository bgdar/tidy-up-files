const std = @import("std");

const Status = enum {
    NONE,
    ERROR,

    pub fn message(self: Status, msg: []const u8) !void {

        var buffer : [100]u8 = undefined;
        const errorResult = try std.fmt.format(&buffer,"[x] Terjadi Error : {s}! ", .{msg});
        switch (self) {
            .ERROR => 
            std.debug.print("{s}\n" , .{errorResult})
            ,
        }
    }
};
// katagori parameter
const Arg = enum {
    NONE,
    RENAME, // -r (rename folder )

};

/// handle argument argument (nama_program -<arg> )
pub const ManagementArgs = struct {
    allocator: std.mem.Allocator,
    status: Status,
    cwd : std.fs.Dir,
    arg: Arg,

    pub fn init(allocator: std.mem.Allocator) ManagementArgs {
        return ManagementArgs{
            .allocator = allocator,
            .status = Status.NONE,
            .arg = Arg.NONE,
            .cwd = std.fs.cwd(),
        };
    }
    /// kembalikan arrya argument type string( chard)
    pub fn get_args(self: *ManagementArgs) ![][]const u8 {
        return try std.process.argsAlloc(self.allocator);
    }

    // PRIVATE fn unyuk handle arg 
    fn _rename_folder(self :ManagementArgs ,old_name : []const u8,  new_name : []const u8 ) void {

        self.cwd.rename(old_name, new_name) catch |err| {

            std.debug.print(" Ada yang salah saat membaca file : {e} ", .{err});
        } ;
        
    }

    /// fn utnuk handle argument yang di kirim || cek README.md
    pub fn handle_arg( self : ManagementArgs , args: [][]const u8  ) !void {
        for (args) |arg| {
            switch (arg) {
                "-r" => std.debug.print("rename folder", .{arg}),
            }
        }
    }
};
