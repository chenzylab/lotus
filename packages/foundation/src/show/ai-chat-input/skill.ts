/**
 * 技能项（对齐 Semi Skill/BaseSkill）：空编辑区按 skillHotKey 触发面板，选中后
 * 作为 skillSlot 节点插入编辑器。hasTemplate=true 的技能选中后可展开模版面板。
 * icon 由渲染层提供，此处只管数据。
 */
export interface AiInputSkill {
  /** 展示标签（skillSlot chip 显示，缺省回退 value）。 */
  label?: string;
  /** 技能值（唯一标识/插入值）。 */
  value?: string;
  /** 是否有配套模版（选中后展示模版按钮）。 */
  hasTemplate?: boolean;
  icon?: unknown;
  [key: string]: unknown;
}

/** 取技能项的显示文本（label 优先，回退 value，再回退空串）。 */
export function skillLabel(skill: AiInputSkill): string {
  return skill.label ?? skill.value ?? '';
}

/**
 * 从编辑器 HTML 反解析 skillSlot（对齐 Semi findSkillSlotInString）。供
 * onContentChange 时同步 currentSkill 状态——不论 skillSlot 是通过技能面板
 * 选中插入的，还是用户直接 setContent() 注入字符串，内容变化后都应据此更新
 * 技能追踪状态。无 data-value 视为无效技能标记，返回 undefined。
 */
export function findSkillSlotInString(html: string): AiInputSkill | undefined {
  const match = /<skill-slot\s+([^>]*)><\/skill-slot>/i.exec(html);
  if (!match) return undefined;
  const attrs: Record<string, string> = {};
  const attrRe = /([\w-]+)=["']([^"']*)["']/g;
  let attrMatch: RegExpExecArray | null;
  while ((attrMatch = attrRe.exec(match[1] ?? '')) !== null) {
    attrs[attrMatch[1] as string] = attrMatch[2] as string;
  }
  if (!attrs['data-value']) return undefined;
  const skill: AiInputSkill = { value: attrs['data-value'] };
  if (attrs['data-label']) skill.label = attrs['data-label'];
  if (attrs['data-template']) skill.hasTemplate = attrs['data-template'] === 'true';
  return skill;
}

function escapeHTML(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function escapeAttr(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/** 生成 skillSlot 节点的 HTML（供 editor.setContent 插入）。属性值做 HTML 转义防注入。 */
export function getSkillSlotHTML(skill: AiInputSkill): string {
  const attrs: string[] = [];
  if (skill.label) attrs.push(`data-label="${escapeAttr(skill.label)}"`);
  if (skill.value) attrs.push(`data-value="${escapeAttr(skill.value)}"`);
  if (typeof skill.hasTemplate === 'boolean') attrs.push(`data-template="${skill.hasTemplate}"`);
  return `<skill-slot ${attrs.join(' ')}></skill-slot>`;
}

/** 生成 selectSlot 节点的 HTML（供 editor.setContent 插入，通常用于模版填空）。options 为 JSON 字符串。 */
export function getSelectSlotHTML(options: string[], value = ''): string {
  const optionsJson = escapeAttr(JSON.stringify(options));
  const attrs = [`options="${optionsJson}"`];
  if (value) attrs.push(`value="${escapeAttr(value)}"`);
  return `<select-slot ${attrs.join(' ')}></select-slot>`;
}

/** 生成 inputSlot 节点的 HTML（供 editor.setContent 插入，用于模版填空的可编辑空格），内含零宽字符作为空态光标锚点。 */
export function getInputSlotHTML(placeholder = '', value = ''): string {
  const ph = placeholder ? ` placeholder="${escapeAttr(placeholder)}"` : '';
  const inner = value ? escapeHTML(value) : '﻿';
  return `<input-slot${ph}>${inner}</input-slot>`;
}

/**
 * tiptap 自定义节点 `isCustomSlot` 属性描述（对齐 Semi `getCustomSlotAttribute`）。
 * 用户自定义扩展接入 AiChatInput 的光标/零宽字符 plugin 时需要这个属性标记。
 * parseHTML 恒真，renderHTML 输出 `data-custom-slot` 供 CSS/调试选择器命中。
 */
export function getCustomSlotAttribute(): {
  default: boolean;
  parseHTML: (element: unknown) => boolean;
  renderHTML: (attributes: { isCustomSlot?: boolean }) => Record<string, unknown>;
} {
  return {
    default: true,
    parseHTML: () => true,
    renderHTML: (attributes) => ({ 'data-custom-slot': attributes.isCustomSlot ? true : undefined }),
  };
}

/**
 * 是否应触发技能面板：编辑区为空、按下的键等于 skillHotKey、且有技能项。
 * 对齐 Semi：`oldValue === '' && e.key === skillHotKey && skills.length`。
 */
export function shouldOpenSkillPanel(params: { key: string; skillHotKey: string; isEmpty: boolean; skillCount: number }): boolean {
  const { key, skillHotKey, isEmpty, skillCount } = params;
  return isEmpty && key === skillHotKey && skillCount > 0;
}
