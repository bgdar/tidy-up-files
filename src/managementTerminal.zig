const std = @import("std");

pub const ManagementTerminal = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ManagementTerminal {
        return ManagementTerminal{
            .allocator = allocator,
        };
    }
    /// kembalikan arrya type string( chard)
    pub fn get_argument(self: *ManagementTerminal) ![][]const u8 {
        return try std.process.argsAlloc(self.allocator);
    }
};
