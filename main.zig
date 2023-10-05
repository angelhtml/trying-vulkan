const std = @import("std");
const vk = @import("vk.zig");
const builtin = @import("builtin");
const shaders = @import("shaders");

const BaseDispatch = vk.BaseWrapper(.{
    .createInstance = true,
});

const InstanceDispatch = vk.InstanceWrapper(.{
    .destroyInstance = true,
    .enumeratePhysicalDevices = true,
    .getPhysicalDeviceQueueFamilyProperties = true,
    .createDevice = true,
    .getDeviceProcAddr = true,
});

const DeviceDispatch = vk.DeviceWrapper(.{ 
    .destroyDevice = true, 
    .getDeviceQueue = true, 
    .queueSubmit = true, 
    .createCommandPool = true, 
    .beginCommandBuffer = true,
    .cmdDispatch=true,
    .cmdBindPipeline=true,
    .createComputePipelines=true ,.createShaderModule=true,.createPipelineLayout = true,.allocateCommandBuffers=true,.endCommandBuffer=true
    });

pub fn main() !void {
    var selflib: ?std.DynLib = null;
    selflib = try std.DynLib.open("vulkan-1.dll");

    const getProcAddress = selflib.?.lookup(
        vk.PfnGetInstanceProcAddr,
        "vkGetInstanceProcAddr",
    ) orelse {
        std.debug.print("Vulkan loader does not export vkGetInstanceProcAddr", .{});
        return error.MissingSymbol;
    };

    const vkGetDeviceProcAddr = selflib.?.lookup(
        vk.PfnGetDeviceProcAddr,
        "vkGetDeviceProcAddr",
    ) orelse {
        std.debug.print("Vulkan loader does not export vkGetInstanceProcAddr", .{});
        return error.MissingSymbol;
    };

    const allocator = std.heap.page_allocator;

    const InstanceCreateInfo = vk.InstanceCreateInfo{ .s_type = vk.StructureType.instance_create_info };

    const vkb = try BaseDispatch.load(getProcAddress);

    const instance = try vkb.createInstance(&InstanceCreateInfo, null);
    const vki = try InstanceDispatch.load(instance, getProcAddress);
    errdefer vki.destroyInstance(instance, null);

    var physical_devices_count: u32 = 0;
    _ = try vki.enumeratePhysicalDevices(instance, &physical_devices_count, null);
    const physical_devices = try allocator.alloc(vk.PhysicalDevice, physical_devices_count);
    errdefer allocator.free(physical_devices);
    _ = try vki.enumeratePhysicalDevices(instance, &physical_devices_count, physical_devices.ptr);

    var queue_family_property_count: u32 = undefined;
    vki.getPhysicalDeviceQueueFamilyProperties(physical_devices[0], &queue_family_property_count, null);
    var queue_family_properties = try allocator.alloc(vk.QueueFamilyProperties, queue_family_property_count);
    errdefer allocator.free(queue_family_properties);
    vki.getPhysicalDeviceQueueFamilyProperties(physical_devices[0], &queue_family_property_count, queue_family_properties.ptr);

    var queue_priorities = [_]f32{1.0};

    var CreatInfo = vk.DeviceQueueCreateInfo{ .s_type = vk.StructureType.device_queue_create_info, .queue_count = 1, .queue_family_index = 0, .p_queue_priorities = &queue_priorities };
    var queueCreatInfo = [_]vk.DeviceQueueCreateInfo{CreatInfo};

    const DeviceCreateInfo = vk.DeviceCreateInfo{
        .s_type = vk.StructureType.device_create_info,
        .p_queue_create_infos = &queueCreatInfo,
        .queue_create_info_count = 1,
    };

    const Device = try vki.createDevice(physical_devices[0], &DeviceCreateInfo, null);

    const vkd = try DeviceDispatch.load(Device, vkGetDeviceProcAddr);

    const ComputingQueue = vkd.getDeviceQueue(Device, 0, 0);
    _ = ComputingQueue;

    const CommandPoolInfo = vk.CommandPoolCreateInfo{ .s_type = vk.StructureType.command_pool_create_info, .queue_family_index = 0 };

    const commandPool = try vkd.createCommandPool(Device, &CommandPoolInfo, null);







    var CommandBuffer: vk.CommandBuffer = vk.CommandBuffer.null_handle;
    var CommandBuffers = [_]vk.CommandBuffer{CommandBuffer};


const CommandBufferAllocateInfo = vk.CommandBufferAllocateInfo{
.s_type=vk.StructureType.command_buffer_allocate_info,
.command_pool=commandPool,
.level=vk.CommandBufferLevel.primary,
.command_buffer_count= 1
};


 try vkd.allocateCommandBuffers(Device,&CommandBufferAllocateInfo, &CommandBuffers);




    const beginInfo = vk.CommandBufferBeginInfo{
        .s_type = vk.StructureType.command_buffer_begin_info,
                .flags = vk.CommandBufferUsageFlags{
            .one_time_submit_bit = true,
        },
    };






    try vkd.beginCommandBuffer(CommandBuffer, &beginInfo);

vkd.cmdDispatch(CommandBuffer, 1,1,1);

try vkd.endCommandBuffer(CommandBuffer);

//     var SubmitInfo = vk.SubmitInfo{
//         .s_type = vk.StructureType.submit_info,
//         .command_buffer_count = 1,
//         .p_command_buffers = &CommandBuffers,
//     };

//     var SubmitInfos = [_]vk.SubmitInfo{SubmitInfo};

// std.debug.print("{any}", .{shaders.minimal_shader.len});

// const  ShaderModuleInfo =vk.ShaderModuleCreateInfo{
//     .s_type=vk.StructureType.shader_module_create_info,
//     .code_size = 4 * shaders.minimal_shader.len,
//     .p_code= @as([*]const u32, @ptrCast(&shaders.minimal_shader)) ,
// };




//  const moudle_shader= try vkd.createShaderModule(Device, &ShaderModuleInfo, null);



// var Pipeline:vk.Pipeline = vk.Pipeline.null_handle;

// var Pipelines = [_]vk.Pipeline{Pipeline};


// const PipelineLayoutInfo =vk.PipelineLayoutCreateInfo{
// .s_type=vk.StructureType.pipeline_layout_create_info
// };


// const PipelineLayout = vkd.createPipelineLayout(Device, &PipelineLayoutInfo, null);


// const ComputePipelineInfo = vk.ComputePipelineCreateInfo{
//     .s_type =vk.StructureType.compute_pipeline_create_info,
//     .stage = .{.s_type = vk.StructureType.pipeline_shader_stage_create_info,.stage=.{.compute_bit=true},.p_name="main",.module=moudle_shader,},
//     .layout = PipelineLayout,
//     .base_pipeline_index =-1
    
// };

// vkd.createComputePipelines(Device, null, 1, ComputePipelineInfo, null, &Pipelines);



// vkd.cmdBindPipeline(CommandBuffer, vk.PipelineBindPoint.compute, Pipeline);






//     vkd.queueSubmit(ComputingQueue, 1, &SubmitInfos, null);

//     // std.debug.print("{any}", .{commandPool});
}
