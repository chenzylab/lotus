/**
 * Sidebar 是 Container 浮层壳 + 多个平行子组件（Options/Annotation/
 * MCPConfigure/CodeContent/FileContent）组成的组合套件，各自的状态机/纯函数
 * 拆在独立文件里实现，这里统一汇总重导出（对齐 `./show/*` exports 通配符
 * 只认 `foundation.ts` 作为包外可导入入口的约定）。
 */
export * from './container-machine.js';
export * from './code-content.js';
export * from './annotation.js';
export * from './mcp-configure.js';
export * from './file-item.js';
export * from './file-content.js';
export * from './main.js';
