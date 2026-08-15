# 横切能力 SPEC — 发布流程

## 目标

`packages/*` 各自独立发布 npm 包（`@lotus/tokens`/`@lotus/foundation`/`@lotus/icons`/`@lotus/ripple`/`@lotus/locale`），版本号语义化管理，避免手工改 `package.json` 版本号导致的疏漏。

## 工具

- **changesets**：每次影响到已发布包的 PR 需附带一个 changeset 文件，描述变更类型（major/minor/patch）与说明。合并到主分支后，changesets 自动生成版本号提升 + CHANGELOG。

## 版本策略

- `@lotus/tokens` 的破坏性变更（重命名/删除已发布变量）→ major
- 新增语义变量/新组件 → minor
- Bug 修复、性能优化（不改变公共 API）→ patch
- 各包版本号独立管理，不强制所有包版本号同步（`@lotus/tokens` 可能比 `@lotus/ripple` 迭代更快）

## 发布前检查

- [ ] `pnpm -r build` 全量构建通过
- [ ] `pnpm -r test` 全量测试通过（不允许带红发布）
- [ ] 每个待发布包的 `package.json` `exports` 字段正确指向构建产物，本地用 `pnpm pack` 模拟安装验证一次（避免"本地能跑，发布后消费方装不上"）
- [ ] CHANGELOG 内容经人工审阅，不是纯机器生成文本直接发布
- [ ] Phase 性 SPEC 全部完成后作为一次里程碑发布（如 Phase 1 完成后发布 `0.1.0`），不要求每个组件单独发版

## 注意事项（继承自用户全局开发原则）

- **发布是不可逆/难以撤销的操作**：`npm publish` 后即使 `unpublish` 也有 72 小时窗口限制且会破坏依赖它的下游，因此发布前必须走完上述检查清单，且发布动作本身需要向用户确认后才执行，不能自动化触发到"实际推送到 npm registry"这一步。
- **本仓库 commit 规范**：commit-msg 钩子拒绝含 `Co-Authored-By Claude` 的提交，release 相关的 commit（版本号提升、CHANGELOG 更新）同样遵守此规则。
