---
name: release
description: 阶段性发布节点（Phase 完成后）执行版本发布流程时使用。对照 specs/cross-cutting/release.spec.md 的检查清单与 changesets 工作流执行。
---

# release

## 何时使用

某个 Phase SPEC 全部组件完成 DoD 后的里程碑发布，或修复重要 bug 需要打 patch 版本时。**不要求每个组件单独发版**，按 Phase 或紧急修复节点批量发布。

## 前置条件

发布是**难以撤销的操作**（`npm publish` 后即便 `unpublish` 也有 72 小时窗口限制且会破坏下游依赖），执行到真正 `npm publish`/`pnpm publish` 这一步之前，必须先向用户确认，不能自动化触发到实际推送 registry 这一步。本 skill 覆盖到"准备就绪、生成 changeset、本地验证"为止，最终 publish 命令需要用户明确同意后执行。

## 操作步骤

1. **确认发布范围**：对照 `specs/component-inventory.md` 与对应 Phase SPEC，确认该 Phase 清单已全部打勾。
2. **全量构建与测试**：`pnpm -r build && pnpm -r test`，任何一项失败则停止发布流程，先修复。
3. **changeset 生成**：对每个有变更的 package 运行 `pnpm changeset`，选择版本类型：
   - `@lotus/tokens` 破坏性变更（重命名/删除已发布变量）→ major
   - 新增语义变量/新组件 → minor
   - Bug 修复、性能优化（不改公共 API）→ patch
   - 各包版本号独立，不强制同步
4. **本地安装验证**：`pnpm pack` 模拟打包，在一个临时项目里 `pnpm add <打包产物路径>` 验证 `exports` 字段指向正确、类型声明可用，避免"本地能跑，发布后装不上"的问题。
5. **CHANGELOG 人工审阅**：changesets 自动生成的 CHANGELOG 条目需要人工过一遍语言表达，不是机器生成文本直接发布。
6. **向用户确认后**执行实际发布命令。

## Commit 规范提醒

本仓库 commit-msg 钩子拒绝含 `Co-Authored-By Claude` 的提交，版本号提升、CHANGELOG 更新等 release 相关 commit 同样遵守此规则，提交前确认 commit message 不含该字段。

## 验收标准

对照 `specs/cross-cutting/release.spec.md` 「发布前检查」小节逐项确认，全部通过后再请求用户确认发布。
