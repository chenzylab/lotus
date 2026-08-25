import type { MCPOption } from '../sidebar/mcp-configure.js';

export type { MCPOption };

/** 配置区的值：字段名 → 任意值（对齐 Semi LeftMenuChangeProps/setup）。 */
export type AiInputConfigureValue = Record<string, unknown>;

/** 合并一个字段补丁到 value，返回新对象（不可变）。 */
export function setConfigureField(value: AiInputConfigureValue, patch: AiInputConfigureValue): AiInputConfigureValue {
  return { ...value, ...patch };
}

/** 从 value 移除一个字段，返回新对象（不可变；对齐 Semi onRemove）。 */
export function removeConfigureField(value: AiInputConfigureValue, field: string): AiInputConfigureValue {
  const next: AiInputConfigureValue = {};
  for (const key of Object.keys(value)) {
    if (key !== field) next[key] = value[key];
  }
  return next;
}

/**
 * MCP 配置区计数展示："MCP · N" 格式（N 为已启用工具数）。Semi 的
 * `Configure.Mcp` 只是一个计数下拉触发器 + "配置"按钮出口，真正的工具浏览/
 * 搜索/选择由消费方提供——lotus 用已完整实现的 `Sidebar.MCPConfigure` 承接
 * "配置"按钮点击后的完整面板，两者共享 `MCPOption` 类型，不重复定义。
 */
export function mcpConfigureLabel(options: MCPOption[]): string {
  const activeCount = options.reduce((count, option) => count + (option.active ? 1 : 0), 0);
  return `MCP · ${activeCount}`;
}
